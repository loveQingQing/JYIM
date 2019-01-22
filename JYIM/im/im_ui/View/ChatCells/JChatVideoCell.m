//
//  JChatVideoCell.m
//  JYIM
//
//  Created by jy on 2019/1/17.
//  Copyright © 2019年 jy. All rights reserved.
//

#import "JChatVideoCell.h"
#import "JChatVideoCellFrameModel.h"
#import "UIImageView+WebCache.h"

@interface JChatVideoCell ()

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
//播放按钮
@property (strong, nonatomic)  UIImageView *playImageView;
//时间
@property (strong, nonatomic)  UILabel *timeLabel;
//时间容器
@property (nonatomic, strong) UIView *timeContainer;

//视频播放回调
@property (nonatomic, copy) playVideoCallback playVideoCallback;
//长按回调
@property (nonatomic, copy) longpressCallback longpressCallback;
//用户详情回调
@property (nonatomic, copy) userInfoCallback userInfoCallback;
//重新发送回调
@property (nonatomic, copy) sendAgainCallback sendAgainCallback;
//删除回调
@property (nonatomic, copy) deleteCallback deleteCallback;
@end

@implementation JChatVideoCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
            
            self.backgroundColor = UICOLOR_RGB_Alpha(0xf0f0f0,1);
            [self.contentView addSubview:self.timeContainer];
            [self.contentView addSubview:self.iconView];
            [self.contentView addSubview:self.picView];
            [self.contentView addSubview:self.failureButton];
            [self.contentView addSubview:self.activiView];
        }
        return self;
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
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVideo)];
        [_picView addGestureRecognizer:tap];
        //长按手势
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpressHandle)];
        [_picView addGestureRecognizer:longpress];
        
        [_picView addSubview:self.coverView];
        [_picView addSubview:self.playImageView];
        
        
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

- (UIImageView *)playImageView
{
    if (!_playImageView) {
        _playImageView = [[UIImageView alloc]init];
        _playImageView.image = [UIImage imageNamed:@"视频icon"];
        
    }
    return _playImageView;
}

-(void)setVideoCellFrameModel:(JChatVideoCellFrameModel *)videoCellFrameModel{
    _videoCellFrameModel = videoCellFrameModel;
    MessageInfoModel * videoInfoModel = _videoCellFrameModel.messageInfoModel;
    
    //菊花显示设置
    if ([videoInfoModel.sendStatus isEqualToString:@"0"]) {
        self.activiView.hidden = YES;
        [self.activiView stopAnimating];
        self.failureButton.hidden = NO;
       
    }else if ([videoInfoModel.sendStatus isEqualToString:@"1"]){
        self.activiView.hidden = YES;
        [self.activiView stopAnimating];
        self.failureButton.hidden = YES;
      
    }else{
        self.activiView.hidden = NO;
        [self.activiView startAnimating];
        self.failureButton.hidden = YES;
        
    }
    
    
    [self setContent:videoInfoModel];
    
    
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
            NSString *imgCachePath = [ChatCache_Path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@_cover.jpg",_videoCellFrameModel.messageInfoModel.toUser,_videoCellFrameModel.messageInfoModel.messageInfoId]];
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imgCachePath]];
            UIImage *picImage = [UIImage imageWithData:imageData];
            //本地如果存在
            if (picImage) {
                self.picView.image = picImage;
            }else{
                self.picView.image = [UIImage imageNamed:@"照片"];
            }

           
            self.coverView.image = rightWidthCoverImage;


        }else{

            self.failureButton.hidden = YES;
            self.activiView.hidden = YES;
            [self.activiView stopAnimating];
            
            [self.iconView downloadImage:@"对方头像" placeholder:@"userhead"];
            
            
            //获取本地资源缓存路径
            NSString *imgCachePath = [ChatCache_Path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@_cover.jpg",_videoCellFrameModel.messageInfoModel.fromUser,_videoCellFrameModel.messageInfoModel.messageInfoId]];
            
            NSFileManager * fn = [NSFileManager defaultManager];
            if ([fn fileExistsAtPath:imgCachePath]) {
                
                NSData *picData = [NSData dataWithContentsOfFile:imgCachePath];
                UIImage *image = [UIImage imageWithData:picData];
                //图片
                if (image) {
                    
                    self.picView.image = image;
                }else{
                    self.picView.image = [UIImage imageNamed:@"照片"];
                    
                }
                
            }else{
                
                //下载缓存
                [self.picView  sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:_videoCellFrameModel.messageInfoModel.picUrl] placeholderImage:[UIImage imageNamed:@"照片"] options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                    
                } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(!error){
                            weakSelf.picView.image = image;
                        }
                    });
                    
                    //拼接缓存目录
                    NSString * saveImgDir = [imgCachePath stringByDeletingLastPathComponent];
                    
                    BOOL exist = [fn fileExistsAtPath:saveImgDir];
                    if (!exist) {
                        [fn createDirectoryAtPath:saveImgDir withIntermediateDirectories:YES attributes:nil error:NULL];
                    }
                    
                    //图片写入缓存
                    
                    [UIImagePNGRepresentation(image) writeToFile:imgCachePath atomically:YES];
                    
                }];
            
            }

           
            self.coverView.image = leftWidthCoverImage;
            
        }
    _timeLabel.frame = _videoCellFrameModel.timeLabelFrame;
    _timeContainer.frame = _videoCellFrameModel.timeContainerFrame;
    self.iconView.frame = _videoCellFrameModel.iconViewFrame;
    self.picView.frame = _videoCellFrameModel.picViewFrame;
    self.coverView.frame = _videoCellFrameModel.coverViewFrame;
    self.playImageView.frame = _videoCellFrameModel.playImageViewFrame;
    _failureButton.frame = _videoCellFrameModel.failureButtonFrame;
    _activiView.frame = _videoCellFrameModel.activiViewFrame;
    
}


#pragma mark - 单击头像
- (void)toUserInfo
{
    if (_videoCellFrameModel.messageInfoModel.byMySelf == NO) {
        _userInfoCallback(_videoCellFrameModel.messageInfoModel.fromUser);
    }
}


#pragma mark - 视频长按
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

#pragma mark - 下载视频在线播放
- (void)playVideo
{
    _playVideoCallback(_videoCellFrameModel.messageInfoModel);
}

#pragma mark - 重新发送
- (void)sendAgain
{
    _sendAgainCallback(_videoCellFrameModel.messageInfoModel);
}

-(void)sendAgainCallback:(sendAgainCallback)sendAgainCallback playVideoCallback:(playVideoCallback)playVideoCallback longpressCallback:(longpressCallback)longpressCallback userInfoCallback:(userInfoCallback)userInfoCallback deleteCallback:(deleteCallback)deleteCallback{
    _sendAgainCallback = sendAgainCallback;
    _playVideoCallback = playVideoCallback;
    _longpressCallback = longpressCallback;
    _userInfoCallback = userInfoCallback;
    _deleteCallback = deleteCallback;
}

-(void)itemDelete:(UIMenuController *) menu{
    _deleteCallback(_videoCellFrameModel.messageInfoModel);
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
