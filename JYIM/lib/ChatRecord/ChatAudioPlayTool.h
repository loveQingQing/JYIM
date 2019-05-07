//
//  ChatAudioPlayTool.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/25.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <Foundation/Foundation.h>

//播放完成
typedef void(^audioPlayerFinishCallback)(MessageInfoModel * theAudioModel,NSIndexPath * theIndexPath);

//暂停播放的回调
typedef void(^audioPlayerPauseCallback)(MessageInfoModel * theAudioModel,NSIndexPath * theIndexPath);

//将要开始播放的回调
typedef void(^audioPlayerWillPlayCallback)(MessageInfoModel * theAudioModel,NSIndexPath *theIndexPath);

//下载中的回调
typedef void(^audioPlayerdownloadingCallback)(MessageInfoModel * theAudioModel,NSIndexPath *theIndexPath,CGFloat progress);

//下载失败的回调
typedef void(^audioPlayerdownloadFailedCallback)(MessageInfoModel * theAudioModel,NSIndexPath *theIndexPath);


@interface ChatAudioPlayTool : NSObject


+ (ChatAudioPlayTool *)sharedInstance;

-(void)playWithMessageInfo:(MessageInfoModel *)messageInfoModel withIndexPath:(NSIndexPath *)inedxPath;
-(void)stopPlay;
-(void)audioPlayerWillPlayCallback:(audioPlayerWillPlayCallback)audioPlayerWillPlayCallback audioPlayerPauseCallback:(audioPlayerPauseCallback)audioPlayerPauseCallback audioPlayerFinishCallback:(audioPlayerFinishCallback)audioPlayerFinishCallback audioPlayerdownloadingCallback:(audioPlayerdownloadingCallback)audioPlayerdownloadingCallback audioPlayerdownloadFailedCallback:(audioPlayerdownloadFailedCallback)audioPlayerdownloadFailedCallback;

//如果当前正在播放的是此声音模型，暂停其播放
-(void)stopPlayWithAudioMessage:(MessageInfoModel *)audioMessage;

@end
