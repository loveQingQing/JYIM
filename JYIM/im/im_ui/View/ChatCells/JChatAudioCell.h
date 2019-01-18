//
//  JChatAudioCell.h
//  JYIM
//
//  Created by jy on 2019/1/14.
//  Copyright © 2019年 jy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JChatAudioCellFrameModel;

NS_ASSUME_NONNULL_BEGIN

//失败重发
typedef void(^sendAgainCallback)(MessageInfoModel * audioModel);
//播放语音回调
typedef void(^playAudioCallback)(MessageInfoModel * audioModel);
//消息长按操作回调
typedef void(^longpressCallback)(LongpressSelectHandleType type,MessageInfoModel *audioModel);
//进入用户详情
typedef void(^userInfoCallback)(NSString *userID);

@interface JChatAudioCell : UITableViewCell

@property (nonatomic, strong) JChatAudioCellFrameModel * audioCellFrameModel;


-(void)playGIF;
-(void)stopGif;

#pragma mark - 回调
- (void)sendAgain:(sendAgainCallback)sendAgain playAudio:(playAudioCallback)playAudio longpress:(longpressCallback)longpress toUserInfo:(userInfoCallback)userDetailCallback;
//下载进度
-(void)showDownLoadProgress:(double)progress;

//隐藏对方发来的语音消息未读红点
-(void)hideRedPoint;
@end

NS_ASSUME_NONNULL_END
