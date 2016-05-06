//
//  LKLoginViewController.m
//  LKchat
//
//  Created by longmen1 on 16/4/21.
//  Copyright © 2016年 LK. All rights reserved.
//

#import "LKLoginViewController.h"

#import "EaseMob.h"

@interface LKLoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *userNameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LKLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (IBAction)registerClick:(UIButton *)sender {
    
    NSString *userName = self.userNameField.text;
    NSString *password = self.passwordField.text;
    
    if (userName.length == 0 || password.length == 0)
    {
        NSLog(@"登录失败，请检查输入内容");
        return;
    }
    
    //注册
    [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:userName password:password withCompletion:^(NSString *username, NSString *password, EMError *error) {
        
        if (!error) {
            NSLog(@"注册成功");
        } else {
            NSLog(@"注册失败");
        }
        
    } onQueue:dispatch_get_main_queue()];
}

- (IBAction)loginClick:(UIButton *)sender {
    
    //用户第一次登录后 自动从服务器获取数据,添加到本地数据库
    [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];
    
    NSString *userName = self.userNameField.text;
    NSString *password = self.passwordField.text;
    
    if (userName.length == 0 || password.length == 0)
    {
        NSLog(@"登录失败，请检查输入内容");
        return;
    }
    
    //登录
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:userName password:password completion:^(NSDictionary *loginInfo, EMError *error) {
        //登录请求完成后的回调
        if (!error) {
            NSLog(@"登陆成功\n %@",loginInfo);
            NSLog(@"沙盒%@",NSHomeDirectory());
            /**
             LastLoginTime = 1461227602605;//上次登录时间
             jid = "liniankeji#lkchat_liukai@easemob.com";//ID
             password = 123456;//密码
             resource = mobile;//登录的客户端类型
             token = "YWMttQo9lgebEeaF2aXUxPdCaQAAAVVs8VBVZg-iI5JKePPARDAC3MjMS9Vvdfc";//令牌
             username = liukai;//用户名
             */
            
            //设置自动登录
            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
            
            //进入主页面
            self.view.window.rootViewController = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
            
        } else {
            NSLog(@"登陆失败\n %@",error);
            //User do not exist.
            //每一个app都有自己的注册用户
        }
    } onQueue:dispatch_get_main_queue()];//block在哪个线程调用
}

@end
