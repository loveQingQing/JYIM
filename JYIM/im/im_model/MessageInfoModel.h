//
//  MessageInfoModel.h
//  JYIM
//
//  Created by jy on 2019/1/7.
//  Copyright © 2019年 jy. All rights reserved.
//

#import <Foundation/Foundation.h>
#define showTimeInterval  60*2

NS_ASSUME_NONNULL_BEGIN


@interface MessageInfoModel : NSObject

@property (nonatomic, copy) NSString * theId;
@property (nonatomic, copy) NSString * messageInfoId;//消息id
@property (nonatomic, copy) NSString * fromUser;//发送者
@property (nonatomic, copy) NSString * toUser;//接受者
@property (nonatomic, assign) NSInteger messageType;//消息类型 1文本 2图片、3视频、4语音 5位置

@property (nonatomic, copy) NSString * sendTime;//发送时间
@property (nonatomic, copy) NSString * sendStatus;//发送状态 0:失败 1：成功 2：发送中..(本地->服务器)
@property (nonatomic, assign) BOOL byMySelf;//是否是由我发送
@property (nonatomic, assign) BOOL hasReceive;//是否送达（本人发给别人的）

@property (nonatomic, copy) NSString * messageText;//文本消息内容

@property (nonatomic, copy) NSString * lat;//维度
@property (nonatomic, copy) NSString * lon;//经度

//图片名字
@property (nonatomic, copy) NSString * picName;
//音频名字
@property (nonatomic, copy) NSString *audioName;
//视频名字
@property (nonatomic, copy) NSString *videoName;
//图片尺寸
@property (nonatomic, assign) CGSize  picSize;

//视频 , 语音时长
@property (nonatomic, copy) NSString * duration;

@property (nonatomic, copy) NSString * videoSize;//视频大小

//图片网络地址
@property (nonatomic, copy) NSString * picUrl;
//音频网络地址
@property (nonatomic, copy) NSString *audioUrl;
//视频网络地址
@property (nonatomic, copy) NSString *videoUrl;

@property (nonatomic, assign) NSInteger hasReadAudio;//收到的语音是否已读

// 无需保存的字段
@property (nonatomic, assign) BOOL shouldShowTime;
@property (nonatomic, copy) NSAttributedString * contentAttributedString;


/**
 是否显示时间
 */
-(void)handleShowTimeWithLastMessageModel:(id)lastMessageModel;

/**
 文本消息（包含表情）处理
 */
-(void)handleMessageText;

@end

NS_ASSUME_NONNULL_END
