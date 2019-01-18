//
//  JChatAudioCellFrameModel.h
//  JYIM
//
//  Created by jy on 2019/1/14.
//  Copyright © 2019年 jy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JChatAudioCellFrameModel : NSObject

@property (nonatomic, strong) MessageInfoModel * messageInfoModel;

//头像
@property (nonatomic, assign) CGRect iconViewFrame;
//背景
@property (nonatomic, assign) CGRect backImageViewFrame; //背景
//时间
@property (nonatomic, assign) CGRect timeLabelFrame;
//时间容器
@property (nonatomic, assign) CGRect timeContainerFrame;
//失败按钮
@property (nonatomic, assign) CGRect failureButtonFrame;
//菊花
@property (nonatomic, assign) CGRect activiViewFrame;
//秒数label
@property (nonatomic, assign) CGRect secondLabelFrame;
//红点
@property (nonatomic, assign) CGRect redPointFrame;
//声音GIF
@property (nonatomic, assign) CGRect voiceGIFViewFrame;

//下载进度
@property (nonatomic, assign) CGRect  downloadProgressViewFrame;

@property (nonatomic, assign) CGFloat cellHeight;


@end

NS_ASSUME_NONNULL_END
