//
//  ChatAudioPlayTool.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/25.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatAudioPlayTool.h"
#import <AVFoundation/AVFoundation.h>

@interface ChatAudioPlayTool ()<AVAudioPlayerDelegate>


 @property (nonatomic, strong)   MessageInfoModel *  currentMessageInfoModel;
@property (nonatomic, strong) AVAudioPlayer * player;
@property (nonatomic, strong) AVAudioSession * session;
@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, assign) BOOL isPlaying;
    

@property (nonatomic, copy) audioPlayerWillPlayCallback audioPlayerWillPlayCallback;
@property (nonatomic, copy) audioPlayerPauseCallback audioPlayerPauseCallback;
@property (nonatomic, copy) audioPlayerFinishCallback audioPlayerFinishCallback;
@property (nonatomic, copy) audioPlayerdownloadingCallback audioPlayerdownloadingCallback;
@property (nonatomic, copy) audioPlayerdownloadFailedCallback audioPlayerdownloadFailedCallback;

@end

@implementation ChatAudioPlayTool

// 本类的单例对象
static ChatAudioPlayTool *instance = nil;

+ (ChatAudioPlayTool *)sharedInstance
{
    if (instance == nil)
    {
        instance = [[ChatAudioPlayTool alloc] init];
    }
    return instance;
}

-(void)playWithMessageInfo:(MessageInfoModel *)messageInfoModel withIndexPath:(NSIndexPath *)inedxPath{
    WS(weakSelf)
    if (_isPlaying == YES) {
        NSString * lastMessageInfoModelId = _currentMessageInfoModel.messageInfoId;
        if ([lastMessageInfoModelId isEqualToString:messageInfoModel.messageInfoId]) {
            
            _audioPlayerPauseCallback(_currentMessageInfoModel,_indexPath);
            [self stopPlay];
            return;
        }else{
            _audioPlayerPauseCallback(_currentMessageInfoModel,_indexPath);
            [self stopPlay];
        }
    }
    _currentMessageInfoModel = messageInfoModel;
    _indexPath = inedxPath;
    NSString *audioPath = nil;
    
    //本人发送
    if (messageInfoModel.byMySelf) {
        audioPath = [NSString stringWithFormat:@"%@/%@/%@",ChatCache_Path,messageInfoModel.toUser,messageInfoModel.audioName];
    }else{
        audioPath = [NSString stringWithFormat:@"%@/%@/%@",ChatCache_Path,messageInfoModel.fromUser,messageInfoModel.audioName];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioPath]) {
        NSURL *url = [NSURL fileURLWithPath:audioPath];
        
        if (_player == nil) {
            NSError * playError = nil;
            //播放录音
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&playError];
            if (playError) {
                NSLog(@"播放器创建失败");
                return;
            }
        }
        _player.delegate = self;
        [_player play];
        _isPlaying = YES;
        _audioPlayerWillPlayCallback(_currentMessageInfoModel,_indexPath);
        if (_session == nil) {
            _session = [AVAudioSession sharedInstance];
            NSError *sessionError;
            [_session setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
            [_session setActive:YES error:nil];
            
        } else {
            
            [_session setActive:YES error:nil];
        }
    }else{
        //本地文件不存在
        if(messageInfoModel.audioUrl){
            //下载,然后播放
            [WWNetworkHelper downFileBySuspendWithURL:messageInfoModel.audioUrl fileSavePath:audioPath progress:^(NSProgress *progress) {
                weakSelf.audioPlayerdownloadingCallback(weakSelf.currentMessageInfoModel,weakSelf.indexPath,progress.fractionCompleted);
            } success:^(id responseObject) {
                
                NSURL *url = [NSURL fileURLWithPath:audioPath];
                
                if (weakSelf.player == nil) {
                    NSError * playError = nil;
                    //播放录音
                    weakSelf.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&playError];
                    if (playError) {
                        NSLog(@"播放器创建失败");
                        return;
                    }
                }
                weakSelf.player.delegate = self;
                [weakSelf.player play];
                weakSelf.isPlaying = YES;
                weakSelf.audioPlayerWillPlayCallback(weakSelf.currentMessageInfoModel,weakSelf.indexPath);
                if (weakSelf.session == nil) {
                    weakSelf.session = [AVAudioSession sharedInstance];
                    NSError *sessionError;
                    [weakSelf.session setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
                    [weakSelf.session setActive:YES error:nil];
                    
                } else {
                    
                    [weakSelf.session setActive:YES error:nil];
                }
                
            } failure:^(NSError *error) {
                weakSelf.audioPlayerdownloadFailedCallback(weakSelf.currentMessageInfoModel, weakSelf.indexPath);
            }];
            
        }else{
            NSLog(@"网络文件url不存在");
            return;
        }
    }
    
}
-(void)stopPlay{
    if (_isPlaying == YES) {
        
        _isPlaying = NO;
        [_player stop];
        _player = nil;
        [_session setActive:NO error:nil];
        _session = nil;
        _currentMessageInfoModel = nil;
        _indexPath = nil;
    }
}

#pragma mark - 播放器代理方法
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    _audioPlayerFinishCallback(_currentMessageInfoModel,_indexPath);
    NSLog(@"音乐播放完成...");
    [self stopPlay];
}
-(void)audioPlayerWillPlayCallback:(audioPlayerWillPlayCallback)audioPlayerWillPlayCallback audioPlayerPauseCallback:(audioPlayerPauseCallback)audioPlayerPauseCallback audioPlayerFinishCallback:(audioPlayerFinishCallback)audioPlayerFinishCallback audioPlayerdownloadingCallback:(audioPlayerdownloadingCallback)audioPlayerdownloadingCallback audioPlayerdownloadFailedCallback:(audioPlayerdownloadFailedCallback)audioPlayerdownloadFailedCallback{
    
    _audioPlayerWillPlayCallback = audioPlayerWillPlayCallback;
    _audioPlayerPauseCallback = audioPlayerPauseCallback;
    _audioPlayerFinishCallback = audioPlayerFinishCallback;
    _audioPlayerdownloadingCallback = audioPlayerdownloadingCallback;
    _audioPlayerdownloadFailedCallback = audioPlayerdownloadFailedCallback;
}
-(void)stopPlayWithAudioMessage:(MessageInfoModel *)audioMessage{
    if (_isPlaying == YES && [_currentMessageInfoModel.messageInfoId isEqualToString:audioMessage.messageInfoId]) {
        [self stopPlay];
    }
}
@end
