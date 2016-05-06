//
//  LKAddressBookViewController.m
//  LKchat
//
//  Created by longmen1 on 16/4/22.
//  Copyright © 2016年 LK. All rights reserved.
//

#import "LKAddressBookViewController.h"

#import "EaseMob.h"

#import "LKChatScreenViewController.h"

@interface LKAddressBookViewController ()<EMChatManagerDelegate>
/** 好友数据源 */
@property (strong, nonatomic) NSArray *buddyList;
@end

@implementation LKAddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加代理,自动登录后刷新表格
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    //获取好友列表的数据
#warning 好友列表需要在自动登录成功后才有值   是从本地数据库获取数据  如果当前有添加好友请求,环信SDK内部会往数据库添加buddy表的好友记录 如果程序删除或者第一次登录,本地是没有数据的,需要从服务器获取
    self.buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    NSLog(@"好友列表%@",self.buddyList);
    
//    //从服务器上获取好友列表
//    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
//        self.buddyList = buddyList;
//    } onQueue:nil];
    
    
//    if (self.buddyList.count == 0) {//代表数据库没有好友记录
//        
//    }
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.buddyList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"BuddyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    //1.获取好友的模型
    EMBuddy *buddy = self.buddyList[indexPath.row];
    
    //2.显示头像和名字
    cell.textLabel.text = buddy.username;
    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead"];
    
    
    return cell;
}

#pragma mark -
#pragma mark   ==============chatManager代理==============
//监听自动登录
- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    if (!error) {
        self.buddyList = [[EaseMob sharedInstance].chatManager buddyList];
        
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark   ==============监听到好友同意==============
- (void)didAcceptedByBuddy:(NSString *)username
{
    //从服务器获取新好友数据
    [self loadBuddyListFromServer];
}

- (void)loadBuddyListFromServer
{
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        NSLog(@"从服务器获取的好友列表 %@",buddyList);
        self.buddyList = buddyList;
        [self.tableView reloadData];
    } onQueue:nil];
}

#pragma mark -
#pragma mark   ==============好友列表被更新==============
- (void)didUpdateBuddyList:(NSArray *)buddyList changedBuddies:(NSArray *)changedBuddies isAdd:(BOOL)isAdd
{//只有在环信给你发送请求时才会回调 比如你同意了某个好友的请求
    NSLog(@"好友列表被更新 %@",buddyList);
    
    //重新复制数据源
    self.buddyList = buddyList;
    //刷新
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark   ==============调用此方法会出现表格delete按钮==============
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {//判断是否为删除按钮
        //获取移除好友的名字
        EMBuddy *buddy = self.buddyList[indexPath.row];
        NSString *deleteUsername = buddy.username;
        
        //删除好友api   removeFromRemote:YES是否将我从好友的列表移除
        [[EaseMob sharedInstance].chatManager removeBuddy:deleteUsername removeFromRemote:YES error:nil];
    }
    
}

#pragma mark -
#pragma mark   ==============监听被好友删除==============
- (void)didRemovedByBuddy:(NSString *)username
{
    //从服务器获得数据刷新表格
    [self loadBuddyListFromServer];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //往聊天控制器传值
    id destVC = segue.destinationViewController;
    
    if ([destVC isKindOfClass:[LKChatScreenViewController class]]) {
        //获取点击的行
        NSInteger selectedRow = [self.tableView indexPathForSelectedRow].row;
        
        LKChatScreenViewController *chatVC = destVC;
        chatVC.buddy = self.buddyList[selectedRow];
    }
    
}

@end
