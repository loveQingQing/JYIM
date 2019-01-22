//
//  JChatLocationCell.m
//  JYIM
//
//  Created by jy on 2019/1/19.
//  Copyright © 2019年 jy. All rights reserved.
//

#import "JChatLocationCell.h"
#import "JChatLocationCellFrameModel.h"

@interface JChatLocationCell ()

//头像
@property (strong, nonatomic)  UIImageView *iconView;
//菊花
@property (nonatomic, strong) UIActivityIndicatorView *activiView;

//缩略图
@property (strong, nonatomic)  UIImageView *picView;
//遮罩
@property (nonatomic, strong) UIImageView *coverView;
//失败
@property (strong, nonatomic)  UIButton *failureButton;
//地址lab
@property (strong, nonatomic)  UILabel * locationLab;
//时间
@property (strong, nonatomic)  UILabel *timeLabel;
//时间容器
@property (nonatomic, strong) UIView *timeContainer;

//视频播放回调
@property (nonatomic, copy) showDetailLocationCallback showDetailLocationCallback;
//长按回调
@property (nonatomic, copy) longpressCallback longpressCallback;
//用户详情回调
@property (nonatomic, copy) userInfoCallback userInfoCallback;
//重新发送回调
@property (nonatomic, copy) sendAgainCallback sendAgainCallback;

//删除回调
@property (nonatomic, copy) deleteCallback deleteCallback;

@end

@implementation JChatLocationCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UICOLOR_RGB_Alpha(0xf0f0f0,1);
        [self.contentView addSubview:self.timeContainer];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.picView];
        [self.contentView addSubview:self.failureButton];
        [self.contentView addSubview:self.activiView];
    }
    return self;
}

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

-(UILabel *)locationLab{
    if (_locationLab == nil) {
        _locationLab = [[UILabel alloc] init];
        _locationLab.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
        _locationLab.textColor = [UIColor whiteColor];
        _locationLab.font = [UIFont systemFontOfSize:12.0];
    }
    return _locationLab;
}

- (UIImageView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIImageView alloc]init];
    }
    return _coverView;
}


- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc]init];
        _iconView.userInteractionEnabled = YES;
        
        ViewRadius(_iconView, 25.f);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toUserInfo)];
        [_iconView addGestureRecognizer:tap];
        
        
    }
    return _iconView;
}

-(UIActivityIndicatorView *)activiView{
    if (!_activiView) {
        _activiView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activiView.color = UICOLOR_RGB_Alpha(0xcdcdcd, 1);
    }
    return _activiView;
}


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




- (UIImageView *)picView
{
    if (!_picView) {
        _picView = [[UIImageView alloc]init];
        _picView.userInteractionEnabled = YES;
        //添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDetailLocation)];
        [_picView addGestureRecognizer:tap];
        //长按手势
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpressHandle)];
        [_picView addGestureRecognizer:longpress];
        
        [_picView addSubview:self.locationLab];
        [_picView addSubview:self.coverView];
        
        
    }
    return _picView;
}


- (UIButton *)failureButton
{
    if (!_failureButton) {
        _failureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_failureButton setImage:[UIImage imageNamed:@"发送失败"] forState:UIControlStateNormal];
        [_failureButton addTarget:self action:@selector(sendAgain) forControlEvents:UIControlEventTouchUpInside];
        _failureButton.hidden = YES;
    }
    return _failureButton;
}



