//  ----------------------------------------------------------------------
//  Copyright (C) 2017  即时通讯网(52im.net) & Jack Jiang.
//  The MobileIMSDK_X (MobileIMSDK v3.x) Project.
//  All rights reserved.
//
//  > Github地址: https://github.com/JackJiang2011/MobileIMSDK
//  > 文档地址: http://www.52im.net/forum-89-1.html
//  > 即时通讯技术社区：http://www.52im.net/
//  > 即时通讯技术交流群：320837163 (http://www.52im.net/topic-qqgroup.html)
//
//  "即时通讯网(52im.net) - 即时通讯开发者社区!" 推荐开源工程。
//
//  如需联系作者，请发邮件至 jack.jiang@52im.net 或 jb2011@163.com.
//  ----------------------------------------------------------------------
//
//  IMClientManager.m
//  MibileIMSDK4iDemo_X (A demo for MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 15/11/8.
//  Copyright © 2017年 52im.net. All rights reserved.
//

#import "IMClientManager.h"
#import "ClientCoreSDK.h"
#import "ConfigEntity.h"
#import "LocalUDPDataSender.h"


@interface IMClientManager ()<ChatBaseEvent,ChatTransDataEvent,MessageQoSEvent>

/* MobileIMSDK是否已被初始化. true表示已初化完成，否则未初始化. */
@property (nonatomic, assign) BOOL _init;
//所有的代理
@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, assign) BOOL hasLogin;



@end


@implementation IMClientManager

// 本类的单例对象
static IMClientManager *instance = nil;

+ (IMClientManager *)sharedInstance
{
    if (instance == nil)
    {
        instance = [[super allocWithZone:NULL] init];
    }
    return instance;
}

/*
 *  重写init实例方法实现。
 *
 *  @return
 *  @see [NSObject init:]
 */
- (id)init
{
    if (![super init])
        return nil;
    
    [self initMobileIMSDK];
    
    return self;
}

- (void)initMobileIMSDK
{
    if(!self._init)
    {
        // 设置AppKey
        [ConfigEntity registerWithAppKey:@"5418023dfd98c579b6001741"];
        
        // 设置好服务端的连接地址
        [ConfigEntity setServerIp:ServerIP];
        // 设置好服务端的UDP监听端口号
        [ConfigEntity setServerPort:[ServerPort intValue]];
        
        // 使用以下代码表示不绑定固定port（由系统自动分配），否则使用默认的7801端口
//      [ConfigEntity setLocalUdpSendAndListeningPort:-1];
        
        // RainbowCore核心IM框架的敏感度模式设置
//      [ConfigEntity setSenseMode:SenseMode10S];
        
        // 开启DEBUG信息输出
        [ClientCoreSDK setENABLED_DEBUG:YES];
        
        // 设置事件回调
        [ClientCoreSDK sharedInstance].chatBaseEvent = self;
        [ClientCoreSDK sharedInstance].chatTransDataEvent = self;
        [ClientCoreSDK sharedInstance].messageQoSEvent = self;
        
        self._init = YES;
        self.hasLogin = NO;
       
    }
}

- (NSMutableArray *)delegates
{
    
    if (!_delegates) {
        _delegates = [NSMutableArray array];
    }
    return _delegates;
}

- (void)releaseMobileIMSDK
{
    [[ClientCoreSDK sharedInstance] releaseCore];
    [self resetInitFlag];
}

- (void)resetInitFlag
{
    self._init = NO;
    self.imDB = nil;
    self.uid = nil;
    self.hasLogin = NO;
}

//添加代理
- (void)addDelegate:(id<IMClientManagerDelegate>)delegate{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}
//移除代理
- (void)removeDelegate:(id<IMClientManagerDelegate>)delegate{
    
     [self.delegates removeObject:delegate];
}

/*
 * 主动登陆信息发送实现方法。
 */
