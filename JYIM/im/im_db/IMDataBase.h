//
//  IMDataBase.h
//  JYIM
//
//  Created by jy on 2019/1/7.
//  Copyright © 2019年 jy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MessageInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface IMDataBase : NSObject

-(instancetype)initWithUid:(NSString *)uid;

//保存消息
-(void)saveMessageInfoWithMessageInfoId:(NSString *)messageInfoId fromUserId:(NSString *)fromUid toUid:(NSString *)toUid messageType:(NSInteger)messageType messageText:(NSString *)messageText sendTime:(NSString *)sendTime sendStatus:(NSString *)sendStatus byMySelf:(NSInteger)byMySelf hasReceive:(NSInteger)hasReceive picName:(NSString *)picName audioName:(NSString *)audioName videoName:(NSString *)videoName picSize:(NSString *)picSize duration:(NSString *)duration videoSize:(NSString *)videoSize picUrl:(NSString *)picUrl audioUrl:(NSString *)audioUrl videoUrl:(NSString *)videoUrl lat:(NSString *)lat lon:(NSString *)lon hasReadAudio:(NSInteger)hasReadAudio;

//更新消息
-(BOOL)updateMessageInfoWithMessageInfoId:(NSString *)messageInfoId sendStatus:(NSString *)sendStatus picUrl:(NSString *)picUrl audioUrl:(NSString *)audioUrl videoUrl:(NSString *)videoUrl hasReadAudio:(NSInteger)hasReadAudio;

//查询和某人的聊天记录
-(NSMutableArray *)queryMessageInfoWithUserId:(NSString *)uid fromLastMessageId:(NSString *)lastMessageId limitNum:(int)limit;

//批量更改已送达状态0->1（服务器与目标用户之间）
-(BOOL)updateMessageInfoReceiveStatusWithMessageIdsArr:(NSArray<NSString*>*)messageIdsArr;

//批量更改发送状态(本地与服务器之间)
-(BOOL)updateMessageInfoSendStatusWithMessageIdsArr:(NSArray<NSString*>*)messageIdsArr sendStatus:(NSString *)sendStatus;

//通过theFingerPrint(指纹)查找消息
-(MessageInfoModel *)queryMessageInfoModelWithMessageInfoId:(NSString *)messageId;

//更改收到的语音消息为已读状态
-(BOOL)updateAudioMessageInfoReadStatusWithMessageId:(NSString*)messageId;

//查询最近联系人聊天列表
-(NSMutableArray *)queryMessageList;

//插入或更新某条联系人数据
-(BOOL)insertOrUpdateContactWithMessageId:(NSString *)messageInfoId fromUser:(NSString *)fromUser toUser:(NSString *)toUser messageType:(NSInteger)messageType sendTime:(NSString *)sendTime byMySelf:(NSInteger)byMyself notReadCount:(NSInteger)notReadCount messageText:(NSString *)messageText;

//未读数清零
-(BOOL)updateMessageListModelHasReadByMyselfWithUserId:(NSString*)uid;


@end

NS_ASSUME_NONNULL_END
