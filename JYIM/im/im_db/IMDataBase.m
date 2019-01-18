//
//  IMDataBase.m
//  JYIM
//
//  Created by jy on 2019/1/7.
//  Copyright © 2019年 jy. All rights reserved.
//  https://blog.csdn.net/qishiai819/article/details/51394303

#import "IMDataBase.h"
#import <sqlite3.h>
#import "FMDB.h"
#import "MessageInfoModel.h"
#import "MessageListModel.h"


@interface IMDataBase ()


@end

@implementation IMDataBase
static FMDatabaseQueue *queue;

-(instancetype)initWithUid:(NSString *)uid{
    self = [super init];
    if (self) {
        // 0.获得沙盒中的数据库文件名
        NSString *filename = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",uid]];
        NSLog(@"FMDBpath: %@",filename);
        // 1.创建数据库队列
        queue = [FMDatabaseQueue databaseQueueWithPath:filename];
        
        // 2.创建消息表
        [queue inDatabase:^(FMDatabase *dealDB) {
            
            //创建聊天消息表
            NSString * sqlMessageInfoStr = @"create table if not exists MessageInfo (id integer PRIMARY KEY AUTOINCREMENT,messageInfoId text,fromUser text,toUser text, messageType integer,messageText text,sendTime text,sendStatus text,byMySelf integer,hasReceive integer,picName text,audioName text,videoName text,picSize text,duration text,videoSize text,picUrl text,audioUrl text,videoUrl text,lat text,lon text,hasReadAudio integer);";
            if(![dealDB executeUpdate:sqlMessageInfoStr])
            {
                NSLog(@"聊天消息表创建失败");
            } else {
                NSLog(@"聊天消息表创建成功");
            }
            
            //创建最近聊天列表
            NSString * sqlMessageListStr = @"create table if not exists MessageList (id integer primary key autoincrement, messageText text,notReadCount integer, byMySelf integer,sendTime text,messageType integer,toUser text,fromUser text,messageInfoId text);";
            if(![dealDB executeUpdate:sqlMessageListStr])
            {
                NSLog(@"最近聊天列表创建失败");
            } else {
                NSLog(@"最近聊天列表创建成功");
            }
            
        }];
    }
    
    return self;
    
    
}

//保存消息
-(void)saveMessageInfoWithMessageInfoId:(NSString *)messageInfoId fromUserId:(NSString *)fromUid toUid:(NSString *)toUid messageType:(NSInteger)messageType messageText:(NSString *)messageText sendTime:(NSString *)sendTime sendStatus:(NSString *)sendStatus byMySelf:(NSInteger)byMySelf hasReceive:(NSInteger)hasReceive picName:(NSString *)picName audioName:(NSString *)audioName videoName:(NSString *)videoName picSize:(NSString *)picSize duration:(NSString *)duration videoSize:(NSString *)videoSize picUrl:(NSString *)picUrl audioUrl:(NSString *)audioUrl videoUrl:(NSString *)videoUrl lat:(NSString *)lat lon:(NSString *)lon hasReadAudio:(NSInteger)hasReadAudio{
    
    NSString *sql=[NSString stringWithFormat:@"INSERT INTO MessageInfo (messageInfoId,fromUser,toUser, messageType,messageText,sendTime,sendStatus,byMySelf,hasReceive,picName,audioName,videoName,picSize,duration,videoSize,picUrl,audioUrl,videoUrl,lat,lon,hasReadAudio) VALUES('%@','%@','%@','%ld','%@','%@','%@','%ld','%ld','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%ld')",messageInfoId,fromUid, toUid,messageType,messageText,sendTime,sendStatus,byMySelf,hasReceive,picName,audioName,videoName,picSize,duration,videoSize,picUrl,audioUrl,videoUrl,lat,lon,hasReadAudio];
    [queue inDatabase:^(FMDatabase *dealDB) {
        
        if (![dealDB executeUpdate:sql])
        {
            NSLog(@"消息model添加失败!");
            
        }
        
    }];
}

