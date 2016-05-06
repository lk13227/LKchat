//
//  AppDelegate.m
//  LKchat
//
//  Created by longmen1 on 16/4/21.
//  Copyright © 2016年 LK. All rights reserved.
//

#import "AppDelegate.h"

#import "EaseMob.h"

@interface AppDelegate ()<EMChatManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //registerSDKWithAppKey:注册的appKey，详细见下面注释。
    //apnsCertName:推送证书名(不需要加后缀)，详细见下面注释。
    //[[EaseMob sharedInstance] registerSDKWithAppKey:@"liniankeji#lkchat" apnsCertName:nil];
    
    //1.初始化环信SDK  并且隐藏环信日志输出
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"liniankeji#lkchat" apnsCertName:nil otherConfig:@{ kSDKConfigEnableConsoleLogger : @(NO) }];
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    //2.监听自动登录的状态
    //设置chatManager代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:dispatch_get_main_queue()];//nil的话默认主线程调用
    
    //3.如果登陆过来到主界面
    if ([[EaseMob sharedInstance].chatManager isAutoLoginEnabled]) {
        self.window.rootViewController = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
    }
    
    return YES;
}

- (void)dealloc
{
    //控制器销毁时 移除聊天管理者的代理
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

//自动登录的回调
- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    if (!error) {
        NSLog(@"自动登录成功  %@", loginInfo);
    } else {
        NSLog(@"自动登录失败  %@", error);
    }
}

// App进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

// App将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

// 申请处理时间
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}

@end
