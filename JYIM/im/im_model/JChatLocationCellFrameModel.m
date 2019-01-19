//
//  JChatLocationCellFrameModel.m
//  JYIM
//
//  Created by jy on 2019/1/19.
//  Copyright © 2019年 jy. All rights reserved.
//

#import "JChatLocationCellFrameModel.h"

@implementation JChatLocationCellFrameModel

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
    
    if (messageInfoModel.byMySelf) {
        
        self.iconViewFrame = CGRectMake(ScreenWidth - 65, CGRectGetMaxY(self.timeContainerFrame)+15, 50, 50);
        self.picViewFrame = CGRectMake(CGRectGetMinX(self.iconViewFrame)-   120, CGRectGetMinY(self.iconViewFrame), 120, 120);
        
        self.locationLabFrame = CGRectMake(4.5f, CGRectGetHeight(self.picViewFrame)*0.7, CGRectGetWidth(self.picViewFrame) - 9.f, CGRectGetHeight(self.picViewFrame)*0.3);
        
        self.coverViewFrame = CGRectMake(0, 0, self.picViewFrame.size.width, self.picViewFrame.size.height);
        self.failureButtonFrame = CGRectMake(CGRectGetMinX(self.picViewFrame)-34, CGRectGetMinY(self.picViewFrame)+(CGRectGetHeight(self.picViewFrame)-24)*0.5, 24, 24);
        //菊花
        self.activiViewFrame = CGRectMake(CGRectGetMinX(self.picViewFrame)-34, CGRectGetMinY(self.picViewFrame) + (CGRectGetHeight(_picViewFrame) - 24)*0.5,24,24);
        
    }else{
        
        self.iconViewFrame = CGRectMake(15, CGRectGetMaxY(self.timeContainerFrame)+15, 50, 50);
        self.picViewFrame = CGRectMake(CGRectGetMaxX(self.iconViewFrame), CGRectGetMinY(self.iconViewFrame), 120, 120);
        
        self.coverViewFrame = CGRectMake(0, 0, self.picViewFrame.size.width, self.picViewFrame.size.height);
        self.locationLabFrame = CGRectMake(10.f, CGRectGetHeight(self.picViewFrame)*0.7, CGRectGetWidth(self.picViewFrame) -20.f, CGRectGetHeight(self.picViewFrame)*0.3);
        //菊花
        self.activiViewFrame = CGRectZero;
        self.failureButtonFrame = CGRectZero;
    }
    self.cellHeight = CGRectGetMaxY(_picViewFrame) + 15.f;
}

@end
