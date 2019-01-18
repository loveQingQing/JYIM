//
//  ChatKeyboard.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/15.
//  Copyright © 2017年 mengyao. All rights reserved.
//
#define CTKEYBOARD_DEFAULTHEIGHT   273
#define defaultMsgBarHeight  49 //模态输入框容器 49
#define  defaultInputHeight  35 //默认输入框 35

@class ChatModel,ChatAlbumModel;

#import <UIKit/UIKit.h>


//普通文本/表情消息发送回调
typedef void(^ChatTextMessageSendBlock)(NSString *text);
//语音消息发送回调
typedef void(^ChatAudioMesssageSendBlock)(ChatAlbumModel *audio);
//图片消息发送回调
typedef void(^ChatPictureMessageSendBlock)(NSArray<ChatAlbumModel *>* images);
//视频消息发送回调
typedef void(^ChatVideoMessageSendBlock)(ChatAlbumModel *videoModel);

@interface ChatKeyboard : UIView

@property (nonatomic,copy)void(^keyboardViewFrameChange)(CGRect frame);
//表情资源
@property (nonatomic, strong) NSDictionary *emotionDict;

//发送消息回调
- (void)textCallback:(ChatTextMessageSendBlock)textCallback audioCallback:(ChatAudioMesssageSendBlock)audioCallback picCallback:(ChatPictureMessageSendBlock)picCallback videoCallback:(ChatVideoMessageSendBlock)videoCallback target:(id)target ;

-(void)closeKeyboardContainer;


@end
