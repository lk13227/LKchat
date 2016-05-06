//
//  LKSettingTableViewController.m
//  LKchat
//
//  Created by longmen1 on 16/4/25.
//  Copyright © 2016年 LK. All rights reserved.
//

#import "LKSettingTableViewController.h"

#import "EaseMob.h"

@interface LKSettingTableViewController ()

- (IBAction)loginActionButton:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LKSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取已经登录用户的名字
    NSString *username = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    
    //1.设置退出按钮的文字
    [self.loginButton setTitle:[NSString stringWithFormat:@"退出登录(%@)",username] forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark   ==============退出登录==============
- (IBAction)loginActionButton:(UIButton *)sender {
    /*!
     DeviceToken:<#(BOOL)#> 推送用 手动退出的话还是关闭比较好
     */
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        if (error) {
            NSLog(@"我去 退出失败了%@",error);
        } else {
            NSLog(@"退出成功");
            //回到登录界面
            self.view.window.rootViewController = [UIStoryboard storyboardWithName:@"Login" bundle:nil].instantiateInitialViewController;
        }
    } onQueue:nil];
}
@end
