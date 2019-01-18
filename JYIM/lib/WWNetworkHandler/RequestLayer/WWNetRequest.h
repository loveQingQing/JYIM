//
//  WWNetRequest.h
//  WWNetworkHelper
//
//  Created by swift on 2017/7/28.
//  Copyright © 2017年 王家伟. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 以下Block的参数你根据自己项目中的需求来指定, 这里仅仅是一个演示的例子
 */

/**
 请求成功的block
 
 @param response 响应体数据
 */
typedef void(^WWRequestSuccess)(id response);

/**
 上传进度的block
 
 @param progress 进度
 */
typedef void (^WWHttpProgress)(NSProgress *progress);

/**
 请求失败的block
 
 @param error 失败信息
 */
typedef void(^WWRequestFailure)(NSError *error);


/**
 网络请求业务处理层次
 */
@interface WWNetRequest : NSObject

/*****************************文件上传************************************/
/** 上传图片或语音 */
+ (NSURLSessionTask *)uploadImageOrAudioWithFilePath:(NSString *)filePath progress:(WWHttpProgress)progress success:(WWRequestSuccess)success failure:(WWRequestFailure)failure;


/** 上传视频 */
+ (NSURLSessionTask *)uploadVideoWithFilePath:(NSString *)filePath progress:(WWHttpProgress)progress success:(WWRequestSuccess)success failure:(WWRequestFailure)failure;



@end

