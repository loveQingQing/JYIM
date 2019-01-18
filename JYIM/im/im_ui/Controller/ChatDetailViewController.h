//
//  ChatDetailViewController.h
//  JYIM
//
//  Created by jy on 2019/1/10.
//  Copyright © 2019年 jy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageListModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ChatDetailViewController : UIViewController

@property (nonatomic, copy) void(^backBlock)(void);
@property (nonatomic, copy) NSString * uid;//聊天对象uid

@end

NS_ASSUME_NONNULL_END
