//
//  ChatListCell.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatListCell.h"
#import "MessageListModel.h"
#import "UIImageView+SDWebImage.h"
#import "YYLabel.h"

@interface ChatListCell ()
@property (strong, nonatomic)  UIImageView *iconView;
@property (strong, nonatomic)  UILabel *nameLabel;
@property (strong, nonatomic)  UILabel *timeLabel;
@property (strong, nonatomic)  UILabel *unreadLabel;
@property (strong, nonatomic)  YYLabel *lastMessageLabel;
@property (strong, nonatomic)  UIView *lineView;

@end

@implementation ChatListCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.iconView = [[UIImageView alloc] init];
        ViewRadius(_iconView, 25);
        self.iconView.frame = CGRectMake(15.f, 5.f, 50, 50);
        [self.contentView addSubview:self.iconView];
        
        self.unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(_iconView.right - 8.f, _iconView.top, 16.f, 16.f)];
        [self.contentView addSubview:self.unreadLabel];
        self.unreadLabel.textAlignment = NSTextAlignmentCenter;
        self.unreadLabel.font = [UIFont systemFontOfSize:12.0];
        self.unreadLabel.textColor = [UIColor whiteColor];
        self.unreadLabel.backgroundColor = [UIColor redColor];
        ViewRadius(_unreadLabel, 8);
        
        self.timeLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.timeLabel];
        self.timeLabel.font = [UIFont systemFontOfSize:12.0];
        _timeLabel.textColor = UICOLOR_RGB_Alpha(0x999999, 1);
        self.timeLabel.text = @"00-00-00 00:00";
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self.timeLabel sizeToFit];
        self.timeLabel.text = @"";
        self.timeLabel.frame = CGRectMake(ScreenWidth - 15.f - _timeLabel.width, 10.f, _timeLabel.width, 15.f);
        
        self.nameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.nameLabel];
        self.nameLabel.frame = CGRectMake(_iconView.right +10, 10.f, _timeLabel.left - 5.f - _iconView.right - 10.f, 16.f);
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont systemFontOfSize:15.0];
        
        self.lastMessageLabel = [[YYLabel alloc] init];
        [self.contentView addSubview:self.lastMessageLabel];
        self.lastMessageLabel.font = [UIFont systemFontOfSize:13.0];
         _lastMessageLabel.textColor = UICOLOR_RGB_Alpha(0x999999, 1);
        self.lastMessageLabel.frame = CGRectMake(_nameLabel.left, _nameLabel.bottom + 8.f, ScreenWidth - 15.f - _nameLabel.left, 21.f);
        
        self.lineView = [[UIView alloc] init];
        [self.contentView addSubview:self.lineView];
        _lineView.backgroundColor = kGrayLineColor;
        self.lineView.frame = CGRectMake(0, _lastMessageLabel.bottom + 5.f, ScreenWidth, 0.5f);
    }
    return self;
}


- (void)setMessageListModel:(MessageListModel *)messageListModel
{
    _messageListModel = messageListModel;
    
    //内容
    [self configContent];
}

- (void)configContent
{
    [_iconView downloadImage:nil placeholder:defaulUserIcon];
    _nameLabel.text              = [_messageListModel.fromUser isEqualToString:[IMClientManager sharedInstance].uid]?_messageListModel.toUser:_messageListModel.fromUser;
    _timeLabel.text               = [NSDate timeStringWithTimeInterval:_messageListModel.sendTime];
    switch (_messageListModel.messageType) {
        case 1:
            _lastMessageLabel.attributedText   = _messageListModel.contentAttributedString;
            break;
            
        case 2:
        {
            NSMutableAttributedString * theContentText = [[NSMutableAttributedString alloc] initWithString:@"[图片]"];
            [theContentText addAttribute:NSForegroundColorAttributeName
                              value:RGB(199, 54, 45)
                              range:NSMakeRange(0, theContentText.length)];
            _lastMessageLabel.attributedText   = theContentText;
            break;
        }
            
        case 3:
        {
            NSMutableAttributedString * theContentText = [[NSMutableAttributedString alloc] initWithString:@"[视频]"];
            [theContentText addAttribute:NSForegroundColorAttributeName
                                   value:RGB(199, 54, 45)
                                   range:NSMakeRange(0, theContentText.length)];
            _lastMessageLabel.attributedText   = theContentText;
            break;
        }
        case 4:
        {
            NSMutableAttributedString * theContentText = [[NSMutableAttributedString alloc] initWithString:@"[语音]"];
            [theContentText addAttribute:NSForegroundColorAttributeName
                                   value:RGB(199, 54, 45)
                                   range:NSMakeRange(0, theContentText.length)];
            _lastMessageLabel.attributedText   = theContentText;
            break;
        }
        case 5:
        {
            NSMutableAttributedString * theContentText = [[NSMutableAttributedString alloc] initWithString:@"[位置]"];
            [theContentText addAttribute:NSForegroundColorAttributeName
                                   value:RGB(199, 54, 45)
                                   range:NSMakeRange(0, theContentText.length)];
            _lastMessageLabel.attributedText   = theContentText;
            break;
        }
        default:
            break;
    }
    
    if (_messageListModel.notReadCount == 0) {
        _unreadLabel.hidden = YES;
    }else{
        _unreadLabel.text = [NSString stringWithFormat:@"%ld",_messageListModel.notReadCount];
        _unreadLabel.hidden = NO;
    }

    
}


@end