- (void)setContent:(MessageInfoModel *)videoInfoModel
{
    if (videoInfoModel.shouldShowTime == YES) {
        _timeContainer.hidden = NO;
        self.timeLabel.text = [NSDate timeStringWithTimeInterval:videoInfoModel.sendTime];
    }else{
        _timeContainer.hidden = YES;
    }
    
    WS(weakSelf)
    //拉伸遮罩
    UIImage *rightHeightCoverImage = [UIImage imageNamed:@"右－竖图片遮罩"];
    UIImage *rightWidthCoverImage  = [UIImage imageNamed:@"右－横图片遮罩"];
    UIImage *leftHeightCoverImage  = [UIImage imageNamed:@"左－竖图片遮罩"];
    UIImage *leftWidthCoverImage   = [UIImage imageNamed:@"左－横图片遮罩"];
    //高的
    rightHeightCoverImage          = [rightHeightCoverImage stretchableImageWithLeftCapWidth:rightHeightCoverImage.size.width*0.3 topCapHeight:rightHeightCoverImage.size.height*0.6];
    //宽的
    rightWidthCoverImage           = [rightWidthCoverImage stretchableImageWithLeftCapWidth:rightWidthCoverImage.size.width*0.3 topCapHeight:rightWidthCoverImage.size.height*0.8];
    
    leftHeightCoverImage           = [leftHeightCoverImage stretchableImageWithLeftCapWidth:leftHeightCoverImage.size.width*0.6 topCapHeight:leftHeightCoverImage.size.height*0.8];
    leftWidthCoverImage            = [leftWidthCoverImage stretchableImageWithLeftCapWidth:leftWidthCoverImage.size.width*0.5 topCapHeight:leftWidthCoverImage.size.height*0.8];
    
    if (videoInfoModel.byMySelf == YES) {//本人
        
        if([videoInfoModel.sendStatus isEqualToString:@"0"]){
            self.failureButton.hidden = NO;
            self.activiView.hidden = YES;
            [self.activiView stopAnimating];
            
        }else if ([videoInfoModel.sendStatus isEqualToString:@"1"]){
            self.failureButton.hidden = YES;
            self.activiView.hidden = YES;
            [self.activiView stopAnimating];
            
        }else{
            self.failureButton.hidden = YES;
            self.activiView.hidden = NO;
            [self.activiView startAnimating];
            
        }
        
        [self.iconView downloadImage:@"我的头像" placeholder:@"userhead"];
        
        
        self.coverView.image = rightWidthCoverImage;
        
        
    }else{
        
        self.failureButton.hidden = YES;
        self.activiView.hidden = YES;
        [self.activiView stopAnimating];
        
        [self.iconView downloadImage:@"对方头像" placeholder:@"userhead"];
        
        
        self.coverView.image = leftWidthCoverImage;
        
    }
    UIImage *picImage = [UIImage imageNamed:@"chat_location_preview"];
    self.picView.image = picImage;
    self.locationLab.text = _locationCellFrameModel.messageInfoModel.messageText;
    
    _timeLabel.frame = _locationCellFrameModel.timeLabelFrame;
    _timeContainer.frame = _locationCellFrameModel.timeContainerFrame;
    self.picView.frame = _locationCellFrameModel.picViewFrame;
    self.coverView.frame = _locationCellFrameModel.coverViewFrame;
    self.iconView.frame = _locationCellFrameModel.iconViewFrame;
    self.locationLab.frame = _locationCellFrameModel.locationLabFrame;
    _failureButton.frame = _locationCellFrameModel.failureButtonFrame;
    _activiView.frame = _locationCellFrameModel.activiViewFrame;
    
}

-(void)setLocationCellFrameModel:(JChatLocationCellFrameModel *)locationCellFrameModel{
    _locationCellFrameModel = locationCellFrameModel;
    MessageInfoModel * locationMessageModel = _locationCellFrameModel.messageInfoModel;
    //菊花显示设置
    if ([locationMessageModel.sendStatus isEqualToString:@"0"]) {
        self.activiView.hidden = YES;
        [self.activiView stopAnimating];
        self.failureButton.hidden = NO;
        
    }else if ([locationMessageModel.sendStatus isEqualToString:@"1"]){
        self.activiView.hidden = YES;
        [self.activiView stopAnimating];
        self.failureButton.hidden = YES;
        
    }else{
        self.activiView.hidden = NO;
        [self.activiView startAnimating];
        self.failureButton.hidden = YES;
        
    }
    
    
    [self setContent:locationMessageModel];
}

-(void)sendAgainCallback:(sendAgainCallback)sendAgainCallback showDetailLocationCallback:(showDetailLocationCallback)showDetailLocationCallback longpressCallback:(longpressCallback)longpressCallback userInfoCallback:(userInfoCallback)userInfoCallback deleteCallback:(nonnull deleteCallback)deleteCallback{
    
    _sendAgainCallback = sendAgainCallback;
    _showDetailLocationCallback = showDetailLocationCallback;
    _longpressCallback = longpressCallback;
    _userInfoCallback = userInfoCallback;
    _deleteCallback = deleteCallback;
}

#pragma mark - 单击头像
- (void)toUserInfo
{
    if (_locationCellFrameModel.messageInfoModel.byMySelf == NO) {
        _userInfoCallback(_locationCellFrameModel.messageInfoModel.fromUser);
    }
}


#pragma mark - 地址长按
- (void)longpressHandle
{
    [self becomeFirstResponder];
    UIMenuController * menuController = [UIMenuController sharedMenuController];
    menuController.arrowDirection = UIMenuControllerArrowDown;
    UIMenuItem * deleteItem = [[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(itemDelete:)];
    menuController.menuItems = @[deleteItem];
    
    [menuController setTargetRect:CGRectMake(0, 5.f * kAutoSizeScaleY, self.coverView.width, self.coverView.height) inView:self.coverView];
    [menuController setMenuVisible:YES animated:YES];
}

#pragma mark - 进入地图界面
- (void)showDetailLocation
{
    _showDetailLocationCallback(_locationCellFrameModel.messageInfoModel);
}

#pragma mark - 重新发送
- (void)sendAgain
{
    _sendAgainCallback(_locationCellFrameModel.messageInfoModel);
}

-(void)itemDelete:(UIMenuController *) menu{
    _deleteCallback(_locationCellFrameModel.messageInfoModel);
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