//更新消息
-(BOOL)updateMessageInfoWithMessageInfoId:(NSString *)messageInfoId sendStatus:(NSString *)sendStatus picUrl:(NSString *)picUrl audioUrl:(NSString *)audioUrl videoUrl:(NSString *)videoUrl hasReadAudio:(NSInteger)hasReadAudio{
    
    __block BOOL isSuccess = NO;
    [queue inDatabase:^(FMDatabase *dealDB) {
        
        NSString * sqlStr = [NSString stringWithFormat:@"update MessageInfo set sendStatus = '%@', picUrl = '%@', audioUrl = '%@',videoUrl = '%@',hasReadAudio = '%ld' where messageInfoId = '%@';",sendStatus,picUrl,audioUrl,videoUrl,hasReadAudio,messageInfoId];
        
        BOOL success = [dealDB executeUpdate:sqlStr];
        
        if(success){
            
            isSuccess = YES;
            
        }else{
            
            isSuccess = NO;
        }
        
    }];
    return isSuccess;
}
//查询和某人的聊天记录
-(NSMutableArray *)queryMessageInfoWithUserId:(NSString *)uid fromLastMessageId:(NSString *)lastMessageId limitNum:(int)limit{
    int theLimit = 20;
    if (limit > 0) {
        theLimit = limit;
    }
    NSMutableArray * modelArr = [NSMutableArray array];
    [queue inDatabase:^(FMDatabase *dealDB) {
        NSString * sql = [NSString string];
       
        if ([lastMessageId isEqualToString:@"-1"]) {
            sql = [NSString stringWithFormat:@"SELECT * FROM (select * from MessageInfo where fromUser = '%@' or toUser = '%@' order by id desc limit %d)aa ORDER BY id",uid,uid,limit];
        }else{
            sql = [NSString stringWithFormat:@"SELECT * FROM (select * from MessageInfo where (id < %@ and fromUser = '%@') or ( id < %@ and toUser = '%@') order by id desc limit %d)aa ORDER BY id",lastMessageId,uid,lastMessageId,uid,theLimit];
        }
        
        // 1.查询数据
        FMResultSet *rs = [dealDB executeQuery:sql];
       
        while ([rs next]) {
            MessageInfoModel * model = [[MessageInfoModel alloc]init];
            model.sendTime = [rs stringForColumn:@"sendTime"];
            model.theId = [rs stringForColumn:@"id"];
            model.messageInfoId = [rs stringForColumn:@"messageInfoId"];
            model.fromUser = [rs stringForColumn:@"fromUser"];
            model.toUser = [rs stringForColumn:@"toUser"];
            model.messageType = [[rs stringForColumn:@"messageType"] integerValue];
            model.messageText = [rs stringForColumn:@"messageText"];
            model.sendStatus = [rs stringForColumn:@"sendStatus"];
            model.byMySelf = [[rs stringForColumn:@"byMySelf"] boolValue];
            model.hasReceive = [[rs stringForColumn:@"hasReceive"] boolValue];
            model.picName = [rs stringForColumn:@"picName"];
            model.audioName = [rs stringForColumn:@"audioName"];
            model.videoName = [rs stringForColumn:@"videoName"];
            model.picSize = CGSizeFromString([rs stringForColumn:@"picSize"]);
            model.duration = [rs stringForColumn:@"duration"];
            model.videoSize = [rs stringForColumn:@"videoSize"];
            model.picUrl = [rs stringForColumn:@"picUrl"];
            model.audioUrl = [rs stringForColumn:@"audioUrl"];
            model.videoUrl = [rs stringForColumn:@"videoUrl"];
            model.lat = [rs stringForColumn:@"lat"];
            model.lon = [rs stringForColumn:@"lon"];
            model.hasReadAudio = [[rs stringForColumn:@"hasReadAudio"] integerValue];
            
            [modelArr addObject:model];
        }
        
        [rs close];
    }];
    return modelArr;
}

//批量更改已送达状态
-(BOOL)updateMessageInfoReceiveStatusWithMessageIdsArr:(NSArray<NSString*>*)messageIdsArr{
   __block BOOL res = YES;
    [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback)  {
        
        for (int i = 0; i<[messageIdsArr count]; i++) {
            
            NSString * messageId = [messageIdsArr objectAtIndex:i];
            NSString * update = [NSString stringWithFormat:@"update MessageInfo set hasReceive = %d where messageInfoId = '%@'",1,messageId];
            BOOL isSuccess = [db executeUpdate:update];
            
            if (!isSuccess) {
                NSLog(@"已送达状态更新失败");
                res = NO;
                *rollback = YES;
                return;
            }
        }
        
    }];
    return res;
}

//更改收到的语音消息为已读状态
-(BOOL)updateAudioMessageInfoReadStatusWithMessageId:(NSString*)messageId{
    __block BOOL isSuccess = NO;
    [queue inDatabase:^(FMDatabase *dealDB) {
        
        NSString * sqlStr = [NSString stringWithFormat:@"update MessageInfo set hasReadAudio = %d where messageInfoId = '%@'",1,messageId];
        
        BOOL success = [dealDB executeUpdate:sqlStr];
        
        if(success){
            
            isSuccess = YES;
            
        }else{
            
            isSuccess = NO;
        }
        
        
    }];
    return isSuccess;
}