- (void)doLoginWithUid:(NSString *)uid withToken:(NSString *)loginTokenStr
{
    
    // * 发送登陆数据包(提交登陆名和密码)
    [[LocalUDPDataSender sharedInstance] sendLogin:uid withToken:loginTokenStr];
    self.uid = uid;
}


#pragma mark ---  ChatBaseEvent 与IM服务器的连接事件

/*!
 * 本地用户的登陆结果回调事件通知。
 *
 * @param dwErrorCode 服务端反馈的登录结果：0 表示登陆成功，否则为服务端自定义的出错代码（按照约定通常为>=1025的数）
 */
- (void) onLoginMessage:(int)dwErrorCode
{

   
    if (_hasLogin == NO) {
         //登录操作
        if (dwErrorCode == COMMON_CODE_OK) {
            
            IMDataBase * db = [[IMDataBase alloc] initWithUid:self.uid];
            self.imDB = db;
            _hasLogin = YES;
            
        }else{
            self.uid = nil;
            
        }
        for (id<IMClientManagerDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(LoginActionRequestResultWithCode:)]) {
                [delegate LoginActionRequestResultWithCode:dwErrorCode];
            }
        }
        
    }else{
      //断线重连
        if (dwErrorCode == COMMON_CODE_OK) {
            
        }else{
            
            
        }
    }
    
}

/*!
 * 与服务端的通信断开的回调事件通知。
 *
 * <br>
 * 该消息只有在客户端连接服务器成功之后网络异常中断之时触发。
 * 导致与与服务端的通信断开的原因有（但不限于）：无线网络信号不稳定、WiFi与2G/3G/4G等同开情
 * 况下的网络切换、手机系统的省电策略等。
 *
 * @param dwErrorCode 本回调参数表示表示连接断开的原因，目前错误码没有太多意义，仅作保留字段，目前通常为-1
 */
- (void) onLinkCloseMessage:(int)dwErrorCode
{
    NSLog(@"【DEBUG_UI】与IM服务器的网络连接出错关闭了，error：%d 与IM服务器的连接已断开, 自动登陆/重连将启动!", dwErrorCode);
    for (id<IMClientManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(onLinkCloseMessage:)]) {
            [delegate onLinkCloseMessage:dwErrorCode];
        }
    }
    
}

#pragma mark --- ChatTransDataEvent 与IM服务器的数据交互事件
/*!
 * 收到普通消息的回调事件通知。
 * <br>
 * 应用层可以将此消息进一步按自已的IM协议进行定义，从而实现完整的即时通信软件逻辑。
 *
 * @param fingerPrintOfProtocal 当该消息需要QoS支持时本回调参数为该消息的特征指纹码，否则为null
 * @param userid 消息的发送者id（RainbowCore框架中规定发送者id=“0”即表示是由服务端主动发过的，否则表示的是其它客户端发过来的消息）
 * @param dataContent 消息内容的文本表示形式
 */
