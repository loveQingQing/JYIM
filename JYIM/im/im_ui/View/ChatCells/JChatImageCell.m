//
//  JChatImageCell.m
//  JYIM
//
//  Created by jy on 2019/1/16.
//  Copyright © 2019年 jy. All rights reserved.
//

#import "JChatImageCell.h"
#import "JChatImageCellFrameModel.h"
#import "UIImageView+WebCache.h"

@interface JChatImageCell ()

//头像
@property(nonatomic,strong) UIImageView *iconView;
//图片
@property (nonatomic, strong) UIImageView *picView;

//失败按钮
@property (nonatomic, strong) UIButton *failureButton;
//遮罩
@property (nonatomic, strong) UIImageView *coverView;
//时间
@property (nonatomic, strong) UILabel *timeLabel;
//时间容器
@property (nonatomic, strong) UIView *timeContainer;

//菊花
@property (nonatomic, strong) UIActivityIndicatorView *activiView;


//查看大图回调
@property (nonatomic, copy) showBigPicCallback showBigPicCallback;
//长按回调
@property (nonatomic, copy) longpressCallback longpressCallback;
//用户详情回调
@property (nonatomic, copy) userInfoCallback userInfoCallback;
//重新发送回调
@property (nonatomic, copy) sendAgainCallback sendAgainCallback;

@end

@implementation JChatImageCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
            
            self.contentView.backgroundColor = UICOLOR_RGB_Alpha(0xf0f0f0,1);
            [self.contentView addSubview:self.timeContainer];
            [self.timeContainer addSubview:self.timeLabel];
            [self.contentView addSubview:self.iconView];
            [self.contentView addSubview:self.picView];
            [self.picView addSubview:self.coverView];
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
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            ViewRadius(_timeContainer, 5.f);
        });
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


//遮罩
- (UIImageView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIImageView alloc]init];
        _coverView.userInteractionEnabled = YES;
        //添加单击手势,展示大图
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toBigPicture)];
        [_coverView addGestureRecognizer:tap];
        //长按手势
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpressHandle)];
        [_coverView addGestureRecognizer:longpress];
    }
    return _coverView;
}

//失败
- (UIButton *)failureButton
{
    if (!_failureButton) {
        _failureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_failureButton setImage:[UIImage imageNamed:@"发送失败"] forState:UIControlStateNormal];
        [_failureButton addTarget:self action:@selector(sendAgain) forControlEvents:UIControlEventTouchUpInside];
        _failureButton.hidden = YES;//默认隐藏
    }
    return _failureButton;
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

//图片
- (UIImageView *)picView
{
    if (!_picView) {
        _picView = [[UIImageView alloc]init];
        _picView.userInteractionEnabled = YES;
        [_picView addSubview:self.coverView];
    }
    return _picView;
}

//头像
- (UIImageView *)iconView
{
    if (!_iconView) {
        WS(weakSelf)
        _iconView = [[UIImageView alloc]init];
        _iconView.userInteractionEnabled = YES;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            ViewRadius(weakSelf.iconView, 25.f);
        });
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toUserInfo)];
        [_iconView addGestureRecognizer:tap];
        
        //头像长按
        UILongPressGestureRecognizer *iconLongPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(iconLongPress:)];
        [_iconView addGestureRecognizer:iconLongPress];
    }
    return _iconView;
}

