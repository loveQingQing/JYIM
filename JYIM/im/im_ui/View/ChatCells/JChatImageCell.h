//
//  JChatImageCell.h
//  JYIM
//
//  Created by jy on 2019/1/16.
//  Copyright © 2019年 jy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JChatImageCellFrameModel;

//失败重发
typedef void(^sendAgainCallback)(MessageInfoModel * picMessageModel);
//查看大图回调
typedef void(^showBigPicCallback)(MessageInfoModel * picMessageModel);
//消息长按操作回调
typedef void(^longpressCallback)(LongpressSelectHandleType type,MessageInfoModel *picMessageModel);
//进入用户详情
typedef void(^userInfoCallback)(NSString *userID);
//删除
typedef void(^deleteCallback)(MessageInfoModel * picMessageModel);


NS_ASSUME_NONNULL_BEGIN

@interface JChatImageCell : UITableViewCell

@property (nonatomic, strong) JChatImageCellFrameModel * imageCellFrameModel;

#pragma mark - 回调
- (void)sendAgain:(sendAgainCallback)sendAgain showBigPicCallback:(showBigPicCallback)showBigPicCallback longpressCallback:(longpressCallback)longpressCallback toUserInfo:(userInfoCallback)userDetailCallback deleteCallback:(deleteCallback)deleteCallback;

@end

NS_ASSUME_NONNULL_END