- (void) onTransBuffer:(NSString *)fingerPrintOfProtocal withUserId:(NSString *)dwUserid andContent:(NSString *)dataContent andTypeu:(int)typeu
{
    NSDictionary *resultDict = [AppUtil dictionaryWithJsonString:dataContent];
    if(resultDict == nil){
        return;
    }
    NSString * sendTime = [resultDict[@"time"] substringWithRange:NSMakeRange(0, 10)];//有可能安卓过来的消息13位，截取10位
    switch (typeu) {
        case 1://文本
        {
               [self.imDB saveMessageInfoWithMessageInfoId:fingerPrintOfProtocal fromUserId:dwUserid toUid:self.uid messageType:typeu messageText:resultDict[@"content"] sendTime:sendTime sendStatus:@"1" byMySelf:0 hasReceive:1 picName:@"" audioName:@"" videoName:@"" picSize:@"" duration:@"" videoSize:@"" picUrl:@"" audioUrl:@"" videoUrl:@"" lat:@"" lon:@"" hasReadAudio:0];
        }
            break;
        case 2://图片
        {
            NSString * picSizeStr = [NSString stringWithFormat:@"{%@}",resultDict[@"content"]];
            [self.imDB saveMessageInfoWithMessageInfoId:fingerPrintOfProtocal fromUserId:dwUserid toUid:self.uid messageType:typeu messageText:@"" sendTime:sendTime sendStatus:@"1" byMySelf:0 hasReceive:1 picName:[resultDict[@"urlimg"] lastPathComponent] audioName:@"" videoName:@"" picSize:picSizeStr duration:@""  videoSize:@"" picUrl:resultDict[@"urlimg"] audioUrl:@""  videoUrl:@"" lat:@"" lon:@"" hasReadAudio:0];
        }
            break;
        case 3://视频
        {
            [self.imDB saveMessageInfoWithMessageInfoId:fingerPrintOfProtocal fromUserId:dwUserid toUid:self.uid messageType:typeu messageText:@"" sendTime:sendTime sendStatus:@"1" byMySelf:0 hasReceive:1 picName:[NSString stringWithFormat:@"%@_cover.jpg",fingerPrintOfProtocal] audioName:@"" videoName:[resultDict[@"urlfile"] lastPathComponent]  picSize:@"" duration:@""  videoSize:@"" picUrl:resultDict[@"urlimg"] audioUrl:@""  videoUrl:resultDict[@"urlfile"] lat:@"" lon:@"" hasReadAudio:0];
        }
            break;
        case 4://语音
        {
             [self.imDB saveMessageInfoWithMessageInfoId:fingerPrintOfProtocal fromUserId:dwUserid toUid:self.uid messageType:typeu messageText:@"" sendTime:sendTime sendStatus:@"1" byMySelf:0 hasReceive:1 picName:@"" audioName:[resultDict[@"urlfile"] lastPathComponent] videoName:@"" picSize:@"" duration:resultDict[@"content"]  videoSize:@"" picUrl:@"" audioUrl:resultDict[@"urlfile"]  videoUrl:@"" lat:@"" lon:@"" hasReadAudio:0];
        }
            break;
        case 5://位置
        {
           [self.imDB saveMessageInfoWithMessageInfoId:fingerPrintOfProtocal fromUserId:dwUserid toUid:self.uid messageType:typeu messageText:resultDict[@"content"] sendTime:sendTime sendStatus:@"1" byMySelf:0 hasReceive:1 picName:@"" audioName:@"" videoName:@"" picSize:@"" duration:@"" videoSize:@"" picUrl:@"" audioUrl:@""  videoUrl:@"" lat:resultDict[@"lat"] lon:resultDict[@"lon"] hasReadAudio:0];
        }
            break;
        default:
            break;
    }
    
    
    if(_inChatRoomWithUid != nil && [_inChatRoomWithUid isEqualToString:dwUserid]){
        [self.imDB insertOrUpdateContactWithMessageId:fingerPrintOfProtocal fromUser:dwUserid toUser:_uid messageType:typeu sendTime:sendTime byMySelf:0 notReadCount:0 messageText:resultDict[@"content"]];
    }else{
        [self.imDB insertOrUpdateContactWithMessageId:fingerPrintOfProtocal fromUser:dwUserid toUser:_uid messageType:typeu sendTime:sendTime byMySelf:0 notReadCount:1 messageText:resultDict[@"content"]];
    }
    
    NSLog(@"【DEBUG_UI】[%d]收到来自用户%@的消息:%@", typeu, dwUserid, dataContent);
    for (id<IMClientManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(onTransBuffer:withUserId:andContent:andTypeu:)]) {
            [delegate onTransBuffer:fingerPrintOfProtocal withUserId:dwUserid andContent:dataContent andTypeu:typeu];
        }
    }
    
}

/*!
 * 服务端反馈的出错信息回调事件通知。
 *
 * @param errorCode 错误码，定义在常量表 ErrorCode 中有关服务端错误码的定义
 * @param errorMsg 描述错误内容的文本信息
 * @see ErrorCode
 */
