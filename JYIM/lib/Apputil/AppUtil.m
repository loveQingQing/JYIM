//
//  AppUtil.m
//  HouseLoan
//
//  Created by wb on 2017/11/9.
//  Copyright © 2017年 wb. All rights reserved.
//

#import "AppUtil.h"

@implementation AppUtil

+ (AppUtil *)shareInstance
{
    static AppUtil *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AppUtil alloc] init];
        CGFloat thewidth = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        CGFloat theheight = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        if (theheight != 667) {
            instance.autoSizeScaleX = thewidth/375.0;//分母:为当前UI参照设备的宽
            instance.autoSizeScaleY = theheight/667.0;//分母:为当前UI参照设备的高
        }
        else if (theheight == 667)
        {
            instance.autoSizeScaleX = 1;
            instance.autoSizeScaleY = 1;
        }
        else if (theheight <= 568)
        {
            //3.5寸屏和4寸屏
            instance.autoSizeScaleX = 320/375.0;
            instance.autoSizeScaleY = 568/667.0;
        }
        instance.hasNotch = (theheight == 812.0f || theheight == 896.0f);
        instance.screenWidth = thewidth;
        instance.screenHeight = theheight;
        
    });
    return instance;
}


//十六进制颜色设置
+ (UIColor *)getColorFromHexadecimalValue:(NSString *)hexadecimalValue alpha:(CGFloat)alpha
{
    NSRange range;
    
    NSInteger colorR_one = 0;
    NSInteger colorR_two = 0;
    NSInteger colorG_one = 0;
    NSInteger colorG_two = 0;
    NSInteger colorB_one = 0;
    NSInteger colorB_two = 0;
    
    for (int i=0; i<6; i++) {
        range = NSMakeRange(i, 1);
        NSString *temp = [hexadecimalValue substringWithRange:range];
        switch (i) {
            case 0:
                colorR_one = [self decimalFromHexadecimalNumber:temp];
                break;
            case 1:
                colorR_two = [self decimalFromHexadecimalNumber:temp];
                break;
            case 2:
                colorG_one = [self decimalFromHexadecimalNumber:temp];
                break;
            case 3:
                colorG_two = [self decimalFromHexadecimalNumber:temp];
                break;
            case 4:
                colorB_one = [self decimalFromHexadecimalNumber:temp];
                break;
            case 5:
                colorB_two = [self decimalFromHexadecimalNumber:temp];
                break;
        }
    }
    CGFloat colorR = colorR_one * 16.0 + colorR_two;
    CGFloat colorG = colorG_one * 16.0 + colorG_two;
    CGFloat colorB = colorB_one * 16.0 + colorB_two;
    UIColor *resultColor = [UIColor colorWithRed:(colorR/255.0) green:(colorG/255.0) blue:(colorB/255.0) alpha:alpha];
    return resultColor;
}
+ (NSInteger)decimalFromHexadecimalNumber:(NSString *)hexadecimalNumber
{
    if ([hexadecimalNumber isEqualToString:@"a"] || [hexadecimalNumber isEqualToString:@"A"])
    {
        return 10;
    }
    if ([hexadecimalNumber isEqualToString:@"b"] || [hexadecimalNumber isEqualToString:@"B"])
    {
        return 11;
    }
    if ([hexadecimalNumber isEqualToString:@"c"] || [hexadecimalNumber isEqualToString:@"C"])
    {
        return 12;
    }
    if ([hexadecimalNumber isEqualToString:@"d"] || [hexadecimalNumber isEqualToString:@"D"])
    {
        return 13;
    }
    if ([hexadecimalNumber isEqualToString:@"e"] || [hexadecimalNumber isEqualToString:@"E"])
    {
        return 14;
    }
    if ([hexadecimalNumber isEqualToString:@"f"] || [hexadecimalNumber isEqualToString:@"F"])
    {
        return 15;
    }
    else
    {
        return [hexadecimalNumber integerValue];
    }
}


/**
 判断字符串是否为空
 */
+ (BOOL)isEmptyString:(NSString *)string
{
    string = [NSString stringWithFormat:@"%@",string];
    if (string == nil) {
        return YES;
    }
    if ([string isEqualToString:@""] == YES) {
        return YES;
    }
    if ([string isEqualToString:@"(null)"] == YES) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]] == YES) {
        return YES;
    }
    return NO;
}



/**
 判断密码是否只为字母和数组
 */
+(BOOL)isPassWOrdAvailable:(NSString*)passWord{
    NSString * str = @"^[A-Za-z0-9]+$";
    NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",str];
    if (![regexTest evaluateWithObject:passWord]) {
        return NO;
    }
    return YES;
    
}

//邮箱正则
+ (BOOL) validateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


//多行字号高度
+ (CGFloat)heightWithMaxSize:(CGSize)maxSize text:(NSString *)text font:(CGFloat)fontSize{
    CGSize textSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;
    return textSize.height;
}

+ (CGFloat)widthForString:(NSString *)content font:(UIFont *)font {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, font.pointSize + 4)];
    label.numberOfLines = 1;
    label.font = font;
    label.text = content;
    CGSize size = [label sizeThatFits:CGSizeMake(500, font.pointSize + 4)];
    return size.width;
}

+(NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    
    [formatter setDateFormat:@"yyyy-MM-dd"];

    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
   
    
    return currentTimeString;
    
}

+(NSString*)getCurrentTimesDetail {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    
    return currentTimeString;
}

#pragma mark --- 将时间转换成时间戳
+ (NSString *)getTimestampFromTime:(NSString *)time{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/BeiJing"];
    [formatter setTimeZone:timeZone];
    NSDate *date = [formatter dateFromString:time];
    // 时间转时间戳的方法:
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    return timeSp;
}

//是否是纯数字
+ (BOOL)isNumText:(NSString *)str{
    if (str.length == 0)
        return NO;
    NSString *regex =@"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:str];
  
}

//获取当前时间戳
+(NSString *)getNowTimeTimestamp{
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval a=[dat timeIntervalSince1970];
    
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    
    return timeString;
    
}

//json字符串转为字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

// 字典转json字符串方法
+(NSString *)convertToJsonStr:(NSDictionary *)dict

{
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        return nil;
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}
@end
