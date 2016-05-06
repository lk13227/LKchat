//
//  LKTimeTool.h
//  LKchat
//
//  Created by longmen1 on 16/5/5.
//  Copyright © 2016年 LK. All rights reserved.
//处理聊天时间工具类

#import <Foundation/Foundation.h>

@interface LKTimeTool : NSObject

/**
 *时间戳
 */
+ (NSString *)timeStr:(long long)timestamp;

@end
