//
//  AppUtil.h
//  HouseLoan
//
//  Created by wb on 2017/11/9.
//  Copyright © 2017年 wb. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppUtil : NSObject

@property float autoSizeScaleX;
@property float autoSizeScaleY;

@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) BOOL hasNotch;//是否有齐刘海


+ (AppUtil *)shareInstance;

//十六进制颜色设置
+ (UIColor *)getColorFromHexadecimalValue:(NSString *)hexadecimalValue alpha:(CGFloat)alpha;


/**
 判断密码是否只为字母和数组
 */
+(BOOL)isPassWOrdAvailable:(NSString*)passWord;


//邮箱正则
+ (BOOL) validateEmail:(NSString *)email;


//多行字号高度
+ (CGFloat)heightWithMaxSize:(CGSize)maxSize text:(NSString *)text font:(CGFloat)fontSize;
/** 横向文本宽度计算 */
+ (CGFloat)widthForString:(NSString *)content font:(UIFont *)font;

+(NSString*)getCurrentTimes;
+(NSString*)getCurrentTimesDetail;
/** 时间转换为时间戳 */
+ (NSString *)getTimestampFromTime:(NSString *)time;

//是否是纯数字
+ (BOOL)isNumText:(NSString *)str;

//还有获取当前时间戳
+(NSString *)getNowTimeTimestamp;

//json字符串转为字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

// 字典转json字符串方法
+(NSString *)convertToJsonStr:(NSDictionary *)dict;

@end
