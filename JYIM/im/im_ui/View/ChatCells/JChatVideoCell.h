//
//  JChatVideoCell.h
//  JYIM
//
//  Created by jy on 2019/1/17.
//  Copyright © 2019年 jy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JChatVideoCellFrameModel;
NS_ASSUME_NONNULL_BEGIN

@interface JChatVideoCell : UITableViewCell

//失败重发
typedef void(^sendAgainCallback)(MessageInfoModel * videoMessageModel);
//视频播放回调
typedef void(^playVideoCallback)(MessageInfoModel * videoMessageModel);
//消息长按操作回调
typedef void(^longpressCallback)(LongpressSelectHandleType type,MessageInfoModel *videoMessageModel);
//进入用户详情
typedef void(^userInfoCallback)(NSString *userID);
//删除
typedef void(^deleteCallback)(MessageInfoModel * videoMessageModel);

@property (nonatomic, strong) JChatVideoCellFrameModel * videoCellFrameModel;

-(void)sendAgainCallback:(sendAgainCallback)sendAgainCallback playVideoCallback:(playVideoCallback)playVideoCallback longpressCallback:(longpressCallback)longpressCallback userInfoCallback:(userInfoCallback)userInfoCallback deleteCallback:(deleteCallback)deleteCallback;

@end

NS_ASSUME_NONNULL_END