-(void)setImageCellFrameModel:(JChatImageCellFrameModel *)imageCellFrameModel{
    WS(weakSelf)
    _imageCellFrameModel = imageCellFrameModel;
    MessageInfoModel * messageInfoModel = _imageCellFrameModel.messageInfoModel;

    //处理时间
    if (messageInfoModel.shouldShowTime) {
        self.timeContainer.hidden = NO;
       
        self.timeLabel.text = [NSDate timeStringWithTimeInterval:messageInfoModel.sendTime];
    }else{
        self.timeContainer.hidden = YES;
       
    }
    //处理失败按钮 , 处理进度按钮 ,昵称隐藏处理
    if (messageInfoModel.byMySelf == YES) {
        if ([messageInfoModel.sendStatus isEqualToString:@"0"]) {
            _failureButton.hidden = NO;
            _activiView.hidden = YES;
            [_activiView stopAnimating];
        }else if ([messageInfoModel.sendStatus isEqualToString:@"1"]){
            _failureButton.hidden = YES;
            _activiView.hidden = YES;
            [_activiView stopAnimating];
        }else{
            _failureButton.hidden = YES;
            _activiView.hidden = NO;
            [_activiView startAnimating];
        }
    }else{
        _failureButton.hidden = YES;
        _activiView.hidden = YES;
        
    }
    
    
    //拉伸遮罩
    UIImage *rightCoverImage = [UIImage imageNamed:@"右－横图片遮罩"];
    UIImage *leftCoverImage    = [UIImage imageNamed:@"左－横图片遮罩"];
    rightCoverImage          = [rightCoverImage stretchableImageWithLeftCapWidth:rightCoverImage.size.width *0.5 topCapHeight:rightCoverImage.size.height *0.5];
    leftCoverImage            = [leftCoverImage stretchableImageWithLeftCapWidth:leftCoverImage.size.width*0.5 topCapHeight:leftCoverImage.size.height*0.5];
    
    //我方图片
    if (_imageCellFrameModel.messageInfoModel.byMySelf) {
        
        //我的头像
        [self.iconView downloadImage:@"我的头像" placeholder:@"userhead"];
        
        //获取本地资源缓存路径
        NSString *imgCachePath = [ChatCache_Path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",_imageCellFrameModel.messageInfoModel.toUser,_imageCellFrameModel.messageInfoModel.picName]];
        
        NSData *picData = [NSData dataWithContentsOfFile:imgCachePath];
        UIImage *image = [UIImage imageWithData:picData];
        if (image) {
            
            self.picView.image = image;
        }else{
            self.picView.image = [UIImage imageNamed:@"照片"];
        }
        
        //遮罩
        self.coverView.image = rightCoverImage;
        
    }else{
        //对方图片
        self.activiView.hidden = YES;
        [self.iconView downloadImage:@"对方头像" placeholder:@"userhead"];
        
        //获取本地资源缓存路径
        NSString *imgCachePath = [ChatCache_Path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",_imageCellFrameModel.messageInfoModel.fromUser,_imageCellFrameModel.messageInfoModel.picName]];
        
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
            [self.picView  sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:messageInfoModel.picUrl] placeholderImage:[UIImage imageNamed:@"照片"] options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.activiView startAnimating];
                });
                
            } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!error){
                        weakSelf.picView.image = image;
                    }
                    [weakSelf.activiView stopAnimating];
                    weakSelf.activiView.hidden = YES;
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
        
        
        //遮罩
        self.coverView.image = leftCoverImage;
    }
    
    self.timeLabel.frame = _imageCellFrameModel.timeLabelFrame;
    self.timeContainer.frame = _imageCellFrameModel.timeContainerFrame;
    self.iconView.frame = _imageCellFrameModel.iconViewFrame;
    self.picView.frame = _imageCellFrameModel.picViewFrame;
    self.activiView.frame = _imageCellFrameModel.activiViewFrame;
    self.coverView.frame = _imageCellFrameModel.coverViewFrame;
    self.failureButton.frame = _imageCellFrameModel.failureButtonFrame;

}




#pragma mark - 头像长按
- (void)iconLongPress:(UILongPressGestureRecognizer *)longpress
{
    
}

#pragma mark - 单击头像
- (void)toUserInfo
{
    if (_imageCellFrameModel.messageInfoModel.byMySelf == NO) {
        _userInfoCallback(_imageCellFrameModel.messageInfoModel.fromUser);
    }
}

#pragma mark - 进入大图查看
- (void)toBigPicture
{
    if (_showBigPicCallback) {
        
        _showBigPicCallback(_imageCellFrameModel.messageInfoModel);
    }
}

#pragma mark - 图片长按
- (void)longpressHandle
{
    
}

#pragma mark - 重新发送
- (void)sendAgain
{
    if (_sendAgainCallback) {
        
        _sendAgainCallback(_imageCellFrameModel.messageInfoModel);
    }
}

#pragma mark - 回调
- (void)sendAgain:(sendAgainCallback)sendAgain showBigPicCallback:(showBigPicCallback)showBigPicCallback longpressCallback:(longpressCallback)longpressCallback toUserInfo:(userInfoCallback)userDetailCallback{
    _sendAgainCallback = sendAgain;
    _showBigPicCallback = showBigPicCallback;
    _longpressCallback = longpressCallback;
    _userInfoCallback = userDetailCallback;
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
