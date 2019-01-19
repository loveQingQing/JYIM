//
//  ChatKeyboard.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/15.
//  Copyright © 2017年 mengyao. All rights reserved.
//


#import "ChatKeyboard.h"
#import "ChatRecordTool.h"
#import "UIImage+photoPicker.h"
#import "ChatAlbumModel.h"
#import "EmotionTextAttachment.h"
#import "TZImageManager.h"
#import "TZImagePickerController.h"
#import "JChatLocationViewController.h"

@interface ChatHandleButton : UIButton
@end
@implementation ChatHandleButton
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, 60, 60);  //图片 60.60
    self.titleLabel.frame   = CGRectMake(0, CGRectGetMaxY(self.imageView.frame)+5,CGRectGetWidth(self.imageView.frame), 12); //固定高度12
}

@end

//记录当前键盘的高度 ，键盘除了系统的键盘还有咱们自定义的键盘，互相来回切换



@interface ChatKeyboard ()<UITextViewDelegate,UIScrollViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>




//消息回调
@property (nonatomic, copy) ChatTextMessageSendBlock textCallback;
@property (nonatomic, copy) ChatAudioMesssageSendBlock audioCallback;
@property (nonatomic, copy) ChatPictureMessageSendBlock pictureCallback;
@property (nonatomic, copy) ChatVideoMessageSendBlock videoCallback;
@property (nonatomic, copy) ChatLocationMessageSendBlock locationCallback;

@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic,assign) BOOL keyboardIsShow;
@property (nonatomic, strong) id target;

 //表情键盘
@property (nonatomic, strong) UIView *facesKeyboard;
//按钮 (拍照,视频,相册)
@property (nonatomic, strong) UIView *handleKeyboard;
//自定义键盘容器
@property (nonatomic, strong) UIView *keyBoardContainer;
//顶部消息操作栏
@property (nonatomic, strong) UIView *messageBar;
//表情容器
@property (nonatomic, strong) UIScrollView *emotionScrollView;
//表情键盘底部操作栏
@property (nonatomic, strong) UIView *emotionBottonBar;
//指示器
@property (nonatomic, strong) UIPageControl *emotionPgControl;
//语音按钮
@property (nonatomic, strong) UIButton *audioButton;
//长按说话按钮
@property (nonatomic, strong) UIButton *audioLpButton;
//表情按钮
@property (nonatomic, strong) UIButton *swtFaceButton;
//加号按钮
@property (nonatomic, strong) UIButton *swtHandleButton;
//输入框
@property (nonatomic, strong) UITextView *msgTextView;
//录音工具(需引用)
@property (nonatomic, strong) ChatRecordTool *recordTool;


@end

@implementation ChatKeyboard

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _keyboardIsShow = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
       
        [self addSubview:self.messageBar];
        [self addSubview:self.keyBoardContainer];
        self.keyBoardContainer.hidden = YES;
        //布局
        [self configUIFrame];
    }
    return self;
}



- (void)keyboardWillShow:(NSNotification *)notification
{
    
    _keyboardIsShow = YES;
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = keyboardFrame.size.height;
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:7];
    self.top = keyboardFrame.origin.y - self.messageBar.height;
    [UIView commitAnimations];
//     [self reloadSwitchButtons];
    if (self.keyboardViewFrameChange) {
        self.keyboardViewFrameChange(self.frame);
    }
    
}
- (void)keyboardWillHidden:(NSNotification *)notification
{
    _keyboardIsShow = NO;
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [self.msgTextView resignFirstResponder];
    //按钮初始化刷新
//    [self reloadSwitchButtons];
    [self customKeyboardMove:self.superview.height - self.messageBar.height - SafeAreaBottomHeight];
    _keyBoardContainer.hidden = YES;//wb
    if (self.keyboardViewFrameChange) {
        self.keyboardViewFrameChange(self.frame);
    }
}
//录音工具
- (ChatRecordTool *)recordTool
{
    if (!_recordTool) {
        _recordTool = [ChatRecordTool chatRecordTool];
    }
    return _recordTool;
}

//表情资源plist (因为表情存在版权问题 , 所以这里的表情只用一个来代替)
- (NSDictionary *)emotionDict
{
    if (!_emotionDict) {
        _emotionDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ChatEmotions" ofType:@"plist"]];
    }
    return _emotionDict;
}

