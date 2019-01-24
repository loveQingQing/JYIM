//
//  WWInterfaceConst.m
//  WWNetworkHelper
//
//  Created by swift on 2017/7/28.
//  Copyright © 2017年 王家伟. All rights reserved.
//

#import "WWInterfaceConst.h"

/* ---  服务器使用判断  --- */
#if DevelopSever
/** 接口前缀-开发服务器*/
NSString *const kApiPrefix = @"http://192.168.0.182/";

#elif ProductSever
/** 接口前缀-生产服务器*/
NSString *const kApiPrefix = @"http://58.58.115.2:8888/";

#endif


/* ---  二级接口定义  --- */
/*****************************文件上传************************************/
/** 上传图片或语音 */
NSString *const kUploadImageOrAudio = @"junyangIm/Im/imgupload";



/** 上传视频 */
NSString *const kUpLoadVideo = @"junyangIm/Im/videoupload";







