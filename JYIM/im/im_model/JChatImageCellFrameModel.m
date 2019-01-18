//
//  JChatImageCellFrameModel.m
//  JYIM
//
//  Created by jy on 2019/1/16.
//  Copyright © 2019年 jy. All rights reserved.
//

#import "JChatImageCellFrameModel.h"

@implementation JChatImageCellFrameModel

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
    CGSize  picSize = messageInfoModel.picSize;
    //图片宽高比
    CGFloat widHgtScale = picSize.width * 1.0 /  picSize.height;
    //图片高宽比
    CGFloat hgtWidScale = picSize.height * 1.0/ picSize.width;
    //我方图片
    if (messageInfoModel.byMySelf == YES) {
        
        //头像
        _iconViewFrame = CGRectMake(ScreenWidth - 65, CGRectGetMaxY(self.timeContainerFrame)+15, 50, 50);
        
        //高大于宽
        if (widHgtScale>0&&widHgtScale < 1) {
            
            //极窄极高 (展示固定50宽,不能再窄)
            if (105*widHgtScale<=50) {
                self.picViewFrame = CGRectMake(ScreenWidth - 115, CGRectGetMinY(self.iconViewFrame), 50, 130);
            }else{
                self.picViewFrame = CGRectMake(CGRectGetMinX(self.iconViewFrame)-130*widHgtScale ,CGRectGetMinY(self.iconViewFrame), 130*widHgtScale, 130);
            }
            
            //宽大于高
        }else if (widHgtScale >1){
            
            //极宽极低(展示固定高度50,不能更低)
            if (100*(hgtWidScale)<=50) {
                self.picViewFrame = CGRectMake(ScreenWidth -195, CGRectGetMinY(self.iconViewFrame), 130, 50);
            }else{
                self.picViewFrame = CGRectMake(CGRectGetMinX(self.iconViewFrame)-135, CGRectGetMinY(self.iconViewFrame), 135, 135 *hgtWidScale);
            }
            //宽高相等
        }else{
            self.picViewFrame = CGRectMake(CGRectGetMinX(self.iconViewFrame)- 120, CGRectGetMinY(self.iconViewFrame), 120, 120);
        }
        //菊花
        self.activiViewFrame = CGRectMake(CGRectGetMinX(self.picViewFrame)-34, CGRectGetMinY(self.picViewFrame) + (CGRectGetHeight(_picViewFrame) - 24)*0.5,24,24);
        
        //遮罩
        self.coverViewFrame = CGRectMake(0, 0, CGRectGetWidth(self.picViewFrame), CGRectGetHeight(self.picViewFrame));
        //失败按钮
        self.failureButtonFrame = CGRectMake(CGRectGetMinX(self.picViewFrame)-38, CGRectGetMinY(self.picViewFrame)+(self.picViewFrame.size.height-30)*0.5, 30, 30);
        
    }else{//对方图片
        
        //头像
        _iconViewFrame = CGRectMake(15, CGRectGetMaxY(self.timeContainerFrame)+15, 50, 50);
        
        //高大于宽
        if (widHgtScale>0&&widHgtScale < 1) {
            
            //极窄极高 (展示固定50宽,不能再窄)
            if (105*widHgtScale<=50) {
                self.picViewFrame = CGRectMake(CGRectGetMaxX(_iconViewFrame), CGRectGetMinY(self.iconViewFrame), 50, 130);
            }else{
                self.picViewFrame = CGRectMake(CGRectGetMaxX(self.iconViewFrame) ,CGRectGetMinY(self.iconViewFrame), 130*widHgtScale, 130);
            }
            
            //宽大于高
        }else if (widHgtScale >1){
            
            //极宽极低(展示固定高度50,不能更低)
            if (100*(hgtWidScale)<=50) {
                self.picViewFrame = CGRectMake(CGRectGetMaxX(_iconViewFrame), CGRectGetMinY(self.iconViewFrame), 130, 50);
            }else{
                self.picViewFrame = CGRectMake(+ CGRectGetMaxX(_iconViewFrame), CGRectGetMinY(self.iconViewFrame), 135, 135 *hgtWidScale);
            }
            //宽高相等
        }else{
            self.picViewFrame = CGRectMake(CGRectGetMaxX(self.iconViewFrame), CGRectGetMinY(self.iconViewFrame), 120, 120);
        }
        //菊花
        self.activiViewFrame = CGRectMake(CGRectGetMaxX(self.picViewFrame)+10, CGRectGetMinY(self.picViewFrame) + (CGRectGetHeight(_picViewFrame) - 24)*0.5,24,24);
        //失败按钮
        self.failureButtonFrame = CGRectZero;
        
        //遮罩
        self.coverViewFrame = CGRectMake(0, 0, CGRectGetWidth(self.picViewFrame), CGRectGetHeight(self.picViewFrame));
    }
    self.cellHeight = CGRectGetMaxY(self.picViewFrame) + 15.f;
}
@end
