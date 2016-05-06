//
//  LKTimeTool.m
//  LKchat
//
//  Created by longmen1 on 16/5/5.
//  Copyright © 2016年 LK. All rights reserved.
//

#import "LKTimeTool.h"

@implementation LKTimeTool

+ (NSString *)timeStr:(long long)timestamp
{
    //返回时间格式
    /*
     今天:(HH:mm)
     昨天:(昨天 HH:mm)
     昨天以前:(yyy-MM-dd HH:mm)
     */
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //1.获取当前时间
    NSDate *currentDate = [NSDate date];
    
    //获取 年 月 日
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
    NSInteger currentYear = components.year;
    NSInteger currentMonth = components.month;
    NSInteger currentDay = components.day;
    
    //2.获取消息发送时间
    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:timestamp/1000.0];
    
    //获取 年 月 日
    components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:msgDate];
    NSInteger msgYear = components.year;
    NSInteger msgMonth = components.month;
    NSInteger msgDay = components.day;
    
    //日期格式化
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    
    //判断
    if (currentYear == msgYear
        && currentMonth == msgMonth
        && currentDay == msgDay) {//今天
        dateFmt.dateFormat = @"HH:mm";
    } else if (currentYear == msgYear
               && currentMonth == msgMonth
               && currentDay - 1 == msgDay) {//昨天
        dateFmt.dateFormat = @"昨天 HH:mm";
    } else {//昨天以前
        dateFmt.dateFormat = @"yyy-MM-dd HH:mm";
    }
    
    
    return [dateFmt stringFromDate:msgDate];
}

@end
