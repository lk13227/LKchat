//
//  LKChatCell.m
//  LKchat
//
//  Created by longmen1 on 16/4/26.
//  Copyright © 2016年 LK. All rights reserved.
//

#import "LKChatCell.h"

#import "LKAudioPlayTool.h"
#import "EMCDDeviceManager.h"

#import "UIImageView+WebCache.h"

@interface LKChatCell ()

/** 聊天图片控件 */
@property (nonatomic, strong) UIImageView *chatImgView;

@end

@implementation LKChatCell

- (UIImageView *)chatImgView
{
    if (!_chatImgView) {
        _chatImgView = [[UIImageView alloc] init];
    }
    return _chatImgView;
}

- (void)awakeFromNib
{
    //在此方法中做一些初始化的操作
    //1.给label添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageLabelTap:)];
    [self.messageLabel addGestureRecognizer:tap];
}

#pragma mark -
#pragma mark   ==============messageLabel点击时触发方法==============
- (void)messageLabelTap:(UITapGestureRecognizer *)recognizer
{
    //播放语音
    //只有当前消息类型为语音时才会播放语音
    /**
     EMTextMessageBody
     EMVoiceMessageBody
     EMImageMessageBody
     */
    //获取消息体
    id body = self.message.messageBodies[0];
    if ([body isKindOfClass:[EMVoiceMessageBody class]]) {
        NSLog(@"播放语音");
        
        BOOL receiver = [self.reuseIdentifier isEqualToString:receiveCellID];
        [LKAudioPlayTool playWithMessage:self.message messageLabel:self.messageLabel receiver:receiver];
        
    }
    
}

- (void)setMessage:(EMMessage *)message
{
    //重用时 移除聊天图片的控件
    [self.chatImgView removeFromSuperview];
    
    _message = message;
    
    id body = message.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) {//文本消息
        EMTextMessageBody *textBody = body;
        self.messageLabel.text = textBody.text;
    } else if ([body isKindOfClass:[EMVoiceMessageBody class]]) {//语音消息
        self.messageLabel.attributedText = [self voiceAtt];
        
    } else if ([body isKindOfClass:[EMImageMessageBody class]]) {//图片消息
        [self showImage];
        
    } else {
        self.messageLabel.text = @"未知消息体类型";
    }
}

#pragma mark -
#pragma mark   ==============显示图片==============
- (void)showImage
{
    //获取图片的消息体
    EMImageMessageBody *imgBody = self.message.messageBodies[0];
    
    //缩略图的大小
    CGRect thumbnailFrm = (CGRect){ 0, 0, imgBody.thumbnailSize};
    
    //设置label的尺寸足够显示图片
    NSTextAttachment *imgAttac = [[NSTextAttachment alloc] init];
    imgAttac.bounds = thumbnailFrm;
    NSAttributedString *imageAtt = [NSAttributedString attributedStringWithAttachment:imgAttac];
    self.messageLabel.attributedText = imageAtt;
    
    //1.cell的label里添加imageview
    [self.messageLabel addSubview:self.chatImgView];
    
    //2.设置图片控件为缩略图的尺寸
    self.chatImgView.frame = thumbnailFrm;
    
    //3.下载图片
    //如果本地图片存在,显示本地图片  如果没有,就从网络加载
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:imgBody.thumbnailLocalPath]) {
        //本地图片
        [self.chatImgView sd_setImageWithURL:[NSURL fileURLWithPath:imgBody.thumbnailLocalPath] placeholderImage:[UIImage imageNamed:@"imageDownloadFail"]];
    } else {
        //网络图片
        [self.chatImgView sd_setImageWithURL:[NSURL URLWithString:imgBody.thumbnailRemotePath] placeholderImage:[UIImage imageNamed:@"imageDownloadFail"]];
    }
    
}

#pragma mark -
#pragma mark   ==============返回语音的富文本==============
- (NSAttributedString *)voiceAtt
{
    //创建一个可变的富文本
    NSMutableAttributedString *voiceAttM = [[NSMutableAttributedString alloc] init];
    
    if ([self.reuseIdentifier isEqualToString:receiveCellID]) {//接收方: 图片+时间
        
        //1.1接收方的语音图片
        UIImage *receiverImg = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
        
        //1.2创建图片附件
        NSTextAttachment *imgAttachment = [[NSTextAttachment alloc] init];
        imgAttachment.image = receiverImg;
        imgAttachment.bounds = CGRectMake(0, -7, 30, 30);
        
        //1.3图片富文本
        NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:imgAttachment];
        [voiceAttM appendAttributedString:imgAtt];
        
        //1.4创建时间的富文本
        //获取时间
        EMVoiceMessageBody *voiceBody = self.message.messageBodies[0];
        NSInteger duration = voiceBody.duration;
        NSString *timeStr = [NSString stringWithFormat:@"%d'",duration];
        NSAttributedString *timeAtt = [[NSAttributedString alloc] initWithString:timeStr];
        [voiceAttM appendAttributedString:timeAtt];
        
    } else {//发送方: 时间+图片
        
        //2.1创建时间的富文本
        //获取时间
        EMVoiceMessageBody *voiceBody = self.message.messageBodies[0];
        NSInteger duration = voiceBody.duration;
        NSString *timeStr = [NSString stringWithFormat:@"%d'",duration];
        NSAttributedString *timeAtt = [[NSAttributedString alloc] initWithString:timeStr];
        [voiceAttM appendAttributedString:timeAtt];
        
        //2.2发送方的语音图片
        UIImage *sendImg = [UIImage imageNamed:@"chat_sender_audio_playing_full"];
        
        //2.3创建图片附件
        NSTextAttachment *imgAttachment = [[NSTextAttachment alloc] init];
        imgAttachment.image = sendImg;
        imgAttachment.bounds = CGRectMake(0, -7, 30, 30);
        
        //2.4图片富文本
        NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:imgAttachment];
        [voiceAttM appendAttributedString:imgAtt];
        
    }
    
    return [voiceAttM copy];
}


//返回cell的高度
- (CGFloat)cellHeight
{
    //重新布局子控件
    [self layoutIfNeeded];
    
    return 5 + 10 + self.messageLabel.bounds.size.height + 10 + 5;
}

@end
