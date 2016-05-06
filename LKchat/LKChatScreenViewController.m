//
//  LKChatScreenViewController.m
//  LKchat
//
//  Created by longmen1 on 16/4/25.
//  Copyright © 2016年 LK. All rights reserved.
//

#import "LKChatScreenViewController.h"

#import "LKChatCell.h"
#import "LKTimeChatCell.h"
#import "LKAudioPlayTool.h"
#import "LKTimeTool.h"

#import "EMCDDeviceManager.h"

@interface LKChatScreenViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,EMChatManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

/** 输入工具条底部约束 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *toolBarBottomConstraint;
/** 数据源 */
@property (strong, nonatomic) NSMutableArray *dataSource;
/** 计算高度的cell的工具对象 */
@property (strong, nonatomic) LKChatCell *chatCellTool;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
/** 输入工具条高度约束 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *toolBarHeightConstraint;
/** 按住说话按钮 */
@property (strong, nonatomic) IBOutlet UIButton *recordBtn;
/** 输入框 */
@property (strong, nonatomic) IBOutlet UITextView *textView;
/** 当前添加的时间 */
@property (copy, nonatomic) NSString *currentTimeStr;
/** 当前的会话对象 */
@property (strong, nonatomic) EMConversation *conversation;

@end

@implementation LKChatScreenViewController

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置背景颜色
    self.tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
    
    //给计算cell高度工具对象赋值
    self.chatCellTool = [self.tableView dequeueReusableCellWithIdentifier:sendCellID];
    
    //显示好友姓名
    self.title = self.buddy.username;
    
    //加载本地的聊天记录
    [self loadLocalChatRecord];
    
    //设置聊天管理器的代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    //1.监听键盘的弹出,把输入工具条约束往上移
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //2.监听键盘的退出,把输入工具条约束回复
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //滚到最下面
    [self scrollToBottom];
}

/**
 *  加载本地的聊天记录
 */
- (void)loadLocalChatRecord
{
    
    //要获取本地聊天记录使用 使用会话对象
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.buddy.username conversationType:eConversationTypeChat];
    
    //给当前会话对象赋值
    self.conversation = conversation;
    
    //加载当前用户的所有聊天记录
    NSArray *messages = [conversation loadAllMessages];
    
    //添加到数据源
//    [self.dataSource addObjectsFromArray:messages];
    for (EMMessage *msgObj in messages) {
        [self addDataSourceWithMessage:msgObj];
    }
}

//键盘显示时会触发的方法
- (void)kbWillShow:(NSNotification *)noti
{
    //1.获取键盘的高度
    //1.1获取键盘结束时的位置
    CGRect kbEndFr = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbHeight = kbEndFr.size.height;
    
    //2.更改约束
    self.toolBarBottomConstraint.constant = kbHeight;
    //添加动画
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

//键盘退出时会触发的方法
- (void)kbWillHide:(NSNotification *)noti
{
    //更改约束
    self.toolBarBottomConstraint.constant = 0;
    //添加动画
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

- (void)dealloc
{
    //记得移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark   ==============tableView==============
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //时间cell高度固定
    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {//时间cell
        return 20;
    }
    
    //设置label的数据
    //1.获取消息模型
    EMMessage *msg = self.dataSource[indexPath.row];
    
    //2.获取消息体
    self.chatCellTool.message = msg;
    
    return [self.chatCellTool cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //判断数据源类型
    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {//时间cell
        LKTimeChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeCell"];
        cell.timeLabel.text = self.dataSource[indexPath.row];
        return cell;
    }
    
    
    LKChatCell *cell = nil;
    
    //先获取模型
    EMMessage *message = self.dataSource[indexPath.row];
    
    if ([message.from isEqualToString:self.buddy.username]) {//接收方
        cell = [tableView dequeueReusableCellWithIdentifier:receiveCellID];
    } else {//发送方
        cell = [tableView dequeueReusableCellWithIdentifier:sendCellID];
    }
    
    
    cell.message = message;
    
    return cell;
}

//tableview开始滑动的方法 滑动时停止播放语音
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [LKAudioPlayTool stop];
}

#pragma mark -
#pragma mark   ==============uitextView==============
- (void)textViewDidChange:(UITextView *)textView
{
    
    //计算textview的高度,调整整个输入工具条的高度
    CGFloat textViewH = 0;
    CGFloat minHeight = 34;//textView最小的高度
    CGFloat maxHeight = 68;//textView最大的高度
    
    //获取contentSize的高度
    CGFloat contentHeight = textView.contentSize.height;
    if (contentHeight < minHeight) {
        textViewH = minHeight;
    } else if (contentHeight > maxHeight){
        textViewH = maxHeight;
    } else {
        textViewH = contentHeight;
    }
    
    
    //监听send事件 判断最后的一个字符是不是换行 是为send
    if ([textView.text hasSuffix:@"\n"]) {
        
        [self sendText:textView.text];
        
        //清空文字
        textView.text = nil;
        
        //发送时textView的高度为34
        textViewH = minHeight;
    }
 
    
    //调整整个输入工具条的高度
    self.toolBarHeightConstraint.constant = 15 + 15 + textViewH;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    //使输入框的光标返回原位
    [textView setContentOffset:CGPointZero animated:YES];
    [textView scrollRangeToVisible:textView.selectedRange];
    
}

- (void)scrollToBottom
{
    
    if (self.dataSource.count == 0) {
        return;
    }
    
    //获取最后一行
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark -
#pragma mark   ==============发送文本构造==============
- (void)sendText:(NSString *)text
{
    //把最后一个换行字符删除 \n只占用一个长度
    text = [text substringToIndex:text.length - 1];
    NSLog(@"发送 ---- %@",text);
    
    //创建一个聊天文本对象
    EMChatText *chatText = [[EMChatText alloc] initWithText:text];
    
    //创建文本消息体
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithChatObject:chatText];
    
    //发送消息
    [self sendMessage:textBody];
    
}
#pragma mark -
#pragma mark   ==============发送语音构造==============
- (void)sendVoice:(NSString *)recordPath duration:(NSInteger)duration
{
    //1.构造一个语音消息体
    EMChatVoice *chatVoice = [[EMChatVoice alloc] initWithFile:recordPath displayName:@"[语音消息]"];
    //chatVoice.duration = duration; //时间设置一个就好
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc] initWithChatObject:chatVoice];
    voiceBody.duration = duration;
    
    //3.发送消息
    [self sendMessage:voiceBody];
    
}

