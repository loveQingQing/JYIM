//
//  MessageListModel.h
//  JYIM
//
//  Created by jy on 2019/1/9.
//  Copyright © 2019年 jy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageListModel : NSObject

@property (nonatomic, copy) NSString * theId;
@property (nonatomic, copy) NSString * messageInfoId;//消息id
@property (nonatomic, copy) NSString * fromUser;//发送者
@property (nonatomic, copy) NSString * toUser;//接受者
@property (nonatomic, assign) NSInteger messageType;//消息类型 1文本 2图片、3视频、4语音 5位置

@property (nonatomic, copy) NSString * sendTime;//发送时间
@property (nonatomic, assign) BOOL byMySelf;//是否是由我发送

@property (nonatomic, assign) NSInteger notReadCount;//未读数
@property (nonatomic, copy) NSString * messageText;//文本消息内容

@property (nonatomic, copy) NSAttributedString * contentAttributedString;

/**
 文本消息（包含表情）处理
 */
-(void)handleMessageText;

@end

NS_ASSUME_NONNULL_END