- (void) onErrorResponse:(int)errorCode withErrorMsg:(NSString *)errorMsg
{
    NSLog(@"【DEBUG_UI】收到服务端错误消息，errorCode=%d, errorMsg=%@", errorCode, errorMsg);
    
    
    for (id<IMClientManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(onErrorResponse:withErrorMsg:)]) {
            [delegate onErrorResponse:errorCode withErrorMsg:errorMsg];
        }
    }
    
}



#pragma mark --- MessageQoSEvent 消息送达相关事件（由QoS机制通知上来的)

/*!
 * 消息未送达的回调事件通知.
 *
 * @param lostMessages 由MobileIMSDK QoS算法判定出来的未送达消息列表（此列表
 * 中的Protocal对象是原对象的clone（即原对象的深拷贝），请放心使用哦），应用层
 * 可通过指纹特征码找到原消息并可以UI上将其标记为”发送失败“以便即时告之用户
 */
- (void) messagesLost:(NSMutableArray*)lostMessages
{
    
    NSLog(@"【DEBUG_UI】收到系统的未实时送达事件通知，当前共有%li个包QoS保证机制结束，判定为【无法实时送达】！", (unsigned long)[lostMessages count]);
    for (id<IMClientManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(messagesLost:)]) {
            [delegate messagesLost:lostMessages];
        }
    }
  
}

/*!
 * 消息已被对方收到的回调事件通知.
 * <p>
 * <b>目前，判定消息被对方收到是有两种可能：</b>
 * <br>
 * 1) 对方确实是在线并且实时收到了；<br>
 * 2) 对方不在线或者服务端转发过程中出错了，由服务端进行离线存储成功后的反馈
 * （此种情况严格来讲不能算是“已被收到”，但对于应用层来说，离线存储了的消息
 * 原则上就是已送达了的消息：因为用户下次登陆时肯定能通过HTTP协议取到）。
 *
 * @param theFingerPrint 已被收到的消息的指纹特征码（唯一ID），应用层可据此ID
 * 来找到原先已发生的消息并可在UI是将其标记为”已送达“或”已读“以便提升用户体验
 */
- (void) messagesBeReceived:(NSString *)theFingerPrint
{
    [self.imDB updateMessageInfoReceiveStatusWithMessageIdsArr:@[theFingerPrint]];
    
    NSLog(@"【DEBUG_UI】收到对方已收到消息事件的通知（消息已送达）");
    for (id<IMClientManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(messagesBeReceived:)]) {
            [delegate messagesBeReceived:theFingerPrint];
        }
    }
    
}

/**
 发送文本消息 type:1;
 */
