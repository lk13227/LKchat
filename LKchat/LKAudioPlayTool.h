//
//  LKAudioPlayTool.h
//  LKchat
//
//  Created by longmen1 on 16/5/4.
//  Copyright © 2016年 LK. All rights reserved.
//语音播放工具类

#import <Foundation/Foundation.h>

@interface LKAudioPlayTool : NSObject

+ (void)playWithMessage:(EMMessage *)msg messageLabel:(UILabel *)msgLabel receiver:(BOOL)receiver;

+ (void)stop;

@end
