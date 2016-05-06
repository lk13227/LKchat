//
//  LKChatCell.h
//  LKchat
//
//  Created by longmen1 on 16/4/26.
//  Copyright © 2016年 LK. All rights reserved.
//聊天的cell

#import <UIKit/UIKit.h>

static NSString *sendCellID = @"sendCell";
static NSString *receiveCellID = @"receiveCell";

@interface LKChatCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

/** 聊天消息模型 */
@property (strong, nonatomic) EMMessage *message;

- (CGFloat)cellHeight;

@end