//批量更改发送状态
-(BOOL)updateMessageInfoSendStatusWithMessageIdsArr:(NSArray<NSString*>*)messageIdsArr sendStatus:(NSString *)sendStatus{
    __block BOOL res = YES;
    [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback)  {
        
        for (int i = 0; i<[messageIdsArr count]; i++) {
            
            NSString * messageId = [messageIdsArr objectAtIndex:i];
            NSString * update = [NSString stringWithFormat:@"update MessageInfo set sendStatus = '%@' where messageInfoId = '%@'",sendStatus,messageId];
            BOOL isSuccess = [db executeUpdate:update];
            
            if (!isSuccess) {
                NSLog(@"发送状态更新失败");
                res = NO;
                *rollback = YES;
                return;
            }
        }
        
    }];
    return res;
}

//通过theFingerPrint(指纹)查找消息
-(MessageInfoModel *)queryMessageInfoModelWithMessageInfoId:(NSString *)messageId{
    __block MessageInfoModel * model = [[MessageInfoModel alloc]init];
    [queue inDatabase:^(FMDatabase *dealDB) {
       
        NSString * sql = [NSString stringWithFormat:@"select * from MessageInfo where messageInfoId = '%@' ",messageId];
        
        // 1.查询数据
        FMResultSet *rs = [dealDB executeQuery:sql];
        while ([rs next]) {
            model.theId = [rs stringForColumn:@"id"];
            model.messageInfoId = [rs stringForColumn:@"messageInfoId"];
            model.fromUser = [rs stringForColumn:@"fromUser"];
            model.toUser = [rs stringForColumn:@"toUser"];
            model.messageType = [[rs stringForColumn:@"messageType"] integerValue];
            model.messageText = [rs stringForColumn:@"messageText"];
            model.sendTime = [rs stringForColumn:@"sendTime"];
            model.sendStatus = [rs stringForColumn:@"sendStatus"];
            model.byMySelf = [[rs stringForColumn:@"byMySelf"] boolValue];
            model.hasReceive = [[rs stringForColumn:@"hasReceive"] boolValue];
            model.picName = [rs stringForColumn:@"picName"];
            model.audioName = [rs stringForColumn:@"audioName"];
            model.videoName = [rs stringForColumn:@"videoName"];
            model.picSize = CGSizeFromString([rs stringForColumn:@"picSize"]);
            model.duration = [rs stringForColumn:@"duration"];
            model.videoSize = [rs stringForColumn:@"videoSize"];
            model.picUrl = [rs stringForColumn:@"picUrl"];
            model.audioUrl = [rs stringForColumn:@"audioUrl"];
            model.videoUrl = [rs stringForColumn:@"videoUrl"];
            model.lat = [rs stringForColumn:@"lat"];
            model.lon = [rs stringForColumn:@"lon"];
            model.hasReadAudio = [[rs stringForColumn:@"hasReadAudio"] integerValue];
        }
        
        [rs close];
    }];
    return model;
}
//查询最近联系人聊天列表
-(NSMutableArray *)queryMessageList{
    
    NSMutableArray * modelArr = [NSMutableArray array];
    [queue inDatabase:^(FMDatabase *dealDB) {
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM MessageList order by id desc;"];
        
        // 1.查询数据
        FMResultSet *rs = [dealDB executeQuery:sql];
        while ([rs next]) {
            MessageListModel * model = [[MessageListModel alloc]init];
            
            model.theId = [rs stringForColumn:@"id"];
            model.messageInfoId = [rs stringForColumn:@"messageInfoId"];
            model.fromUser = [rs stringForColumn:@"fromUser"];
            model.toUser = [rs stringForColumn:@"toUser"];
            model.messageType = [[rs stringForColumn:@"messageType"] integerValue];
            model.sendTime = [rs stringForColumn:@"sendTime"];
            model.byMySelf = [[rs stringForColumn:@"byMySelf"] boolValue];
            model.notReadCount = [[rs stringForColumn:@"notReadCount"] integerValue];
            model.messageText = [rs stringForColumn:@"messageText"];
            
            [modelArr addObject:model];
        }
        
        [rs close];
    }];
    return modelArr;
}

//查询是否存在某个最近联系人
-(NSMutableDictionary *)_existThisContactWithUid:(NSString *)contactUid{
    
    __block NSMutableDictionary * resultDic = [NSMutableDictionary dictionary];
    [queue inDatabase:^(FMDatabase *dealDB) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM MessageList WHERE fromUser = '%@' or toUser = '%@'",contactUid,contactUid];
        
        FMResultSet *aResult = [dealDB executeQuery:sql];
        
        if([aResult next]){
            NSInteger unReadCount = [[aResult stringForColumn:@"notReadCount"] integerValue];
            [resultDic addEntriesFromDictionary:@{@"exist":@(1),@"notReadCount":@(unReadCount)}];
            
        }else{
            
            [resultDic addEntriesFromDictionary:@{@"exist":@(0)}];
        }
        [aResult close];
     
    }];
    return resultDic;
}

