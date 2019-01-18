//
//  JChatTextCellFrameModel.h
//  JYIM
//
//  Created by jy on 2019/1/11.
//  Copyright © 2019年 jy. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface JChatTextCellFrameModel : NSObject

@property (nonatomic, assign) CGRect iconViewFrame;
@property (nonatomic, assign) CGRect backImgViewFrame;
@property (nonatomic, assign) CGRect contentLabelFrame;
@property (nonatomic, assign) CGRect timeLabelFrame;
@property (nonatomic, assign) CGRect timeContainerFrame;
@property (nonatomic, assign) CGRect failureButtonFrame;
@property (nonatomic, assign) CGRect activiViewFrame;
@property (nonatomic, strong) MessageInfoModel * messageInfoModel;
@property (nonatomic, assign) CGFloat cellHeight;

@end

NS_ASSUME_NONNULL_END