-(MessageInfoModel *)sendTextMessageWithStr:(NSString *)str toUserId:(NSString *)toUid{
    MessageInfoModel * model = [[MessageInfoModel alloc] init];
    
    NSString * fp = [Protocal genFingerPrint];
    NSString * sendTime = [AppUtil getNowTimeTimestamp];
    NSDictionary * paraDic = @{@"content":str,@"time":sendTime,@"urlimg":@"",@"urlfile":@"",@"lon":@"",@"lat":@""};
    model.messageInfoId = fp;
    model.fromUser = self.uid;
    model.toUser = toUid;
    model.messageType = 1;
    model.sendTime = sendTime;
    model.byMySelf = YES;
    model.hasReceive = NO;
    model.messageText = str;
    model.lat = @"";
    model.lon = @"";
    model.picName = @"";
    model.audioName = @"";
    model.videoName = @"";
    model.picSize = CGSizeZero;
    model.duration = @"";
    model.videoSize = @"";
    model.picUrl = @"";
    model.audioUrl = @"";
    model.videoUrl = @"";
    
    NSString * jsonStr = [AppUtil convertToJsonStr:paraDic];
    if (jsonStr == nil) {
        jsonStr = [AppUtil convertToJsonStr:@{@"content":@"⚠️此内容转换出错",@"time":sendTime,@"urlimg":@"",@"urlfile":@"",@"lon":@"",@"lat":@""}];
        
    }
    
   int code =  [self sendMessageWithJsonStr:jsonStr toUid:toUid fp:fp WithType:1];
    if (code == COMMON_CODE_OK) {
        
        [self.imDB saveMessageInfoWithMessageInfoId:fp fromUserId:self.uid toUid:toUid messageType:1 messageText:str sendTime:sendTime sendStatus:@"1" byMySelf:1 hasReceive:0  picName:@"" audioName:@"" videoName:@"" picSize:@"" duration:@"" videoSize:@"" picUrl:@"" audioUrl:@"" videoUrl:@"" lat:@"" lon:@"" hasReadAudio:0];
        model.sendStatus = @"1";
    }else{
        [self.imDB saveMessageInfoWithMessageInfoId:fp fromUserId:self.uid toUid:toUid messageType:1 messageText:str sendTime:sendTime sendStatus:@"0" byMySelf:1 hasReceive:0  picName:@"" audioName:@"" videoName:@"" picSize:@"" duration:@"" videoSize:@"" picUrl:@"" audioUrl:@"" videoUrl:@"" lat:@"" lon:@"" hasReadAudio:0];
        model.sendStatus = @"0";
    }
    [self.imDB insertOrUpdateContactWithMessageId:fp fromUser:self.uid toUser:toUid messageType:1 sendTime:sendTime byMySelf:1 notReadCount:0 messageText:str];
    
    for (id<IMClientManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(sendMessageWithFp:)]) {
            [delegate sendMessageWithFp:fp];
        }
    }
    
    return model;
}

/**
 发送图片消息 type 2
 */
-(MessageInfoModel *)sendImageMessageWithImageData:(NSData *)imgData toUserId:(NSString *)toUid picSize:(CGSize)picSize{
    
    NSString * fp = [Protocal genFingerPrint];
    NSString * sendTime = [AppUtil getNowTimeTimestamp];
    
    NSString *picName = [NSString stringWithFormat:@"ChatPic_%@.jpg",fp];
    
    MessageInfoModel * model = [[MessageInfoModel alloc] init];
    
    model.messageInfoId = fp;
    model.fromUser = self.uid;
    model.toUser = toUid;
    model.messageType = 2;
    model.sendTime = sendTime;
    model.byMySelf = YES;
    model.hasReceive = NO;
    model.messageText = @"";
    model.lat = @"";
    model.lon = @"";
    model.picName = picName;
    model.audioName = @"";
    model.videoName = @"";
    model.picSize = picSize;
    model.duration = @"";
    model.videoSize = @"";
    model.picUrl = @"";
    model.audioUrl = @"";
    model.videoUrl = @"";
    model.sendStatus = @"2";
    
    NSString * basePath = [ChatCache_Path stringByAppendingPathComponent:toUid];
    
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL exist = [manager fileExistsAtPath:basePath];
    if (!exist) {
        [manager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    //图片写入缓存
    
    [imgData writeToFile:[basePath stringByAppendingPathComponent:picName] atomically:YES];
    
    [self.imDB saveMessageInfoWithMessageInfoId:fp fromUserId:self.uid toUid:toUid messageType:2 messageText:@"" sendTime:sendTime sendStatus:@"2" byMySelf:1 hasReceive:0  picName:picName audioName:@"" videoName:@"" picSize:NSStringFromCGSize(picSize) duration:@"" videoSize:@"" picUrl:@"" audioUrl:@"" videoUrl:@"" lat:@"" lon:@"" hasReadAudio:0];
    
    [self.imDB insertOrUpdateContactWithMessageId:fp fromUser:self.uid toUser:toUid messageType:2 sendTime:sendTime byMySelf:1 notReadCount:0 messageText:@""];
    
    
    for (id<IMClientManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(sendMessageWithFp:)]) {
            [delegate sendMessageWithFp:fp];
        }
    }
    
    return model;
}

