//
//  PhotoBrowser.h
//  SinaGames
//
//  Created by ZhangYingJie on 15/7/8.
//  Copyright (c) 2015年 bond. All rights reserved.
//

#import "MWPhotoBrowser.h"

@class PhotoBrowser;

@protocol DeletePicDelegate <NSObject>

- (void)photoBrowser:(PhotoBrowser *)browser deleteImageForIndex:(NSInteger)index;

@end

@interface PhotoBrowser : MWPhotoBrowser

@property(nonatomic,weak)id<DeletePicDelegate> scanDelegate;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableArray *arr_image;
@property (nonatomic, assign) NSInteger imageCount;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIView *viewBack;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) UIButton *btn_delete;

@property (nonatomic, strong) UIPageControl *pageControl;

+ (void)presentViewController:(UIViewController *)viewController photoSourse:(NSArray *)photoSourse  startIndex:(NSUInteger)startIndex animated:(BOOL) animated delegate:(id<DeletePicDelegate> )delegate type:(NSString *)typeStr completion:(void(^)(PhotoBrowser *browser))completion;

/**
 *  显示图片直接调用此方法
 *
 *  @param viewController 选择弹出控制器，从当前控制器弹出填入self
 *  @param photoSourse    图片数组，元素为Photo类型，如果不是此类型图片则需要实现PhotoBrowserCoverDelegate方法
 *  @param coverDelegate  指定代理
 *  @param startIndex     显示第几页（0起）
 *  @param animated       是否使用动画
 *  @param completion     弹出完成后回调Block
 */
+ (void)presentViewController:(UIViewController *)viewController photoSourse:(NSArray *)photoSourse  startIndex:(NSUInteger)startIndex animated:(BOOL) animated completion:(void(^)(PhotoBrowser *browser))completion;

@end
