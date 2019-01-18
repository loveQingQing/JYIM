//
//  ChatListCell.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageListModel;

@interface ChatListCell : UITableViewCell

@property (nonatomic, strong) MessageListModel *messageListModel;

@end