/**
 发送视频消息
 */
-(MessageInfoModel *)sendVideoMessageWithCoverImageData:(NSData *)imgData videoName:(NSString *)videoName toUserId:(NSString *)toUid{
    NSString * fp = [Protocal genFingerPrint];
    NSString * sendTime = [AppUtil getNowTimeTimestamp];
    
    NSString *picName = [NSString stringWithFormat:@"%@_cover.jpg",fp];
    
    MessageInfoModel * model = [[MessageInfoModel alloc] init];
    
    model.messageInfoId = fp;
    model.fromUser = self.uid;
    model.toUser = toUid;
    model.messageType = 3;
    model.sendTime = sendTime;
    model.byMySelf = YES;
    model.hasReceive = NO;
    model.messageText = @"";
    model.lat = @"";
    model.lon = @"";
    model.picName = picName;
    model.audioName = @"";
    model.videoName = videoName;
    model.picSize = CGSizeZero;
    model.duration = @"";
    model.videoSize = @"";
    model.picUrl = @"";
    model.audioUrl = @"";
    model.videoUrl = @"";
    model.sendStatus = @"2";
    
    NSString * basePath = [ChatCache_Path stringByAppendingPathComponent:toUid];
    
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL exist = [manager fileExistsAtPath:basePath];
    if (!exist) {
        [manager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    //图片写入缓存
    
    [imgData writeToFile:[basePath stringByAppendingPathComponent:picName] atomically:YES];
    
    [self.imDB saveMessageInfoWithMessageInfoId:fp fromUserId:self.uid toUid:toUid messageType:3 messageText:@"" sendTime:sendTime sendStatus:@"2" byMySelf:1 hasReceive:0  picName:picName audioName:@"" videoName:videoName picSize:@"" duration:@"" videoSize:@"" picUrl:@"" audioUrl:@"" videoUrl:@"" lat:@"" lon:@"" hasReadAudio:0];
    
    [self.imDB insertOrUpdateContactWithMessageId:fp fromUser:self.uid toUser:toUid messageType:3 sendTime:sendTime byMySelf:1 notReadCount:0 messageText:@""];
    
    
    for (id<IMClientManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(sendMessageWithFp:)]) {
            [delegate sendMessageWithFp:fp];
        }
    }
    
    return model;
}

/**
 发送语音消息
 */
-(MessageInfoModel *)sendVoiceMessageWithAudioData:(NSData*)audioData audioDuration:(NSString *)audioDuration toUserId:(NSString *)toUid;
{
    
    NSString * fp = [Protocal genFingerPrint];
    NSString * sendTime = [AppUtil getNowTimeTimestamp];
    
    NSString *audioName = [NSString stringWithFormat:@"ChatAudio_%@.mp3",fp];
    
    MessageInfoModel * model = [[MessageInfoModel alloc] init];
    
    model.messageInfoId = fp;
    model.fromUser = self.uid;
    model.toUser = toUid;
    model.messageType = 4;
    model.sendTime = sendTime;
    model.byMySelf = YES;
    model.hasReceive = NO;
    model.messageText = @"";
    model.lat = @"";
    model.lon = @"";
    model.picName = @"";
    model.audioName = audioName;
    model.videoName = @"";
    model.picSize = CGSizeZero;
    model.duration = audioDuration;
    model.videoSize = @"";
    model.picUrl = @"";
    model.audioUrl = @"";
    model.videoUrl = @"";
    model.sendStatus = @"2";
    
    NSString * basePath = [ChatCache_Path stringByAppendingPathComponent:toUid];
    
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL exist = [manager fileExistsAtPath:basePath];
    if (!exist) {
        [manager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    //语音写入缓存
    [audioData writeToFile:[basePath stringByAppendingPathComponent:audioName] atomically:YES];
    
   [self.imDB saveMessageInfoWithMessageInfoId:fp fromUserId:self.uid toUid:toUid messageType:4 messageText:@"" sendTime:sendTime sendStatus:@"2" byMySelf:1 hasReceive:0  picName:@"" audioName:audioName videoName:@"" picSize:@"" duration:audioDuration videoSize:@"" picUrl:@"" audioUrl:@"" videoUrl:@"" lat:@"" lon:@"" hasReadAudio:1];
    
    [self.imDB insertOrUpdateContactWithMessageId:fp fromUser:self.uid toUser:toUid messageType:4 sendTime:sendTime byMySelf:1 notReadCount:0 messageText:@""];
    
    
    for (id<IMClientManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(sendMessageWithFp:)]) {
            [delegate sendMessageWithFp:fp];
        }
    }
    
    return model;
    
}

