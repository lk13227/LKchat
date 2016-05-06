//
//  LKAudioPlayTool.m
//  LKchat
//
//  Created by longmen1 on 16/5/4.
//  Copyright © 2016年 LK. All rights reserved.
//

#import "LKAudioPlayTool.h"

#import "EMCDDeviceManager.h"

static UIImageView *animatingImageView;//正在执行动画的imageview

@implementation LKAudioPlayTool

+ (void)playWithMessage:(EMMessage *)msg messageLabel:(UILabel *)msgLabel receiver:(BOOL)receiver
{
    //防止动画重复播放 移除以前所有的动画
    [animatingImageView stopAnimating];
    [animatingImageView removeFromSuperview];
    
    //获取语音路径
    EMVoiceMessageBody *voiceBody = msg.messageBodies[0];
    
    //本地语音文件路径
    NSString *path = voiceBody.localPath;
    
    //如果本地语音不存在,则使用服务器的语音路径
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        path = voiceBody.remotePath;
    }
    
    //1.播放语音
    [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:path completion:^(NSError *error) {
        NSLog(@"语音播放完毕 --%@",error);
        
        //移除动画
        [animatingImageView stopAnimating];
        [animatingImageView removeFromSuperview];
        
    }];
    
    //2.添加动画
    //2.1创建一个UIImageView添加到Label上
    UIImageView *imageView = [[UIImageView alloc] init];
    [msgLabel addSubview:imageView];
    
    //2.2添加动画的图片
    if (receiver) {
        imageView.frame = CGRectMake(0, 0, 30, 30);
        imageView.animationImages = @[
                                      [UIImage imageNamed:@"chat_receiver_audio_playing000"],
                                      [UIImage imageNamed:@"chat_receiver_audio_playing001"],
                                      [UIImage imageNamed:@"chat_receiver_audio_playing002"],
                                      [UIImage imageNamed:@"chat_receiver_audio_playing003"]
                                      ];
    } else {
        imageView.frame = CGRectMake( msgLabel.bounds.size.width - 30, 0, 30, 30);
        imageView.animationImages = @[
                                      [UIImage imageNamed:@"chat_sender_audio_playing_000"],
                                      [UIImage imageNamed:@"chat_sender_audio_playing_001"],
                                      [UIImage imageNamed:@"chat_sender_audio_playing_002"],
                                      [UIImage imageNamed:@"chat_sender_audio_playing_003"]
                                      ];
    }
    
    imageView.animationDuration = 1;//动画时间
    [imageView startAnimating];//执行动画
    animatingImageView = imageView;
    
}

+ (void)stop
{
    //停止播放语音
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    //移除动画
    [animatingImageView stopAnimating];
    [animatingImageView removeFromSuperview];
}

@end
