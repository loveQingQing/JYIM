//
//  JChatTextCell.h
//  JYIM
//
//  Created by jy on 2019/1/11.
//  Copyright © 2019年 jy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JChatTextCellFrameModel;

NS_ASSUME_NONNULL_BEGIN


//失败重发
typedef void(^sendAgainCallback)(MessageInfoModel * textMessageModel);

//删除
typedef void(^deleteCallback)(MessageInfoModel * textMessageModel);

//消息长按操作回调
typedef void(^longpressCallback)(LongpressSelectHandleType type,MessageInfoModel *textMessageModel);
//进入用户详情
typedef void(^userInfoCallback)(NSString *userID);

@interface JChatTextCell : UITableViewCell
@property (nonatomic, strong) JChatTextCellFrameModel * textCellFrameModel;

-(void)sendAgainCallback:(sendAgainCallback)sendAgainCallback longpressCallback:(longpressCallback)longpressCallback userInfoCallback:(userInfoCallback)userInfoCallback deleteCallBack:(deleteCallback)deleteCallBack;

@end



NS_ASSUME_NONNULL_END
