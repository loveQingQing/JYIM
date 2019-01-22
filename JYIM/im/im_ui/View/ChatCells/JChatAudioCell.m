//
//  JChatAudioCell.m
//  JYIM
//
//  Created by jy on 2019/1/14.
//  Copyright © 2019年 jy. All rights reserved.
//

#import "JChatAudioCell.h"
#import "JChatAudioCellFrameModel.h"

@interface JChatAudioCell ()

@property (nonatomic, strong) UIProgressView * downloadProgressView;
//头像
@property (nonatomic, strong) UIImageView *iconView;
//背景
@property (nonatomic, strong) UIImageView *backImageView; //背景
//时间
@property (nonatomic, strong) UILabel *timeLabel;
//时间容器
@property (nonatomic, strong) UIView *timeContainer;
//失败按钮
@property (nonatomic, strong) UIButton *failureButton;
//菊花
@property (nonatomic, strong) UIActivityIndicatorView *activiView;
//秒数label
@property (nonatomic, strong) UILabel *secondLabel;
//红点
@property (nonatomic, strong) UILabel *redPoint;
//声音GIF
@property (nonatomic, strong) UIImageView *voiceGIFView;

//播放回调
@property (nonatomic, copy) playAudioCallback playCallback;
//长按回调
@property (nonatomic, copy) longpressCallback longpressCallback;
//用户详情回调
@property (nonatomic, copy) userInfoCallback userInfoCallback;
//重新发送回调
@property (nonatomic, copy) sendAgainCallback sendAgainCallback;

//删除回调
@property (nonatomic, copy) deleteCallback deleteCallback;

@end

@implementation JChatAudioCell



//秒数
- (UILabel *)secondLabel
{
    if (!_secondLabel) {
        _secondLabel = [[UILabel alloc]init];
        _secondLabel.font = [UIFont systemFontOfSize:12.0];
        _secondLabel.textColor = UICOLOR_RGB_Alpha(0x999999, 1);
    }
    return _secondLabel;
}

/**
 下载进度
 */
-(UIProgressView *)downloadProgressView{
    if (_downloadProgressView == nil) {
        _downloadProgressView = [[UIProgressView alloc] init];
        _downloadProgressView.progressTintColor = [UIColor greenColor];
        _downloadProgressView.hidden = YES;
    }
    return _downloadProgressView;
}


//红点
- (UILabel *)redPoint
{
    if (!_redPoint) {
        _redPoint = [[UILabel alloc]init];
        ViewRadius(_redPoint, 4.f);
        _redPoint.backgroundColor = [UIColor redColor];
    }
    return _redPoint;
}

//语音动画
- (UIImageView *)voiceGIFView
{
    if (!_voiceGIFView) {
        _voiceGIFView = [[UIImageView alloc]init];
    }
    return _voiceGIFView;
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

//失败按钮
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

//时间容器
- (UIView *)timeContainer
{
    if (!_timeContainer) {
        _timeContainer = [[UIView alloc]init];
        _timeContainer.backgroundColor = UICOLOR_RGB_Alpha(0xcecece, 1);
        ViewRadius(_timeContainer, 5.f);
        
        [_timeContainer addSubview:self.timeLabel];
    }
    return _timeContainer;
}

//时间
- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:12.0];
    }
    return _timeLabel;
}

//气泡
- (UIImageView *)backImageView
{
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc]init];
        _backImageView.userInteractionEnabled = YES;
        [_backImageView addSubview:self.voiceGIFView];
        //单击手势,播放语音
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playAudio)];
        [_backImageView addGestureRecognizer:tap];
        //长按手势
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpressHandle)];
        [_backImageView addGestureRecognizer:longpress];
    }
    return _backImageView;
}

//头像
- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc]init];
        _iconView.userInteractionEnabled = YES;
        ViewRadius(_iconView,25);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toUserInfo)];
        [_iconView addGestureRecognizer:tap];
    }
    return _iconView;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = UICOLOR_RGB_Alpha(0xf0f0f0,1);
        [self.contentView addSubview:self.timeContainer];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.backImageView];
        [self.contentView addSubview:self.redPoint];
        [self.contentView addSubview:self.secondLabel];
        [self.contentView addSubview:self.activiView];
        [self.contentView addSubview:self.failureButton];
        [self.contentView addSubview:self.downloadProgressView];
    }
    return self;
}

