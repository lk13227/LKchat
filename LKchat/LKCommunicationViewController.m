//
//  LKCommunicationViewController.m
//  LKchat
//
//  Created by longmen1 on 16/4/22.
//  Copyright © 2016年 LK. All rights reserved.
//

#import "LKCommunicationViewController.h"

#import "EaseMob.h"

#import "LKChatScreenViewController.h"

@interface LKCommunicationViewController ()<EMChatManagerDelegate>

/** 历史会话数据 */
@property (strong, nonatomic) NSArray *conversations;

@end

static NSString *conversationCellID = @"conversationCell";

@implementation LKCommunicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    //获取历史会话记录
    [self loadConversations];
    
}

#pragma mark -
#pragma mark   ==============获取历史会话记录==============
- (void)loadConversations
{
    //1.从内存获取历史会话记录
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    
    //2.如果内存里没有会话记录,就从数据库Conversation表获取
    if (conversations.count == 0) {
        conversations = [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    }
    NSLog(@"获取历史会话记录===%@",conversations);
    self.conversations = conversations;
    
    //显示总的未读数
    [self showTabBarBadge];
}

#pragma mark -
#pragma mark   ==============//1.监听网络状态==============
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
//    eEMConnectionConnected,   //连接成功
//    eEMConnectionDisconnected,//未连接
    if (connectionState == eEMConnectionDisconnected) {
        NSLog(@"网络断开,连接中.......");
        self.navigationItem.title = @"未链接";
    } else {
        NSLog(@"只是网络已连接");
    }
}

#pragma mark -
#pragma mark   ==============//2.监听自动链接的状态==============
- (void)willAutoReconnect
{
    NSLog(@"将要自动重新连接");
    self.navigationItem.title = @"链接中";
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error
{
    if (!error) {
        NSLog(@"自动重新链接成功....");
        self.navigationItem.title = @"会话";
    } else {
        NSLog(@"自动重新链接失败....%@",error);
    }
}


#pragma mark -
#pragma mark   ==============好友添加代理==============
- (void)didAcceptedByBuddy:(NSString *)username
{//对方同意加好友回调
    NSString *message = [NSString stringWithFormat:@"%@ 同意了你的好友请求",username];
    
    //初始化提示框；
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"好友添加信息" message:message preferredStyle: UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //点击按钮的响应事件；
    }]];
    //弹出提示框；
    [self presentViewController:alert animated:true completion:nil];
}

- (void)didRejectedByBuddy:(NSString *)username
{//对方拒绝了你的好友请求
    NSString *message = [NSString stringWithFormat:@"%@ 拒绝了你的好友请求",username];
    
    //初始化提示框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"好友添加信息" message:message preferredStyle: UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //点击按钮的响应事件
    }]];
    //弹出提示框；
    [self presentViewController:alert animated:true completion:nil];
}


#pragma mark -
#pragma mark   ==============接收到好友的添加请求==============
- (void)didReceiveBuddyRequest:(NSString *)username message:(NSString *)message
{
    
    //初始化提示框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"好友添加请求" message:message preferredStyle: UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //拒绝事件
        [[EaseMob sharedInstance].chatManager rejectBuddyRequest:username reason:@"我不认识你" error:nil];
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //同意事件
        [[EaseMob sharedInstance].chatManager acceptBuddyRequest:username error:nil];
        
    }]];
    //弹出提示框；
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark -
#pragma mark   ==============监听被好友删除==============
- (void)didRemovedByBuddy:(NSString *)username
{
    NSLog(@"你被%@给删掉了,真可怜",username);
    NSString *message = [NSString stringWithFormat:@"你被%@给删掉了,真可怜",username];
    //初始化提示框；
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"你被好友删除了" message:message preferredStyle: UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"(ーー゛)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //点击按钮的响应事件；
    }]];
    //弹出提示框；
    [self presentViewController:alert animated:true completion:nil];
}


- (void)dealloc
{
    //控制器销毁时 移除聊天管理者的代理
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}


#pragma mark -
#pragma mark   ==============表格视图相关==============
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:conversationCellID];
    
    //获取会话模型
    EMConversation *conversation = self.conversations[indexPath.row];
    
    //显示数据
    //显示用户名
    cell.textLabel.text = [NSString stringWithFormat:@"%@  未读的消息数 %zd",conversation.chatter ,[conversation unreadMessagesCount]];
    
    //显示最新的一条记录
    //获取消息体
    id body = conversation.latestMessage.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) {
        EMTextMessageBody *textBody = body;
        cell.detailTextLabel.text = textBody.text;
    }else if ([body isKindOfClass:[EMVoiceMessageBody class]]){
        EMVoiceMessageBody *voiceBody = body;
        cell.detailTextLabel.text = [voiceBody displayName];
    }else if ([body isKindOfClass:[EMImageMessageBody class]]){
        EMImageMessageBody *imgBody = body;
        cell.detailTextLabel.text = imgBody.displayName;
    }else{
        cell.detailTextLabel.text = @"未知消息类型";
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //进入聊天控制器
    //1.从storyboard加载聊天控制器
    LKChatScreenViewController *chatVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"chatPage"];//使用storyboardID初始化一个控制器
    
    //会话  需要自己构造好友模型
    EMConversation *conversation = self.conversations[indexPath.row];
    EMBuddy *buddy = [EMBuddy buddyWithUsername:conversation.chatter];
    
    //2.设置好友模型
    chatVC.buddy = buddy;
    
    //3.展现聊天界面
    [self.navigationController pushViewController:chatVC animated:YES];
    
}

#pragma mark -
#pragma mark   ==============历史会话列表更新回调==============
- (void)didUpdateConversationList:(NSArray *)conversationList
{
    //给数据源重新赋值
    self.conversations = conversationList;
    //刷新表格
    [self.tableView reloadData];
    
    //显示tabbar上的总未读数
    [self showTabBarBadge];
}

#pragma mark -
#pragma mark   ==============监听未读消息数发生改变时的回调==============
- (void)didUnreadMessagesCountChanged
{
    //更新表格
    [self.tableView reloadData];
    
    //显示tabbar上的总未读数
    [self showTabBarBadge];
}

#pragma mark -
#pragma mark   ==============显示总未读数==============
- (void)showTabBarBadge
{
    //遍历所有的会话记录 将未读的消息数进行累加
    NSInteger totalUnreadCount = 0;
    for (EMConversation *conversation in self.conversations) {
        totalUnreadCount += [conversation unreadMessagesCount];
    }
    
    //显示tabbar上原点的值
    self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%zd",totalUnreadCount];
    
}


@end
