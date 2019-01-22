//
//  JChatLocationCell.h
//  JYIM
//
//  Created by jy on 2019/1/19.
//  Copyright © 2019年 jy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JChatLocationCellFrameModel;
NS_ASSUME_NONNULL_BEGIN

@interface JChatLocationCell : UITableViewCell

@property (nonatomic, strong)JChatLocationCellFrameModel * locationCellFrameModel;

//失败重发
typedef void(^sendAgainCallback)(MessageInfoModel * locationMessageModel);
//视频播放回调
typedef void(^showDetailLocationCallback)(MessageInfoModel * locationMessageModel);
//消息长按操作回调
typedef void(^longpressCallback)(LongpressSelectHandleType type,MessageInfoModel *locationMessageModel);
//进入用户详情
typedef void(^userInfoCallback)(NSString *userID);

//删除
typedef void(^deleteCallback)(MessageInfoModel * locationMessageModel);

-(void)sendAgainCallback:(sendAgainCallback)sendAgainCallback showDetailLocationCallback:(showDetailLocationCallback)showDetailLocationCallback longpressCallback:(longpressCallback)longpressCallback userInfoCallback:(userInfoCallback)userInfoCallback deleteCallback:(deleteCallback)deleteCallback;

@end

NS_ASSUME_NONNULL_END
