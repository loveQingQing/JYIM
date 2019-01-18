//
//  JChatTextCell.m
//  JYIM
//
//  Created by jy on 2019/1/11.
//  Copyright © 2019年 jy. All rights reserved.
//

#import "JChatTextCell.h"
#import "MYCoreTextLabel.h"
#import "JChatTextCellFrameModel.h"
#import "YYText.h"

@interface JChatTextCell ()<MYCoreTextLabelDelegate>

//头像
@property (nonatomic, strong) UIImageView *iconView;
//背景
@property (nonatomic, strong) UIImageView *backImgView; //背景
//文字图文混排
@property (nonatomic, strong) YYLabel *contentLabel;
//时间
@property (nonatomic, strong) UILabel *timeLabel;
//时间容器
@property (nonatomic, strong) UIView *timeContainer;
//失败按钮
@property (nonatomic, strong) UIButton *failureButton;
//菊花
@property (nonatomic, strong) UIActivityIndicatorView *activiView;


//长按回调
@property (nonatomic, copy) longpressCallback longpressCallback;
//用户详情回调
@property (nonatomic, copy) userInfoCallback userInfoCallback;
//重新发送回调
@property (nonatomic, copy) sendAgainCallback sendAgainCallback;

@end

@implementation JChatTextCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UICOLOR_RGB_Alpha(0xf0f0f0,1);
        [self.contentView addSubview:self.timeContainer];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.backImgView];
        [self.contentView addSubview:self.activiView];
        [self.contentView addSubview:self.failureButton];
        
    }
    return self;
}



- (YYLabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[YYLabel alloc]init];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

//菊花
- (UIActivityIndicatorView *)activiView
{
    if (!_activiView) {
        _activiView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activiView.color = UICOLOR_RGB_Alpha(0xcdcdcd, 1);
    }
    return _activiView;
}

- (UIButton *)failureButton
{
    if (!_failureButton) {
        _failureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_failureButton setImage:[UIImage imageNamed:@"发送失败"] forState:UIControlStateNormal];
        [_failureButton addTarget:self action:@selector(sendAgain) forControlEvents:UIControlEventTouchUpInside];
        _failureButton.hidden = YES; //默认隐藏
    }
    return _failureButton;
}

- (UIView *)timeContainer
{
    if (!_timeContainer) {
        _timeContainer = [[UIView alloc]init];
        _timeContainer.backgroundColor = UICOLOR_RGB_Alpha(0xcecece, 1);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            ViewRadius(_timeContainer, 5.f);
        });
        [_timeContainer addSubview:self.timeLabel];
    }
    return _timeContainer;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _timeLabel;
}

- (UIImageView *)backImgView
{
    if (!_backImgView) {
        _backImgView = [[UIImageView alloc]init];
        _backImgView.userInteractionEnabled = YES;
        //长按手势
//        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpressHandle)];
//        [_backImgView addGestureRecognizer:longpress];
        [_backImgView addSubview:self.contentLabel];
    }
    return _backImgView;
}


- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc]init];
        _iconView.userInteractionEnabled = YES;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            ViewRadius(_iconView,25);
        });
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toUserInfo)];
        [_iconView addGestureRecognizer:tap];
        
    }
    return _iconView;
}

- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType
{
    NSLog(@"----------点击了-------%@",clickString);
}


-(void)setTextCellFrameModel:(JChatTextCellFrameModel *)textCellFrameModel{
    _textCellFrameModel = textCellFrameModel;
    MessageInfoModel * messageModel = _textCellFrameModel.messageInfoModel;
    
#warning 头像
    [self.iconView downloadImage:@"头像" placeholder:@"userhead"];
    UIImage *backImage = nil;
    //我方
    if (messageModel.byMySelf) {
        
        backImage = [UIImage imageNamed:@"我方文字气泡"];
        
    }else{
        
        backImage = [UIImage imageNamed:@"对方文字气泡"];
    }
    self.contentLabel.attributedText = messageModel.contentAttributedString;
    backImage = [backImage stretchableImageWithLeftCapWidth:backImage.size.width * 0.8 topCapHeight:backImage.size.height *0.8];
    self.backImgView.image = backImage;
    
    
    if (messageModel.shouldShowTime) {
        _timeContainer.hidden = NO;
        _timeLabel.hidden = NO;
        self.timeLabel.text = [NSDate timeStringWithTimeInterval:messageModel.sendTime];
    }else{
        _timeContainer.hidden = YES;
        _timeLabel.hidden = YES;
    }
    self.timeLabel.frame = textCellFrameModel.timeLabelFrame;
    self.timeContainer.frame = textCellFrameModel.timeContainerFrame;
    self.iconView.frame = textCellFrameModel.iconViewFrame;
    self.contentLabel.frame = textCellFrameModel.contentLabelFrame;
    self.backImgView.frame = textCellFrameModel.backImgViewFrame;
    self.failureButton.frame = textCellFrameModel.failureButtonFrame;
    self.activiView.frame = textCellFrameModel.failureButtonFrame;
    if ([messageModel.sendStatus isEqualToString:@"0"]) {
        self.failureButton.hidden = NO;
        self.activiView.hidden = YES;
    }else if([messageModel.sendStatus isEqualToString:@"1"])
    {
        self.failureButton.hidden = YES;
        self.activiView.hidden = YES;
    }
    else{//2
         self.failureButton.hidden = YES;
         self.activiView.hidden = NO;
    }
    
}

#pragma mark - 消息长按
- (void)longpressHandle
{
    
}

#pragma mark - 进入个人资料详情
- (void)toUserInfo
{
    if (_textCellFrameModel.messageInfoModel.byMySelf == NO) {
        _userInfoCallback(_textCellFrameModel.messageInfoModel.fromUser);
    }
    
}

#pragma mark - 重新发送
- (void)sendAgain
{
    _sendAgainCallback(_textCellFrameModel.messageInfoModel);
}


-(void)sendAgainCallback:(sendAgainCallback)sendAgainCallback longpressCallback:(longpressCallback)longpressCallback userInfoCallback:(userInfoCallback)userInfoCallback
{
    _sendAgainCallback = sendAgainCallback;
    _longpressCallback = longpressCallback;
    _userInfoCallback = userInfoCallback;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