//插入或更新某条联系人数据
-(BOOL)insertOrUpdateContactWithMessageId:(NSString *)messageInfoId fromUser:(NSString *)fromUser toUser:(NSString *)toUser messageType:(NSInteger)messageType sendTime:(NSString *)sendTime byMySelf:(NSInteger)byMyself notReadCount:(NSInteger)notReadCount messageText:(NSString *)messageText{
    NSMutableDictionary * resultDic = [self _existThisContactWithUid:([fromUser isEqualToString:[IMClientManager sharedInstance].uid]?toUser:fromUser)];
    
    if ([[resultDic objectForKey:@"exist"] boolValue]) {
        NSInteger unReadCount = [resultDic[@"notReadCount"] integerValue];
        if (notReadCount == 0) {
            return  [self _updateContactWithMessageId:messageInfoId fromUser:fromUser toUser:toUser messageType:messageType sendTime:sendTime byMySelf:byMyself notReadCount:0 messageText:messageText];
        }else{
            return  [self _updateContactWithMessageId:messageInfoId fromUser:fromUser toUser:toUser messageType:messageType sendTime:sendTime byMySelf:byMyself notReadCount:(unReadCount + 1) messageText:messageText];
        }
        
        
    }else{
        if (notReadCount == 0) {
            return [self _insertContactWithMessageId:messageInfoId fromUser:fromUser toUser:toUser messageType:messageType sendTime:sendTime byMySelf:byMyself notReadCount:0 messageText:messageText];
        }else{
            return [self _insertContactWithMessageId:messageInfoId fromUser:fromUser toUser:toUser messageType:messageType sendTime:sendTime byMySelf:byMyself notReadCount:1 messageText:messageText];
        }
        
        
    }
   
}
//更新
-(BOOL)_updateContactWithMessageId:(NSString *)messageInfoId fromUser:(NSString *)fromUser toUser:(NSString *)toUser messageType:(NSInteger)messageType sendTime:(NSString *)sendTime byMySelf:(NSInteger)byMyself notReadCount:(NSInteger)notReadCount messageText:(NSString *)messageText{
    NSString * targetUid = [fromUser isEqualToString:[IMClientManager sharedInstance].uid]?toUser:fromUser;
    __block BOOL isSuccess = NO;
    [queue inDatabase:^(FMDatabase *dealDB) {
        
        NSString * sqlStr = [NSString stringWithFormat:@"update MessageList set messageText = '%@', notReadCount = '%ld', byMySelf = '%ld',sendTime = '%@',messageType = '%ld',toUser = '%@',fromUser = '%@', messageInfoId = '%@' where fromUser = '%@' or toUser = '%@';",messageText,notReadCount,byMyself,sendTime,messageType,toUser,fromUser,messageInfoId,targetUid,targetUid];
        
        BOOL success = [dealDB executeUpdate:sqlStr];
        
        if(success){
            
            isSuccess = YES;
            
        }else{
            
            isSuccess = NO;
        }
       
    }];
    return isSuccess;
}

//更新
-(BOOL)_insertContactWithMessageId:(NSString *)messageInfoId fromUser:(NSString *)fromUser toUser:(NSString *)toUser messageType:(NSInteger)messageType sendTime:(NSString *)sendTime byMySelf:(NSInteger)byMyself notReadCount:(NSInteger)notReadCount messageText:(NSString *)messageText{

    __block BOOL isSuccess = NO;
   
    NSString *sql=[NSString stringWithFormat:@"INSERT INTO MessageList (messageText,notReadCount,byMySelf, sendTime,messageType,toUser,fromUser,messageInfoId) VALUES('%@','%ld','%ld','%@','%ld','%@','%@','%@')",messageText,notReadCount, byMyself,sendTime,messageType,toUser,fromUser,messageInfoId];
    [queue inDatabase:^(FMDatabase *dealDB) {
        
        if (![dealDB executeUpdate:sql])
        {
            NSLog(@"联系人消息列表添加失败!");
            isSuccess = NO;
        }else{
            isSuccess = YES;
            NSLog(@"联系人消息列表添加成功!");
        }
        
    }];
    return isSuccess;
}
//未读数清零
-(BOOL)updateMessageListModelHasReadByMyselfWithUserId:(NSString*)uid{
    
    __block BOOL isSuccess = NO;
    [queue inDatabase:^(FMDatabase *dealDB) {
        
        NSString * sqlStr = [NSString stringWithFormat:@"update MessageList set notReadCount = %d where fromUser = '%@' or toUser = '%@'",0,uid,uid];
        
        BOOL success = [dealDB executeUpdate:sqlStr];
        
        if(success){
            
            isSuccess = YES;
            
        }else{
            
            isSuccess = NO;
        }
        
        
    }];
    return isSuccess;
}
@end
