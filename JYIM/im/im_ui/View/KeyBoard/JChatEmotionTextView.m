//
//  JChatEmotionTextView.m
//  JYIM
//
//  Created by jy on 2019/1/21.
//  Copyright © 2019年 jy. All rights reserved.
//

#import "JChatEmotionTextView.h"
#import "EmotionTextAttachment.h"
#import "YYImage.h"

@implementation JChatEmotionTextView

#pragma mark - override

- (void)cut:(id)sender
{
    __block NSString * cutString = @"";
    [self.attributedText enumerateAttributesInRange:self.selectedRange options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        if (attrs[@"NSAttachment"]) {//图片替换成对应的文字
            EmotionTextAttachment *textAttachment = attrs[@"NSAttachment"];
            if (textAttachment.emotionName) {
                cutString = [cutString stringByAppendingString:textAttachment.emotionName];
            }
        } else {//文字或者表情
            NSString *subString = [self.text substringWithRange:range];
            cutString = [cutString stringByAppendingString:subString];
        }
    }];
    
    if (cutString.length) {
        [UIPasteboard generalPasteboard].string = cutString;
        
        NSRange selectedRange = self.selectedRange;
        NSMutableAttributedString *attributeContent = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        [attributeContent replaceCharactersInRange:self.selectedRange withString:@""];
        self.attributedText = attributeContent;
        self.selectedRange = NSMakeRange(selectedRange.location, 0);
        
    }
}

- (void)copy:(id)sender
{
    __block NSString * copyString = @"";
    [self.attributedText enumerateAttributesInRange:self.selectedRange options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        if (attrs[@"NSAttachment"]) {//图片替换成对应的文字
            EmotionTextAttachment *textAttachment = attrs[@"NSAttachment"];
            if (textAttachment.emotionName) {
                copyString = [copyString stringByAppendingString:textAttachment.emotionName];
            }
        } else {//文字或者表情
            NSString *subString = [self.text substringWithRange:range];
            copyString = [copyString stringByAppendingString:subString];
        }
    }];
    
    if (copyString.length) {
        [UIPasteboard generalPasteboard].string = copyString;
    }
}

- (void)paste:(id)sender
{
    NSString *string = UIPasteboard.generalPasteboard.string;
    if (string.length) {
        
        NSMutableAttributedString * mAttributedString = [[NSMutableAttributedString alloc] init];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:4];//调整行间距
        [paragraphStyle setParagraphSpacing:4];//调整行间距
        
        NSDictionary *attri = [NSDictionary dictionaryWithObjects:@[[UIFont systemFontOfSize:14], [UIColor blackColor] ,paragraphStyle] forKeys:@[NSFontAttributeName,NSForegroundColorAttributeName,NSParagraphStyleAttributeName]];
        [mAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:string attributes:attri]];
        
        CGFloat fontHeight = [UIFont systemFontOfSize:14].lineHeight;
        
        //创建匹配正则表达式的类型描述模板
        NSString * pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        //创建匹配对象
        NSError * error;
        NSRegularExpression * regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        //判断
        if (!regularExpression) {
            //如果匹配规则对象为nil
            NSLog(@"正则创建失败！");
            NSLog(@"error = %@",[error localizedDescription]);
            
        } else {
            NSArray * resultArray = [regularExpression matchesInString:mAttributedString.string options:NSMatchingReportCompletion range:NSMakeRange(0, mAttributedString.string.length)];
            
            NSInteger index = resultArray.count;
            while (index > 0) {
                index --;
                NSTextCheckingResult *result = resultArray[index];
                //根据range获取字符串
                NSString * rangeString = [mAttributedString.string substringWithRange:result.range];
                NSLog(@"rangge is %@",rangeString);
                
                
                NSString *imageName = rangeString;
                if (imageName) {
                    //获取图片
                    UIImage * theImage = [UIImage imageNamed:imageName];
                    YYImage *image = [[YYImage alloc] initWithData:UIImagePNGRepresentation(theImage)];
                    image.preloadAllAnimatedImageFrames = YES;
                    if (image != nil) {
                        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
                        imageView.width = fontHeight;
                        imageView.height = fontHeight;
                        
                        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.size alignToFont:[UIFont systemFontOfSize:14] alignment:YYTextVerticalAlignmentCenter];
                        //开始替换
                        [mAttributedString replaceCharactersInRange:result.range withAttributedString:attachText];
                    }
                }
            }
        }
        
        
        
        NSRange selectedRange = self.selectedRange;
        
        NSMutableAttributedString *attributeContent = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        [attributeContent replaceCharactersInRange:self.selectedRange withAttributedString:mAttributedString];
        self.attributedText = attributeContent;
        self.selectedRange = NSMakeRange(selectedRange.location + mAttributedString.length, 0);
        
    }
}


@end