//pageControl
- (UIPageControl *)emotionPgControl
{
    if (!_emotionPgControl) {
        _emotionPgControl = [[UIPageControl alloc]init];
        _emotionPgControl.pageIndicatorTintColor = UICOLOR_RGB_Alpha(0xcecece, 1);
        _emotionPgControl.currentPageIndicatorTintColor = UICOLOR_RGB_Alpha(0x999999, 1);
    }
    return _emotionPgControl;
}


//表情键盘底部操作栏 (表情键盘底部的操作栏 , 可以添加更多的操作按钮 ,类似微信那样 , 只需要再添加 和facesKeyboard handleKeyboard平级的view即可 , 几个键盘来回切换)
- (UIView *)emotionBottonBar
{
    if (!_emotionBottonBar) {
        _emotionBottonBar = [[UIView alloc]init];
        _emotionBottonBar.backgroundColor = [UIColor whiteColor];
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton setTitleColor:UICOLOR_RGB_Alpha(0x333333, 1) forState:UIControlStateNormal];
        sendButton.frame = CGRectMake(ScreenWidth - 85, 0, 60, 30);
        [sendButton addTarget:self action:@selector(sendEmotionMessage:) forControlEvents:UIControlEventTouchUpInside];
        ViewBorder(sendButton, UICOLOR_RGB_Alpha(0x333333, 1), 1);
        ViewRadius(sendButton, 5);
        [_emotionBottonBar addSubview:sendButton];
    }
    return _emotionBottonBar;
}

//表情滚动容器
- (UIScrollView *)emotionScrollView
{
    if (!_emotionScrollView) {
        _emotionScrollView = [[UIScrollView alloc]init];
        _emotionScrollView.backgroundColor = [UIColor whiteColor];
        _emotionScrollView.showsHorizontalScrollIndicator = NO;
        _emotionScrollView.pagingEnabled = YES;
        _emotionScrollView.delegate = self;
        //最多几列
        NSUInteger columnMaxCount = 8;
        //最多几行
        NSUInteger rowMaxCount = 3;
        //一页表情最多多少个
        NSUInteger emotionMaxCount = columnMaxCount *rowMaxCount;
        //左右边距
        CGFloat lrMargin = 15.f;
        //顶部边距
        CGFloat topMargin = 20.f;
        //宽高
        CGFloat widthHeight = 30.f;
        //中间间距
        CGFloat midMargin = (ScreenWidth - columnMaxCount*widthHeight - 2*lrMargin)/(columnMaxCount - 1);
        //计算一共多少页表情
        NSInteger pageCount = self.emotionDict.count / emotionMaxCount + (self.emotionDict.count %emotionMaxCount > 0 ? 1 : 0);
        //滑动范围
        _emotionScrollView.contentSize = CGSizeMake(pageCount *ScreenWidth, 0);
        
        //布局
        //当前第几个表情
        NSUInteger emotionIdx = 0;
        //index 当前第几页
        for (NSInteger index = 0; index < pageCount; index ++) {
            UIView *emotionContainer = [[UIView alloc]init];
            //添加表情按钮
            for (NSInteger i = 0; i < emotionMaxCount; i ++) {
                NSInteger row    = i % columnMaxCount;
                NSInteger colum = i / columnMaxCount;
                UIButton *emotionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                emotionBtn.tag = 999 + emotionIdx;
                NSString *emotionImgName = [self.emotionDict objectForKey:[NSString stringWithFormat:@"ChatEmotion_%li",emotionIdx]];
                [emotionBtn setImage:[UIImage imageNamed:emotionImgName] forState:UIControlStateNormal];
                emotionBtn.frame = CGRectMake(lrMargin + row *(widthHeight + midMargin), topMargin + colum*(widthHeight + midMargin), widthHeight, widthHeight);
                [emotionBtn addTarget:self action:@selector(emotionClick:) forControlEvents:UIControlEventTouchUpInside];
                [emotionContainer addSubview:emotionBtn];
                emotionIdx ++ ;
            }
            [_emotionScrollView addSubview:emotionContainer];
        }
    }
    return _emotionScrollView;
}
//表情键盘
- (UIView *)facesKeyboard
{
    if (!_facesKeyboard) {
        _facesKeyboard = [[UIView alloc]init];
        _facesKeyboard.backgroundColor = [UIColor whiteColor];
        //添加表情滚动容器
        [_facesKeyboard addSubview:self.emotionScrollView];
        //添加底部操作栏
        [_facesKeyboard addSubview:self.emotionBottonBar];
        //指示器pageControl
        [_facesKeyboard addSubview:self.emotionPgControl];
    }
    return _facesKeyboard;
}

