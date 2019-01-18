//
//  JChatImageCellFrameModel.h
//  JYIM
//
//  Created by jy on 2019/1/16.
//  Copyright © 2019年 jy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JChatImageCellFrameModel : NSObject

@property (nonatomic, strong) MessageInfoModel * messageInfoModel;

//头像
@property(nonatomic,assign) CGRect iconViewFrame;
//图片
@property (nonatomic, assign) CGRect picViewFrame;

//失败按钮
@property (nonatomic, assign) CGRect failureButtonFrame;
//遮罩
@property (nonatomic, assign) CGRect coverViewFrame;
//时间
@property (nonatomic, assign) CGRect timeLabelFrame;
//时间容器
@property (nonatomic, assign) CGRect timeContainerFrame;

@property (nonatomic, assign) CGFloat cellHeight;

//菊花
@property (nonatomic, assign) CGRect activiViewFrame;

@end

NS_ASSUME_NONNULL_END
