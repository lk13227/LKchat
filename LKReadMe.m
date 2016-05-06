//
//  LKReadMe.m
//  LKchat
//
//  Created by longmen1 on 16/4/22.
//  Copyright © 2016年 LK. All rights reserved.
//

/*

1.使用环信的思想
》所有网络请求使用 [EaseMob sharedInstance].chatManager "聊天管理器"
》结果(自动登录、自动连接)-通过代理来回调
调用chatManager "聊天管理器" 的 【- (void)addDelegate:(id<EMChatManagerDelegate>)delegate delegateQueue:(dispatch_queue_t)queue;】

2.添加好友注意
1.添加聊天管理器的代理时，在控制器被dealloc的时候，应该移除代理
2.添加好友的代理方法，最好放在Conversation的控制器实现

3.获取好友列表数据
    注意
     * 1.好友列表buddyList需要在自动登录成功后才有值
     * 2.buddyList的数据是从 本地数据库获取
     * 3.如果要从服务器获取好友列表 调用chatManger下面的方法
     【-(void *)asyncFetchBuddyListWithCompletion:onQueue:】;
     * 4.如果当前有添加好友请求，环信的SDK内部会往数据库的buddy表添加好友记录
     * 5.如果程序删除或者用户第一次登录，buddy表是没记录，
     解决方案
     1》要从服务器获取好友列表记录
     2》设置用户第一次登录后，自动从服务器获取好友列表
 


4.接收到好友的同意好友请求后，要刷新好友列表数据


*/