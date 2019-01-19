//
//  JChatLocationCellFrameModel.h
//  JYIM
//
//  Created by jy on 2019/1/19.
//  Copyright © 2019年 jy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JChatLocationCellFrameModel : NSObject

//头像
@property (assign, nonatomic)  CGRect iconViewFrame;
//菊花
@property (nonatomic, assign) CGRect activiViewFrame;

//缩略图
@property (assign, nonatomic)  CGRect picViewFrame;
//遮罩
@property (nonatomic, assign) CGRect coverViewFrame;
//失败
@property (assign, nonatomic)  CGRect failureButtonFrame;
//地址lab
@property (assign, nonatomic)  CGRect locationLabFrame;
//时间
@property (assign, nonatomic)  CGRect timeLabelFrame;
//时间容器
@property (nonatomic, assign) CGRect timeContainerFrame;

@property (nonatomic, strong) MessageInfoModel * messageInfoModel;

@property (nonatomic, assign) CGFloat cellHeight;

@end

NS_ASSUME_NONNULL_END