//操作按钮键盘
- (UIView *)handleKeyboard
{
    if (!_handleKeyboard) {
        _handleKeyboard = [[UIView alloc]init];
        _handleKeyboard.backgroundColor = [UIColor whiteColor];
        NSArray *buttonNames = @[@"照片",@"拍摄",@"视频",@"位置"];
        NSInteger btnCount = buttonNames.count;
        CGFloat btnLeft = 30;
        CGFloat btnTop = 15.f;
        for (NSInteger index = 0; index < btnCount; index ++) {
            
            ChatHandleButton *handleButton = [ChatHandleButton buttonWithType:UIButtonTypeCustom];
            handleButton.titleLabel.font = [UIFont systemFontOfSize:12];
            handleButton.tag = 9999 + index;
            [handleButton setTitleColor:UICOLOR_RGB_Alpha(0x666666, 1) forState:UIControlStateNormal];;
            handleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            [handleButton setTitle:buttonNames[index] forState:UIControlStateNormal];
            [handleButton setImage:[UIImage imageNamed:buttonNames[index]] forState:UIControlStateNormal];
            if (btnLeft + 60.f + 25.f <= ScreenWidth) {
               
            }else{
                btnLeft = 30;
                btnTop = btnTop + 77 + 10;
            }
            handleButton.frame = CGRectMake(btnLeft, btnTop, 60, 77);
            btnLeft = btnLeft + 60.f + 25.f;
            
            [_handleKeyboard addSubview:handleButton];
            [handleButton addTarget:self action:@selector(handleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _handleKeyboard;
}

//自定义
- (UIView *)keyBoardContainer
{
    if (!_keyBoardContainer) {
        _keyBoardContainer = [[UIView alloc]init];
        [_keyBoardContainer addSubview:self.facesKeyboard];
        [_keyBoardContainer addSubview:self.handleKeyboard];
    }
    return _keyBoardContainer;
}

//输入栏
- (UIView *)messageBar
{
    if (!_messageBar) {
        _messageBar = [[UIView alloc]init];
        _messageBar.backgroundColor = UICOLOR_RGB_Alpha(0xe6e6e6, 1);
        [_messageBar addSubview:self.audioButton];
        [_messageBar addSubview:self.msgTextView];
        [_messageBar addSubview:self.audioLpButton];
        [_messageBar addSubview:self.swtFaceButton];
        [_messageBar addSubview:self.swtHandleButton];
    }
    return _messageBar;
}

//输入框
- (UITextView *)msgTextView
{
    if (!_msgTextView) {
        _msgTextView = [[UITextView alloc]init];
        _msgTextView.font = [UIFont systemFontOfSize:14.0];
        _msgTextView.showsVerticalScrollIndicator = NO;
        _msgTextView.showsHorizontalScrollIndicator = NO;
        _msgTextView.returnKeyType = UIReturnKeySend;
        _msgTextView.enablesReturnKeyAutomatically = YES;
        _msgTextView.delegate = self;
        ViewRadius(_msgTextView, 5);
        //观察者监听高度变化
        [_msgTextView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return _msgTextView;
}

//语音按钮
- (UIButton *)audioButton
{
    if (!_audioButton) {
        _audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_audioButton setImage:[UIImage imageNamed:@"语音"] forState:UIControlStateNormal];
        [_audioButton addTarget:self action:@selector(audioButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _audioButton;
}

//表情切换按钮
- (UIButton *)swtFaceButton
{
    if (!_swtFaceButton) {
        _swtFaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_swtFaceButton setImage:[UIImage imageNamed:@"表情"] forState:UIControlStateNormal];
        [_swtFaceButton addTarget:self action:@selector(switchFaceKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _swtFaceButton;
}

//切换操作键盘
- (UIButton *)swtHandleButton
{
    if (!_swtHandleButton) {
        _swtHandleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_swtHandleButton setImage:[UIImage imageNamed:@"加号"] forState:UIControlStateNormal];
        [_swtHandleButton addTarget:self action:@selector(switchHandleKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _swtHandleButton;
}

//长按录音按钮
- (UIButton *)audioLpButton
{
    if (!_audioLpButton) {
        _audioLpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_audioLpButton setTitle:@"按住说话" forState:UIControlStateNormal];
        [_audioLpButton setTitle:@"松开发送" forState:UIControlStateHighlighted];
        [_audioLpButton setTitleColor:UICOLOR_RGB_Alpha(0x333333, 1) forState:UIControlStateNormal];
        _audioLpButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        //默认隐藏
        _audioLpButton.hidden = YES;
        //边框,切角
        ViewBorder(_audioLpButton, UICOLOR_RGB_Alpha(0x999999, 1), 1);
        ViewRadius(_audioLpButton, 5);
        //按下录音按钮
        [_audioLpButton addTarget:self action:@selector(audioLpButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        //手指离开录音按钮 , 但不松开
        [_audioLpButton addTarget:self action:@selector(audioLpButtonMoveOut:) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchDragOutside];
        //手指离开录音按钮 , 松开
        [_audioLpButton addTarget:self action:@selector(audioLpButtonMoveOutTouchUp:) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchCancel];
        //手指回到录音按钮,但不松开
        [_audioLpButton addTarget:self action:@selector(audioLpButtonMoveInside:) forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragEnter];
        //手指回到录音按钮 , 松开
        [_audioLpButton addTarget:self action:@selector(audioLpButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _audioLpButton;
}



#pragma mark - 初始化布局
- (void)configUIFrame
{
    self.messageBar.frame = CGRectMake(0, 0, ScreenWidth, defaultMsgBarHeight);  //消息栏
    self.audioButton.frame = CGRectMake(10, (CGRectGetHeight(self.messageBar.frame) - 30)*0.5, 30, 30); //语音按钮
    self.audioLpButton.frame = CGRectMake(CGRectGetMaxX(self.audioButton.frame)+15,(CGRectGetHeight(self.messageBar.frame)-defaultInputHeight)*0.5, ScreenWidth - 155, defaultInputHeight); //长按录音按钮
    self.msgTextView.frame = self.audioLpButton.frame;  //输入框
    self.swtFaceButton.frame  = CGRectMake(CGRectGetMaxX(self.msgTextView.frame)+15, (CGRectGetHeight(self.messageBar.frame)-30)*0.5,30, 30); //表情键盘切换按钮
    self.swtHandleButton.frame = CGRectMake(CGRectGetMaxX(self.swtFaceButton.frame)+15, (CGRectGetHeight(self.messageBar.frame)-30)*0.5, 30, 30); //加号按钮切换操作键盘
     self.keyBoardContainer.frame = CGRectMake(0,CGRectGetHeight(self.messageBar.frame), ScreenWidth,CTKEYBOARD_DEFAULTHEIGHT - CGRectGetHeight(self.messageBar.frame)); //自定义键盘容器
    self.handleKeyboard.frame = self.keyBoardContainer.bounds ;//键盘操作栏
    self.facesKeyboard.frame = self.keyBoardContainer.bounds ; //表情键盘部分
    
    //表情容器部分
    self.emotionScrollView.frame =CGRectMake(0,0, ScreenWidth, CGRectGetHeight(self.facesKeyboard.frame)-45); //表情滚动容器
    for (NSInteger index = 0; index < self.emotionScrollView.subviews.count; index ++) { //emotion容器
        UIView *emotionView = self.emotionScrollView.subviews[index];
        emotionView.frame = CGRectMake(index *ScreenWidth, 0, ScreenWidth, CGRectGetHeight(self.emotionScrollView.frame));
    }
    //页码
    self.emotionPgControl.numberOfPages = self.emotionScrollView.subviews.count;
    CGSize controlSize = [self.emotionPgControl sizeForNumberOfPages:self.emotionScrollView.subviews.count];
    self.emotionPgControl.frame = CGRectMake((ScreenWidth - controlSize.width)*0.5,CGRectGetHeight(self.emotionScrollView.frame)-controlSize.height, controlSize.width, controlSize.height); // pageControl
    self.emotionBottonBar.frame = CGRectMake(0,CGRectGetMaxY(self.emotionScrollView.frame), ScreenWidth, 40); //底部操作栏  固定 40高度
}


#pragma mark - 语音按钮点击
- (void)audioLpButtonTouchDown:(UIButton *)audioLpButton
{
    [self.recordTool beginRecord];
}
#pragma mark - 手指离开录音按钮 , 但不松开
- (void)audioLpButtonMoveOut:(UIButton *)audioLpButton
{
    [self.recordTool moveOut];
}
#pragma mark - 手指离开录音按钮 , 松开
- (void)audioLpButtonMoveOutTouchUp:(UIButton *)audioLpButton
{
    [self.recordTool cancelRecord];
    //手动释放一下,每次录音创建新的蒙板,避免过多处理 定时器和子控件逻辑
    self.recordTool = nil;
}
#pragma mark - 手指回到录音按钮,但不松开
- (void)audioLpButtonMoveInside:(UIButton *)audioLpButton
{
    [self.recordTool continueRecord];
}
#pragma mark - 手指回到录音按钮 , 松开
- (void)audioLpButtonTouchUpInside:(UIButton *)audioLpButton
{
    [self.recordTool stopRecord:^(NSData *audioData, NSInteger seconds) {
        
        //回调语音消息
        ChatAlbumModel *audio = [[ChatAlbumModel alloc]init];
        audio.audioData = audioData;
        audio.duration   = [@(seconds)stringValue];
        _audioCallback(audio);
    }];
    //手动释放一下,每次录音创建新的蒙板,避免过多处理 定时器和子控件逻辑
    self.recordTool = nil;
}
#pragma mark - 切换到表情键盘
- (void)switchFaceKeyboard:(UIButton *)swtFaceButton
{
    swtFaceButton.selected = !swtFaceButton.selected;
    //重置其他按钮seleted
    self.audioButton.selected = NO;
    self.swtHandleButton.selected = NO;
    
    if (swtFaceButton.selected) {
        _msgTextView.hidden = NO;
        _audioLpButton.hidden  = YES;
        [_msgTextView resignFirstResponder];
        //展示表情键盘
        [self.keyBoardContainer bringSubviewToFront:self.facesKeyboard];
        //自定义键盘位移
        [self customKeyboardMove:ScreenHeight - CGRectGetHeight(self.frame)];
        _keyBoardContainer.hidden = NO;//wb
    }else{
        [_msgTextView becomeFirstResponder];
        _keyBoardContainer.hidden = YES;//wb
    }
}
#pragma mark - 切换到操作键盘
- (void)switchHandleKeyboard:(UIButton *)swtHandleButton
{
    swtHandleButton.selected = !swtHandleButton.selected;
    //重置其他按钮selected
    self.audioButton.selected = NO;
    self.swtFaceButton.selected = NO;
    
    if (swtHandleButton.selected) {
        _msgTextView.hidden = NO;
        _audioLpButton.hidden = YES;
        
        [_msgTextView resignFirstResponder];
        //展示操作键盘
        [self.keyBoardContainer bringSubviewToFront:self.handleKeyboard];
        //自定义键盘位移
        [self customKeyboardMove:ScreenHeight - CGRectGetHeight(self.frame)];
        _keyBoardContainer.hidden = NO;//wb
    }else{
        _keyBoardContainer.hidden = YES;//wb
        [_msgTextView becomeFirstResponder];
    }
}
#pragma mark - 切换至语音录制
- (void)audioButtonClick:(UIButton *)audioButton
{
    self.keyBoardContainer.hidden = YES;
    audioButton.selected = !audioButton.selected;
     //重置其他按钮selected
    self.swtFaceButton.selected = NO;
    self.swtHandleButton.selected = NO;
    
    if (audioButton.selected) {
        [_msgTextView resignFirstResponder];
        self.msgTextView.hidden = YES;
        self.audioLpButton.hidden = NO;
        [self customKeyboardMove:self.superview.height - defaultMsgBarHeight - SafeAreaBottomHeight]; //默认高度 输入栏 49
        if (self.keyboardViewFrameChange) {
            self.keyboardViewFrameChange(self.frame);
        }
        
    }else{
        self.msgTextView.hidden = NO;
        self.audioLpButton.hidden = YES;
        [self.msgTextView becomeFirstResponder];
    }
    audioButton.selected = !_msgTextView.isFirstResponder;
}

#pragma mark - 自定义键盘位移变化
- (void)customKeyboardMove:(CGFloat)customKbY
{
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(0,customKbY, ScreenWidth, CGRectGetHeight(self.frame));
        
    }];
}

#pragma mark - 监听输入框变化 (这里如果放到layout里自动让他布局 , 会稍显麻烦一些 , 所以自动手动控制一下)
//这里用contentSize计算较为简单和精确 , 如果计算文字高度 ,  还需要加上textView的内间距.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    CGFloat oldHeight  = [change[@"old"]CGSizeValue].height;
    CGFloat newHeight = [change[@"new"]CGSizeValue].height;
    if (oldHeight <=0 || newHeight <=0) return;
    NSLog(@"------new ----%@",change[@"new"]);
    NSLog(@"-------old ---%@",change[@"old"]);
    if (newHeight != oldHeight) {
        NSLog(@"高度变化");
        //根据实时的键盘高度进行布局
        CGFloat inputHeight = newHeight > defaultInputHeight ? newHeight : defaultInputHeight;
        [self msgTextViewHeightFit:inputHeight];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //删除键监听
    if ([text isEqualToString:@""""]) {
        
        NSLog(@"----------------点击了系统键盘删除键");
        //系统键盘删除
        [self keyboardDelete];
        return NO;
        
    //发送键监听
    }else if ([text isEqualToString:@"\n"]){
        
        //发送普通文本消息
        [self sendTextMessage];
        return NO;
    }
    return YES;
}

#pragma mark - 切换按钮初始化
- (void)reloadSwitchButtons
{
    self.audioButton.selected        = NO;
    self.swtFaceButton.selected    = NO;
    self.swtHandleButton.selected = NO;
}

#pragma mark - 输入框高度调整
- (void)msgTextViewHeightFit:(CGFloat)msgViewHeight
{
    self.messageBar.frame = CGRectMake(0, 0, ScreenWidth, msgViewHeight +CGRectGetMinY(self.msgTextView.frame)*2);
    self.msgTextView.frame = CGRectMake(CGRectGetMinX(self.msgTextView.frame),(CGRectGetHeight(self.messageBar.frame)-msgViewHeight)*0.5, CGRectGetWidth(self.msgTextView.frame), msgViewHeight);
    self.keyBoardContainer.frame = CGRectMake(0, CGRectGetMaxY(self.messageBar.frame), ScreenWidth, CGRectGetHeight(self.keyBoardContainer.frame));
    self.frame = CGRectMake(0,self.superview.height - (_keyboardIsShow ? _keyboardHeight : _keyBoardContainer.height) -CGRectGetHeight(self.messageBar.frame), ScreenWidth,CGRectGetHeight(self.keyBoardContainer.frame) + CGRectGetHeight(self.messageBar.frame));
    if (self.keyboardViewFrameChange) {
        self.keyboardViewFrameChange(self.frame);
    }
}

#pragma mark - 拍摄 , 照片 ,视频按钮点击
- (void)handleButtonClick:(ChatHandleButton *)button
{
    WS(weakSelf)
    switch (button.tag - 9999) {
        case 0:
        {
            // 这里用到了阿里巴巴TZImagerPicker 相册选择器 写得挺好的 ，我对它进行了封装和修改了里面一些代码 。 后期有时间会自己写一个相册的选择器
            [UIImage openPhotoPickerGetImages:^(NSArray<ChatAlbumModel *> *images) {
                
                //回调发送
                if (weakSelf.pictureCallback) {
                    weakSelf.pictureCallback(images);
                }
            } target:self.target maxCount:9];
            NSLog(@"-------------点击了相册");
        }
            break;
        case 1:
        {
            NSLog(@"-------------点击了拍照");
            [self takePhotoWithTarget:self.target images:^(NSArray<ChatAlbumModel *> *images) {
                if (weakSelf.pictureCallback) {
                    weakSelf.pictureCallback(images);
                }
            }];
        }
            break;
        case 2:
        {
            [UIImage openPhotoPickerGetVideo:^(ChatAlbumModel *videoModel) {
                if (weakSelf.videoCallback) {
                    weakSelf.videoCallback(videoModel);
                }
            } target:_target];
            NSLog(@"-------------点击了视频相册");
        }
            break;
        case 3:
        {
            NSLog(@"-------------点击了地址");
            if (self.locationCallback) {
                
                JChatLocationViewController * vc = [[JChatLocationViewController alloc] init];
                vc.locationType = LocationType_send;
                vc.locationMessageSendBlock = ^(NSString * _Nonnull lat, NSString * _Nonnull lon, NSString * _Nonnull detailStr) {
                    if (weakSelf.locationCallback) {
                        
                        weakSelf.locationCallback(lat,lon,detailStr);
                    }
                };
                UIViewController * viewController = weakSelf.target;
                
                [viewController.navigationController pushViewController:vc animated:YES];
                
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - 点击表情
- (void)emotionClick:(UIButton *)emotionBtn
{
    //获取点击的表情
    NSString *emotionKey = [NSString stringWithFormat:@"ChatEmotion_%li",emotionBtn.tag - 999];
    NSString *emotionName = [self.emotionDict objectForKey:emotionKey];
    
    //判断是删除 ， 还是点击了正常的emotion表情
    if ([emotionName isEqualToString:@"[del_]"]) {
        
        //表情键盘删除
        [self keyboardDelete];
        
    }else{ //点击表情
        
//        //获取光标所在位置
//        NSInteger location = self.msgTextView.selectedRange.location;
//        //变为可变字符串
//        NSMutableString *txtStrM = [[NSMutableString alloc]initWithString:self.msgTextView.text];
//        [txtStrM insertString:emotionName atIndex:location];
//        self.msgTextView.text = txtStrM;
//        //光标后移
//        self.msgTextView.selectedRange = NSMakeRange(location + emotionName.length, 0);
        NSLog(@"--------当前点击了表情 : ------------------%@",emotionName);
        
        NSMutableAttributedString *oldmsgAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.msgTextView.attributedText];
        
        //创建包含TextAttachment附件的attributedString
        EmotionTextAttachment * emotionTextAttachment = [[EmotionTextAttachment alloc] init];
        emotionTextAttachment.emotionName = emotionName;
        CGFloat fontHeight = self.msgTextView.font.lineHeight;
        
        NSAttributedString * attachmentAttributedString = [[NSAttributedString alloc] init];
        
       UIImage * emotionImg = [UIImage imageNamed:emotionName];
        emotionTextAttachment.image = emotionImg;
        emotionTextAttachment.bounds = CGRectMake(0, -4, fontHeight, fontHeight);
        attachmentAttributedString = [NSAttributedString attributedStringWithAttachment:emotionTextAttachment];
        //        }
        
        //获取光标的位置,在当前光标出插入图片
        NSRange currentRange = self.msgTextView.selectedRange;
        
        //合并包含TextAttachment附件的attributedString,赋值给textView
        [oldmsgAttributedString replaceCharactersInRange:NSMakeRange(currentRange.location, 0) withAttributedString:attachmentAttributedString];
        [oldmsgAttributedString addAttribute:NSFontAttributeName value:self.msgTextView.font range:NSMakeRange(0, oldmsgAttributedString.length)];
        self.msgTextView.attributedText = oldmsgAttributedString;
        
        //光标下移
        self.msgTextView.selectedRange = NSMakeRange(currentRange.location + 1,0);
        
    }
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.emotionPgControl.currentPage = scrollView.contentOffset.x / ScreenWidth;
}

#pragma mark - 表情发送按钮点击
- (void)sendEmotionMessage:(UIButton *)emotionSendBtn
{
    [self sendTextMessage];
}

#pragma mark - 键盘删除内容
- (void)keyboardDelete
{
    
    if (self.msgTextView.attributedText) {
        //当前光标的位置
        NSRange currentRange = self.msgTextView.selectedRange;
        NSAttributedString *beforeAttributedString = [self.msgTextView.attributedText attributedSubstringFromRange:NSMakeRange(0, currentRange.location)];
        NSAttributedString *afterAttributedString = [self.msgTextView.attributedText attributedSubstringFromRange:NSMakeRange(currentRange.location , self.msgTextView.attributedText.length - beforeAttributedString.length)];
        
        //如果前半部分没有内容,就不处理了
        if (beforeAttributedString.length <= 0) {
            return;
        }
        //光标前部分的beforeAttributedString减少一个(emoji字符占两个字节)//判断即将被删除的是一个字和图片,还是emoji
        NSRange lastRange = [beforeAttributedString.string rangeOfComposedCharacterSequenceAtIndex:beforeAttributedString.string.length -1];
        beforeAttributedString = [beforeAttributedString attributedSubstringFromRange:NSMakeRange(0, beforeAttributedString.length - lastRange.length)];
        
        //前后两部分合并赋值给textView
        NSMutableAttributedString *resultAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:beforeAttributedString];
        [resultAttributedString appendAttributedString:afterAttributedString];
        self.msgTextView.attributedText = resultAttributedString;
        
        //光标前移
        self.msgTextView.selectedRange = NSMakeRange(currentRange.location - lastRange.length,0);
    }
}

#pragma mark - 发送文本/表情消息
- (void)sendTextMessage
{
    __block NSString *publishString = @"";
    [self.msgTextView.attributedText enumerateAttributesInRange:NSMakeRange(0, self.msgTextView.attributedText.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        if (attrs[@"NSAttachment"]) {//图片替换成对应的文字
            EmotionTextAttachment *textAttachment = attrs[@"NSAttachment"];
            if (textAttachment.emotionName) {
                publishString = [publishString stringByAppendingString:textAttachment.emotionName];
            }
        } else {//文字或者表情
            NSString *subString = [self.msgTextView.text substringWithRange:range];
            publishString = [publishString stringByAppendingString:subString];
        }
    }];
   
    
    //回调
    if (![publishString isEqualToString:@""] && _textCallback) {
        _textCallback(publishString);
        self.msgTextView.attributedText = [[NSAttributedString alloc] initWithString:@""];
        self.msgTextView.text = @"";
        
        self.messageBar.frame = CGRectMake(0, 0, ScreenWidth, defaultMsgBarHeight);
    
        self.msgTextView.frame = CGRectMake(CGRectGetMaxX(self.audioButton.frame)+15,(CGRectGetHeight(self.messageBar.frame)-defaultInputHeight)*0.5, ScreenWidth - 155, defaultInputHeight);  //输入框
        self.frame = CGRectMake(0,self.superview.height - CGRectGetHeight(self.messageBar.frame) - SafeAreaBottomHeight, ScreenWidth,CGRectGetHeight(self.keyBoardContainer.frame) + CGRectGetHeight(self.messageBar.frame));
        if (self.keyboardViewFrameChange) {
            self.keyboardViewFrameChange(self.frame);
        }
        
    }
}

#pragma mark - 消息回调
- (void)textCallback:(ChatTextMessageSendBlock)textCallback audioCallback:(ChatAudioMesssageSendBlock)audioCallback picCallback:(ChatPictureMessageSendBlock)picCallback videoCallback:(ChatVideoMessageSendBlock)videoCallback locationCallback:(ChatLocationMessageSendBlock)locationCallback target:(id)target
{
    _textCallback     = textCallback;
    _audioCallback   = audioCallback;
    _pictureCallback = picCallback;
    _videoCallback   = videoCallback;
    _locationCallback = locationCallback;
    _target              = target;
}

- (void)dealloc
{
    [self.msgTextView removeObserver:self forKeyPath:@"contentSize"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)closeKeyboardContainer{
    if (_swtFaceButton.selected == YES) {
        self.swtFaceButton.selected = NO;
        //自定义键盘位移
        [self customKeyboardMove:self.superview.height - SafeAreaBottomHeight - defaultMsgBarHeight];
        _keyBoardContainer.hidden = YES;//wb
        
        if (self.keyboardViewFrameChange) {
            self.keyboardViewFrameChange(self.frame);
        }
    }
    if (_swtHandleButton.selected == YES) {
        
        self.swtHandleButton.selected = NO;
        [self customKeyboardMove:self.superview.height - SafeAreaBottomHeight - defaultMsgBarHeight];
        _keyBoardContainer.hidden = YES;//wb
        if (self.keyboardViewFrameChange) {
            self.keyboardViewFrameChange(self.frame);
        }
    }
}

/**
 相机
 拍照后回调
 */
-(void)takePhotoWithTarget:(UIViewController *)target images:(photoPickerImagesCallback)imagesCallBack{
    
    [self takePhotoWithTarget:target];
}

- (void)takePhotoWithTarget:(UIViewController *)target{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            
        }];
        [alertController addAction:setAction];
        [alertController addAction:cancelAction];
        
        [target presentViewController:alertController animated:YES completion:nil];
        
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self takePhotoWithTarget:target];
                });
            }
        }];
        // 拍照之前还需要检查相册权限
    } else if ([PHPhotoLibrary authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            
        }];
        [alertController addAction:setAction];
        [alertController addAction:cancelAction];
        
        [target presentViewController:alertController animated:YES completion:nil];
        
    } else if ([PHPhotoLibrary authorizationStatus] == 0) { // 未请求过相册权限
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhotoWithTarget:target];
        }];
    } else {
        [self pushImagePickerControllerWithTarget:target];
    }
}

// 调用相机
- (void)pushImagePickerControllerWithTarget:(UIViewController *)viewController{
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController * imagePickerVc = [[UIImagePickerController alloc] init];
        imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        //        imagePickerVc.navigationBar.barTintColor = kNavigationBackColor;
        //        imagePickerVc.navigationBar.tintColor = kFontWhiteColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (@available(iOS 9, *)) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
        imagePickerVc.sourceType = sourceType;
        NSMutableArray *mediaTypes = [NSMutableArray array];
        
        [mediaTypes addObject:(NSString *)kUTTypeImage];
        
        if (mediaTypes.count) {
            imagePickerVc.mediaTypes = mediaTypes;
        }
        [viewController presentViewController:imagePickerVc animated:YES completion:nil];
        
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        ChatAlbumModel * imageModel = [[ChatAlbumModel alloc] init];
        imageModel.picSize = image.size;
        imageModel.normalPicData = UIImageJPEGRepresentation(image, 0.7);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd-HH:mm:ss"];
        NSDate *datenow = [NSDate date];
        NSString *currentTimeString = [formatter stringFromDate:datenow];
        imageModel.name = [NSString stringWithFormat:@"%@.png",currentTimeString];
        if (_pictureCallback) {
            _pictureCallback(@[imageModel]);
        }
    }
    
}
@end
