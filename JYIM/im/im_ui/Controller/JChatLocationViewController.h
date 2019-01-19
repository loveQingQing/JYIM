//
//  JChatLocationViewController.h
//  JYIM
//
//  Created by jy on 2019/1/19.
//  Copyright © 2019年 jy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LocationType_show,
    LocationType_send,
} LocationType;

NS_ASSUME_NONNULL_BEGIN

typedef void(^ChatLocationMessageSendBlock)(NSString * lat,NSString * lon, NSString * detailStr);

@interface JChatLocationViewController : UIViewController

@property (nonatomic, assign) LocationType locationType;

@property (nonatomic, copy) NSString * lat;
@property (nonatomic, copy) NSString * lon;
@property (nonatomic, copy) NSString * locationDetailStr;
@property (nonatomic, copy) ChatLocationMessageSendBlock  locationMessageSendBlock;

@end

NS_ASSUME_NONNULL_END