#pragma mark -
#pragma mark   ==============发送图片构造==============
- (void)sendImage:(UIImage *)selectedImg
{
    //1.构造图片消息体
    
    EMChatImage *orginalChatImg = [[EMChatImage alloc] initWithUIImage:selectedImg displayName:@"[图片]"];//原始图片
    /**
     第一个参数:原始大小的图片对象
     第二个参数:缩略图的图片对象
     */
    EMImageMessageBody *imageBody = [[EMImageMessageBody alloc] initWithImage:orginalChatImg thumbnailImage:nil];
    
    //发送消息
    [self sendMessage:imageBody];
    
}

#pragma mark -
#pragma mark   ==============发送消息基本构造==============
- (void)sendMessage:(id<IEMMessageBody>)body
{
    //1.构造消息对象
    EMMessage *msgObj = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[body]];
    msgObj.messageType = eMessageTypeChat;//单聊
    
    //2.发送消息
    [[EaseMob sharedInstance].chatManager asyncSendMessage:msgObj progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送消息");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"图片发送消息 --%@",error);
    } onQueue:nil];
    
    //3.把消息添加到数据库 再刷新表格
    [self addDataSourceWithMessage:msgObj];
    [self.tableView reloadData];
    
    //4.把新消息显示在最上面
    [self scrollToBottom];
}

#pragma mark -
#pragma mark   ==============接收好友的回复消息==============
- (void)didReceiveMessage:(EMMessage *)message
{
    //判断是否为当前聊天用户
    if ([message.from isEqualToString:self.buddy.username]) {
        //1.把接受的消息添加到数据源
        [self addDataSourceWithMessage:message];
        //2.刷新表格
        [self.tableView reloadData];
        //3.滚动到最新数据
        [self scrollToBottom];
    }
    
}


#pragma mark -
#pragma mark   ==============录音相关==============
- (IBAction)voiceClick:(UIButton *)sender {
    //显示录音按钮
    self.recordBtn.hidden = !self.recordBtn.hidden;
    //隐藏输入框
    self.textView.hidden = !self.textView.hidden;
    
    if (self.recordBtn.hidden == NO) {//录音按钮要显示
        //聊天工具栏的高度要回到默认高度(64)
        self.toolBarHeightConstraint.constant = 64;
        //隐藏键盘
        [self.view endEditing:YES];
    } else {
        //不录音时,显示键盘
        [self.textView becomeFirstResponder];
        //恢复输入工具条的高度
        [self textViewDidChange:self.textView];
    }
}

//开始录音
- (IBAction)recordBeginClick:(UIButton *)sender {
    
    //文件名已时间命名
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
        if (!error) {
            NSLog(@"开始录音成功");
        } else {
            NSLog(@"开始录音失败---%@",error);
        }
    }];
}

//手指从按钮的范围内松开,结束录音 并且发送
- (IBAction)recordEndClick:(UIButton *)sender {
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            NSLog(@"录音成功\n%@\n%u", recordPath, aDuration);
            
            //发送语音给服务器
            [self sendVoice:recordPath duration:aDuration];
            
        } else {
            NSLog(@"录音失败---%@",error);
        }
    }];
}

//手指从按钮的范围外松开,取消录音
- (IBAction)recordCancelClick:(UIButton *)sender {
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

#pragma mark -
#pragma mark   ==============图片相关==============
- (IBAction)showImagePickerAction:(UIButton *)sender {
    
    //显示图片选择的控制器
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    
    //设置源
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//相册
    
    //设置代理
    imgPicker.delegate = self;
    
    [self presentViewController:imgPicker animated:YES completion:NULL];
    
}

/**
 *  选中图片后的回调方法
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //1.获取用户选中的图片
    UIImage *selectedImg = info[UIImagePickerControllerOriginalImage];
    
    //2.发送图片
    [self sendImage:selectedImg];
    
    //3.隐藏当前的图片选择控制器
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark   ==============添加数据源==============
- (void)addDataSourceWithMessage:(EMMessage *)msg
{
    //判断EMMessage对象前是否要加"时间"
    NSString *timeStr = [LKTimeTool timeStr:msg.timestamp];
    if (![self.currentTimeStr isEqualToString:timeStr]) {
        [self.dataSource addObject:timeStr];
        self.currentTimeStr = timeStr;
    }
    
    //再加EMMessage
    [self.dataSource addObject:msg];
    
    //设置消息为已读
    [self.conversation markMessageWithId:msg.messageId asRead:YES];
    
}


@end
