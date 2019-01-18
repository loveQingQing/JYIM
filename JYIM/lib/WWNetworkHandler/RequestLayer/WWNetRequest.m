//
//  WWNetRequest.m
//  WWNetworkHelper
//
//  Created by swift on 2017/7/28.
//  Copyright © 2017年 王家伟. All rights reserved.
//

#import "WWNetRequest.h"
#import "WWInterfaceConst.h"
#import "WWNetworkHelper.h"

@implementation WWNetRequest

#pragma mark - 请求方法：可以在其它界面直接调用，解除其它界面复杂的网络解析操作。一行代码完成请求即可
/*****************************文件上传************************************/
/** 上传图片或语音 */
+ (NSURLSessionTask *)uploadImageOrAudioWithFilePath:(NSString *)filePath progress:(WWHttpProgress)progress success:(WWRequestSuccess)success failure:(WWRequestFailure)failure{
     NSString *url = [NSString stringWithFormat:@"%@%@", kApiPrefix, kUploadImageOrAudio];
    return [self uploadFileWithURL:url parameters:@{} name:@"file" filePath:filePath progress:progress success:success failure:failure];
}


/** 上传视频 */
+ (NSURLSessionTask *)uploadVideoWithFilePath:(NSString *)filePath progress:(WWHttpProgress)progress success:(WWRequestSuccess)success failure:(WWRequestFailure)failure{
    NSString *url = [NSString stringWithFormat:@"%@%@", kApiPrefix, kUpLoadVideo];
    return [self uploadFileWithURL:url parameters:@{} name:@"file" filePath:filePath progress:progress success:success failure:failure];
}

/********************************基础方法************************************/
/*
 配置好WWNetworkHelper各项请求参数,封装成一个公共方法,给以上方法调用,
 相比在项目中单个分散的使用WWNetworkHelper/其他网络框架请求,可大大降低耦合度,方便维护
 在项目的后期, 你可以在公共请求方法内任意更换其他的网络请求工具,切换成本小
 */

#pragma mark - 请求的公共方法

+ (NSURLSessionTask *)postRequestWithURL:(NSString *)URL parameters:(NSDictionary *)parameter success:(WWRequestSuccess)success failure:(WWRequestFailure)failure
{
    // 在请求之前你可以统一配置你请求的相关参数 ,设置请求头, 请求参数的格式, 返回数据的格式....这样你就不需要每次请求都要设置一遍相关参数
    [WWNetworkHelper setRequestTimeoutInterval:20.0];
    

    // 发起请求
    return [WWNetworkHelper POST:URL parameters:parameter success:^(id responseObject) {
        
        // 在这里你可以根据项目自定义其他一些重复操作,比如加载页面时候的等待效果, 提醒弹窗....
        success(responseObject);
        
    } failure:^(NSError *error) {
        // 同上
        
        failure(error);
    }];
}

/**
 *  上传文件
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param name       文件对应服务器上的字段
 *  @param filePath   文件本地的沙盒路径
 *  @param progres   上传进度信息
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                                      parameters:(id)parameters
                                            name:(NSString *)name
                                        filePath:(NSString *)filePath
                                        progress:(WWHttpProgress)progres
                                         success:(WWHttpRequestSuccess)success
                                         failure:(WWHttpRequestFailed)failure{
    [WWNetworkHelper setRequestTimeoutInterval:20.0];
    
    
    // 发起请求
    return [WWNetworkHelper uploadFileWithURL:URL parameters:parameters name:name filePath:filePath progress:^(NSProgress *progress) {
        progres(progress);
    } success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/**
 *  上传单/多张图片
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param name       图片对应服务器上的字段
 *  @param images     图片数组
 *  @param fileNames  图片文件名数组, 可以为nil, 数组内的文件名默认为当前日期时间"yyyyMMddHHmmss"
 *  @param imageScale 图片文件压缩比 范围 (0.f ~ 1.f)
 *  @param imageType  图片文件的类型,例:png、jpg(默认类型)....
 *  @param progres   上传进度信息
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)uploadImagesWithURL:(NSString *)URL
                                        parameters:(id)parameters
                                              name:(NSString *)name
                                            images:(NSArray<UIImage *> *)images
                                         fileNames:(NSArray<NSString *> *)fileNames
                                        imageScale:(CGFloat)imageScale
                                         imageType:(NSString *)imageType
                                          progress:(WWHttpProgress)progres
                                           success:(WWHttpRequestSuccess)success
                                           failure:(WWHttpRequestFailed)failure{
    
    [WWNetworkHelper setRequestTimeoutInterval:20.0];
    
    
    // 发起请求
    return [WWNetworkHelper uploadImagesWithURL:URL parameters:parameters name:name images:images fileNames:fileNames imageScale:imageScale imageType:imageType progress:^(NSProgress *progress) {
        progres(progress);
    } success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSError *error) {
         failure(error);
    }];
}

@end
