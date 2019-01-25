//
//  JChatAudioCellFrameModel.m
//  JYIM
//
//  Created by jy on 2019/1/14.
//  Copyright © 2019年 jy. All rights reserved.
//

#import "JChatAudioCellFrameModel.h"

@implementation JChatAudioCellFrameModel

-(void)setMessageInfoModel:(MessageInfoModel *)messageInfoModel{
    _messageInfoModel = messageInfoModel;
    
    if (_messageInfoModel.shouldShowTime) {
        UIFont * sysFont12 = [UIFont systemFontOfSize:12.0];
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.font = sysFont12;
        timeLabel.text = [NSDate timeStringWithTimeInterval:messageInfoModel.sendTime];;
        
        CGSize timeTextSize  = [timeLabel sizeThatFits:CGSizeMake(ScreenWidth, 20)];
        self.timeLabelFrame = CGRectMake(5,(20 - timeTextSize.height)*0.5, timeTextSize.width, timeTextSize.height);
        self.timeContainerFrame = CGRectMake((ScreenWidth - timeTextSize.width-10)*0.5, 15,timeTextSize.width + 10, 20);
        
    }else{
        _timeContainerFrame = CGRectZero;
        _timeLabelFrame = CGRectZero;
    }
    
    
    //计算语音长度
    CGFloat length = 0;
    CGFloat maxLength = ScreenWidth - 145;
    //默认最小值为40
    CGFloat minLength = 40;
    //秒数
    NSInteger seconds = (NSInteger)self.messageInfoModel.duration.floatValue / 1000;
    
    //1秒
    switch (seconds) {
        case 1:
            length = minLength;
            break;
            //60秒
        case 60:
            length = maxLength;
            break;
            //其他
        default:
        {
            length = 40 + (ScreenWidth - 145)/59 *seconds;
            if (length >maxLength) {   //超过60秒 还是显示60秒长度
                length = maxLength;
            }
        }
            break;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 1;
    label.font = [UIFont systemFontOfSize:12.0];
    label.text = [NSString stringWithFormat:@"%.f''",[_messageInfoModel.duration floatValue]/1000];
    [label sizeToFit];
    CGSize secondSize = label.size;
    
    //我方
    if (_messageInfoModel.byMySelf) {
        
        self.iconViewFrame = CGRectMake(ScreenWidth - 65,CGRectGetMaxY(self.timeContainerFrame)+15, 50, 50);
        self.backImageViewFrame = CGRectMake(ScreenWidth - 70-length, CGRectGetMinY(self.iconViewFrame)+5, length, 40);
        
        //下载进度
        self.downloadProgressViewFrame = CGRectZero;
        
        //动画
        self.voiceGIFViewFrame = CGRectMake(CGRectGetWidth(self.backImageViewFrame)-39, (CGRectGetHeight(self.backImageViewFrame)-24)*0.5, 24, 24);
        //红点
        self.redPointFrame = CGRectZero;
        //秒数label
        self.secondLabelFrame = CGRectMake(CGRectGetMinX(self.backImageViewFrame)-10-secondSize.width, CGRectGetMinY(self.backImageViewFrame)+14, secondSize.width, 12);
        //菊花
        self.activiViewFrame = CGRectMake(CGRectGetMinX(self.secondLabelFrame)-34, CGRectGetMinY(self.backImageViewFrame)+8, 24, 24);
        //发送失败按钮
        self.failureButtonFrame = CGRectMake(CGRectGetMinX(self.secondLabelFrame) - 8.f - 30.f, CGRectGetCenter(_activiViewFrame).y - 15.f, 30.f, 30.f);
        
        //别人语音
    }else{
        //头像
        self.iconViewFrame = CGRectMake(15, CGRectGetMaxY(self.timeContainerFrame)+15, 50, 50);
        
        //气泡
        self.backImageViewFrame = CGRectMake(CGRectGetMaxX(self.iconViewFrame)+5,CGRectGetMinY(self.iconViewFrame)+5.f, length, 40);
        
        //下载进度
        self.downloadProgressViewFrame = CGRectMake(CGRectGetMinX(_backImageViewFrame) + 3.f, CGRectGetMaxY(_backImageViewFrame)+ 1, CGRectGetWidth(_backImageViewFrame) - 3.f, 1.f);
        //语音动画
        self.voiceGIFViewFrame = CGRectMake(15, (CGRectGetHeight(self.backImageViewFrame)-24)*0.5, 24, 24);

        //红点
        self.redPointFrame = CGRectMake(CGRectGetMaxX(self.backImageViewFrame)+5, CGRectGetMinY(self.backImageViewFrame), 8, 8);
        //时间秒数
        self.secondLabelFrame = CGRectMake(CGRectGetMaxX(self.backImageViewFrame)+10, CGRectGetMinY(self.backImageViewFrame)+14, secondSize.width, 12);
        
        self.activiViewFrame = CGRectZero;
        
        //发送失败按钮
        self.failureButtonFrame = CGRectZero;
    }
    self.cellHeight = CGRectGetMaxY(self.backImageViewFrame) + 15.f;
    
}

@end