/**
 发送位置消息 type 5
 */
-(MessageInfoModel *)sendLocationMessageWithLat:(NSString *)lat lon:(NSString *)lon detailLocationStr:(NSString *)detailLocationStr toUserId:(NSString *)toUid{
    MessageInfoModel * model = [[MessageInfoModel alloc] init];
    
    NSString * fp = [Protocal genFingerPrint];
    NSString * sendTime = [AppUtil getNowTimeTimestamp];
    NSDictionary * paraDic = @{@"content":detailLocationStr,@"time":sendTime,@"urlimg":@"",@"urlfile":@"",@"lon":lon,@"lat":lat};
    model.messageInfoId = fp;
    model.fromUser = self.uid;
    model.toUser = toUid;
    model.messageType = 5;
    model.sendTime = sendTime;
    model.byMySelf = YES;
    model.hasReceive = NO;
    model.messageText = detailLocationStr;
    model.lat = lat;
    model.lon = lon;
    model.picName = @"";
    model.audioName = @"";
    model.videoName = @"";
    model.picSize = CGSizeZero;
    model.duration = @"";
    model.videoSize = @"";
    model.picUrl = @"";
    model.audioUrl = @"";
    model.videoUrl = @"";
    
    NSString * jsonStr = [AppUtil convertToJsonStr:paraDic];
    
    int code =  [self sendMessageWithJsonStr:jsonStr toUid:toUid fp:fp WithType:5];
    if (code == COMMON_CODE_OK) {
        
        [self.imDB saveMessageInfoWithMessageInfoId:fp fromUserId:self.uid toUid:toUid messageType:5 messageText:detailLocationStr sendTime:sendTime sendStatus:@"1" byMySelf:1 hasReceive:0  picName:@"" audioName:@"" videoName:@"" picSize:@"" duration:@"" videoSize:@"" picUrl:@"" audioUrl:@"" videoUrl:@"" lat:lat lon:lon hasReadAudio:0];
        model.sendStatus = @"1";
    }else{
        [self.imDB saveMessageInfoWithMessageInfoId:fp fromUserId:self.uid toUid:toUid messageType:5 messageText:detailLocationStr sendTime:sendTime sendStatus:@"0" byMySelf:1 hasReceive:0  picName:@"" audioName:@"" videoName:@"" picSize:@"" duration:@"" videoSize:@"" picUrl:@"" audioUrl:@"" videoUrl:@"" lat:lat lon:lon hasReadAudio:0];
        model.sendStatus = @"0";
    }
    [self.imDB insertOrUpdateContactWithMessageId:fp fromUser:self.uid toUser:toUid messageType:5 sendTime:sendTime byMySelf:1 notReadCount:0 messageText:detailLocationStr];
    
    for (id<IMClientManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(sendMessageWithFp:)]) {
            [delegate sendMessageWithFp:fp];
        }
    }
    
    return model;
}


-(int)sendMessageWithJsonStr:(NSString *)jsonStr toUid:(NSString *)toUid fp:(NSString *)fp  WithType:(int)typeU{

    int code = [[LocalUDPDataSender sharedInstance] sendCommonDataWithStr:jsonStr toUserId:toUid qos:YES fp:fp withTypeu:typeU];
    
    return code;
}


@end
