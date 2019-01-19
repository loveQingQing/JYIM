
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
//  IMClientManager.h
//  MibileIMSDK4iDemo_X (A demo for MobileIMSDK v3.0 at Summer 2017)


#import <Foundation/Foundation.h>
#import "MessageInfoModel.h"

@protocol IMClientManagerDelegate <NSObject>

@optional

/*
 * 主动登请求返回的响应
 */
-(void)LoginActionRequestResultWithCode:(int)code;



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
- (void) onLinkCloseMessage:(int)dwErrorCode;



/*!
 * 收到普通消息的回调事件通知。
 * <br>
 * 应用层可以将此消息进一步按自已的IM协议进行定义，从而实现完整的即时通信软件逻辑。
 *
 * @param fingerPrintOfProtocal 当该消息需要QoS支持时本回调参数为该消息的特征指纹码，否则为null
 * @param userid 消息的发送者id（RainbowCore框架中规定发送者id=“0”即表示是由服务端主动发过的，否则表示的是其它客户端发过来的消息）
 * @param dataContent 消息内容的文本表示形式
 */
- (void) onTransBuffer:(NSString *)fingerPrintOfProtocal withUserId:(NSString *)dwUserid andContent:(NSString *)dataContent andTypeu:(int)typeu;


/*!
 * 服务端反馈的出错信息回调事件通知。
 *
 * @param errorCode 错误码，定义在常量表 ErrorCode 中有关服务端错误码的定义
 * @param errorMsg 描述错误内容的文本信息
 * @see ErrorCode
 */
- (void) onErrorResponse:(int)errorCode withErrorMsg:(NSString *)errorMsg;




/*!
 * 消息未送达的回调事件通知.
 *
 * @param lostMessages 由MobileIMSDK QoS算法判定出来的未送达消息列表（此列表
 * 中的Protocal对象是原对象的clone（即原对象的深拷贝），请放心使用哦），应用层
 * 可通过指纹特征码找到原消息并可以UI上将其标记为”发送失败“以便即时告之用户
 */
- (void) messagesLost:(NSMutableArray*)lostMessages;


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
- (void) messagesBeReceived:(NSString *)theFingerPrint;

/**
 发送消息事件通知
*/
- (void)sendMessageWithFp:(NSString *)theFingerPrint;

@end

@interface IMClientManager : NSObject

/**
 数据库类
 */
@property (nonatomic, strong) IMDataBase * imDB;
@property (nonatomic, copy) NSString * uid;

//在聊天界面
@property (nonatomic, copy) NSString * inChatRoomWithUid;

/*!
 * 取得本类实例的唯一公开方法。
 * <p>
 * 本类目前在APP运行中是以单例的形式存活，请一定注意这一点哦。
 *
 * @return
 */
+ (IMClientManager *)sharedInstance;

- (void)initMobileIMSDK;

- (void)releaseMobileIMSDK;


/**
 * 重置init标识。
 * <p>
 * <b>重要说明：</b>不退出APP的情况下，重新登陆时记得调用一下本方法，不然再
 * 次调用 {@link #initMobileIMSDK()} 时也不会重新初始化MobileIMSDK（
 * 详见 {@link #initMobileIMSDK()}代码）而报 code=203错误！
 *
 */
- (void)resetInitFlag;


/*
 * 主动的登陆信息发送实现方法。
 */
- (void)doLoginWithUid:(NSString *)uid withToken:(NSString *)loginTokenStr;


//添加代理
- (void)addDelegate:(id<IMClientManagerDelegate>)delegate;
//移除代理
- (void)removeDelegate:(id<IMClientManagerDelegate>)delegate;


/**
 发送文本消息
 */
-(MessageInfoModel *)sendTextMessageWithStr:(NSString *)str toUserId:(NSString *)toUid;

/**
 发送图片消息
 */
-(MessageInfoModel *)sendImageMessageWithImageData:(NSData *)imgData toUserId:(NSString *)toUid picSize:(CGSize)picSize;

/**
 发送视频消息
 */
-(MessageInfoModel *)sendVideoMessageWithCoverImageData:(NSData *)imgData  videoName:(NSString *)videoName  toUserId:(NSString *)toUid;

/**
 发送语音消息
 */
-(MessageInfoModel *)sendVoiceMessageWithAudioData:(NSData*)audioData audioDuration:(NSString *)audioDuration toUserId:(NSString *)toUid;

/**
 发送位置消息
 */
-(MessageInfoModel *)sendLocationMessageWithLat:(NSString *)lat lon:(NSString *)lon detailLocationStr:(NSString *)detailLocationStr toUserId:(NSString *)toUid;

-(int)sendMessageWithJsonStr:(NSString *)jsonStr toUid:(NSString *)toUid fp:(NSString *)fp  WithType:(int)typeU;

@end
