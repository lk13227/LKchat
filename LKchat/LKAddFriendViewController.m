//
//  LKAddFriendViewController.m
//  LKchat
//
//  Created by longmen1 on 16/4/22.
//  Copyright © 2016年 LK. All rights reserved.
//

#import "LKAddFriendViewController.h"

#import "EaseMob.h"

@interface LKAddFriendViewController ()<EMChatManagerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textField;

@end

@implementation LKAddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#warning 代理放在会话控制器比较好  因为不会因为销毁控制器而接收不到回调
    //添加代理(聊天管理器)
    //[[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

/**
 *  加好友
 */
- (IBAction)addFriendClick:(UIButton *)sender {
    
    //添加好友
    
    //1.获取要添加好友的名字
    NSString *username = self.textField.text;
    
    //2.向服务器发送添加好友的请求
    //Buddy:好友名字
    //message:添加好友额外的信息
    NSString *loginUsername = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    NSString *message = [NSString stringWithFormat:@"我是%@",loginUsername];
    
    EMError *error = nil;
    [[EaseMob sharedInstance].chatManager addBuddy:username message:message error:&error];
    
    if (!error) {
        NSLog(@"添加好友成功");
    } else {
        NSLog(@"添加好友出错  %@",error);
    }
    
}




- (void)dealloc
{
    //控制器销毁时 移除聊天管理者的代理
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}
@end