- (void)setAudioCellFrameModel:(JChatAudioCellFrameModel *)audioCellFrameModel
{
    _audioCellFrameModel = audioCellFrameModel;
    MessageInfoModel * messageInfoModel = _audioCellFrameModel.messageInfoModel;
    
   
    if (messageInfoModel.shouldShowTime) {
        self.timeLabel.text = [NSDate timeStringWithTimeInterval:messageInfoModel.sendTime];
        self.timeContainer.hidden = NO;
    }else{
        self.timeContainer.hidden = YES;
    }
    
    //处理失败按钮
   
    if (messageInfoModel.byMySelf == 1 && [messageInfoModel.sendStatus isEqualToString:@"0"]) {
        self.failureButton.hidden =  NO;
    }else{

        self.failureButton.hidden = YES;
    }
    
    //红点隐藏处理
    self.redPoint.hidden   = messageInfoModel.byMySelf || messageInfoModel.hasReadAudio;
    //转圈处理
    if ([messageInfoModel.sendStatus isEqualToString:@"2"]) {
        [self.activiView startAnimating];
    }else{
        [self.activiView stopAnimating];
    }
    //秒数
    self.secondLabel.text = [NSString stringWithFormat:@"%@''",_audioCellFrameModel.messageInfoModel.duration];
    
    //我方
    if (_audioCellFrameModel.messageInfoModel.byMySelf) {
#warning 头像
        //头像
        [self.iconView downloadImage:@"我的头像" placeholder:defaulUserIcon];
        //气泡
        UIImage *voiceBackImage = [UIImage imageNamed:@"我方文字气泡"];
        //拉伸
        voiceBackImage           = [voiceBackImage stretchableImageWithLeftCapWidth:voiceBackImage.size.width *0.5 topCapHeight:voiceBackImage.size.height *0.5];
        self.backImageView.image   = voiceBackImage;
        self.voiceGIFView.image = [UIImage imageNamed:@"我方语音icon03"];
    }else{
        
        //头像
        [self.iconView downloadImage:@"别人的头像" placeholder:defaulUserIcon];
        //气泡
        UIImage *voiceBackImage = [UIImage imageNamed:@"对方文字气泡"];
        //拉伸
        [voiceBackImage resizableImageWithCapInsets:UIEdgeInsetsMake(voiceBackImage.size.height *0.9, voiceBackImage.size.width *0.5, voiceBackImage.size.height *0.1, voiceBackImage.size.width * 0.5) resizingMode:UIImageResizingModeStretch];
        self.backImageView.image = voiceBackImage;
        self.voiceGIFView.image = [UIImage imageNamed:@"对方语音icon03"];
    }
    
    self.timeLabel.frame = self.audioCellFrameModel.timeLabelFrame;
    self.timeContainer.frame = self.audioCellFrameModel.timeContainerFrame;
    self.iconView.frame = self.audioCellFrameModel.iconViewFrame;
    self.backImageView.frame = self.audioCellFrameModel.backImageViewFrame;
    self.voiceGIFView.frame = self.audioCellFrameModel.voiceGIFViewFrame;
    self.secondLabel.frame = self.audioCellFrameModel.secondLabelFrame;
    self.activiView.frame = self.audioCellFrameModel.activiViewFrame;
    self.redPoint.frame = self.audioCellFrameModel.redPointFrame;
    self.failureButton.frame = self.audioCellFrameModel.failureButtonFrame;
    self.downloadProgressView.frame = self.audioCellFrameModel.downloadProgressViewFrame;
    
}





#pragma mark - 播放语音
- (void)playAudio
{
    //回调播放
    if (_playCallback) {
        _playCallback(_audioCellFrameModel.messageInfoModel);
    }
}

-(void)playGIF{
    NSArray *gifs = _audioCellFrameModel.messageInfoModel.byMySelf ? @[@"我方语音icon01",@"我方语音icon02",@"我方语音icon03"] : @[@"对方语音icon01",@"对方语音icon02",@"对方语音icon03"];
    [self.voiceGIFView GIF_PrePlayWithImageNamesArray:gifs];
}
-(void)stopGif{
    [self.voiceGIFView GIF_Stop];
}


-(void)showDownLoadProgress:(double)progress{
    if (progress < 1.0) {
        
        _downloadProgressView.hidden = NO;
        [_downloadProgressView setProgress:progress animated:YES];
        
    }else{
        
        _downloadProgressView.hidden = YES;
    }
    
}

//隐藏对方发来的语音消息未读红点
-(void)hideRedPoint{
    self.redPoint.hidden = YES;
}

#pragma mark - 回调
- (void)sendAgain:(sendAgainCallback)sendAgain playAudio:(playAudioCallback)playAudio longpress:(longpressCallback)longpress toUserInfo:(userInfoCallback)userDetailCallback deleteCallBack:(deleteCallback)deleteCallBack
{
    _sendAgainCallback = sendAgain;
    _playCallback          = playAudio;
    _longpressCallback  = longpress;
    _userInfoCallback    = userDetailCallback;
    _deleteCallback = deleteCallBack;
}


#pragma mark - 重新发送
- (void)sendAgain
{
    _sendAgainCallback(_audioCellFrameModel.messageInfoModel);
}

#pragma mark - 语音长按
- (void)longpressHandle
{
    [self becomeFirstResponder];
    UIMenuController * menuController = [UIMenuController sharedMenuController];
    menuController.arrowDirection = UIMenuControllerArrowDown;
    UIMenuItem * deleteItem = [[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(itemDelete:)];
    menuController.menuItems = @[deleteItem];
    
    [menuController setTargetRect:CGRectMake(0, 5.f * kAutoSizeScaleY, self.backImageView.width, self.backImageView.height) inView:self.backImageView];
    [menuController setMenuVisible:YES animated:YES];
}

#pragma mark - 进入用户详情
- (void)toUserInfo
{
    if (_audioCellFrameModel.messageInfoModel.byMySelf == NO) {
        _userInfoCallback(_audioCellFrameModel.messageInfoModel.fromUser);
    }
}

-(void)itemDelete:(UIMenuController *) menu{
    _deleteCallback(_audioCellFrameModel.messageInfoModel);
}

-(BOOL) canBecomeFirstResponder{
    
    return YES;
    
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(itemDelete:))
    {
        return YES;
        
    }
    return [super canPerformAction:action withSender:sender];
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
