//
//  JChatTextCellFrameModel.m
//  JYIM
//
//  Created by jy on 2019/1/11.
//  Copyright © 2019年 jy. All rights reserved.
//

#import "JChatTextCellFrameModel.h"
#import "MYCoreTextLabel.h"

@implementation JChatTextCellFrameModel

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
    
    CGSize contentTextSize = [YYTextLayout layoutWithContainerSize:CGSizeMake(ScreenWidth - 145, MAXFLOAT) text:messageInfoModel.contentAttributedString].textBoundingSize;
    
    if (_messageInfoModel.byMySelf) {
        self.iconViewFrame = CGRectMake(ScreenWidth - 65, CGRectGetMaxY(self.timeContainerFrame)+15, 50, 50);
       //我方文本label
       self.contentLabelFrame = CGRectMake(10, 10,contentTextSize.width, contentTextSize.height);
       self.backImgViewFrame = CGRectMake(ScreenWidth - 100 - self.contentLabelFrame.size.width, CGRectGetMinY(self.iconViewFrame)+5, self.contentLabelFrame.size.width+30, self.contentLabelFrame.size.height+20);
       self.activiViewFrame = CGRectMake(CGRectGetMinX(self.backImgViewFrame)-34,CGRectGetMinY(self.backImgViewFrame)+((self.backImgViewFrame.size.height-24)*0.5), 24, 24);
    
        //发送失败按钮
        self.failureButtonFrame = CGRectMake(CGRectGetMinX(self.backImgViewFrame) - 8.f - 30.f, CGRectGetCenter(_activiViewFrame).y - 15.f, 30.f, 30.f);
    }else{
        //对方头像
        self.iconViewFrame = CGRectMake(15, CGRectGetMaxY(self.timeContainerFrame)+15, 50, 50);
        //对方文本label
        self.contentLabelFrame = CGRectMake(20, 10, contentTextSize.width, contentTextSize.height);
        //对方气泡
        self.backImgViewFrame = CGRectMake(CGRectGetMaxX(self.iconViewFrame)+5,CGRectGetMinY(self.iconViewFrame)+5, self.contentLabelFrame.size.width+30, self.contentLabelFrame.size.height+20);
        self.failureButtonFrame = CGRectZero;
        
    }
    self.cellHeight = CGRectGetMaxY(self.backImgViewFrame) + 15.f;
    
}

@end
