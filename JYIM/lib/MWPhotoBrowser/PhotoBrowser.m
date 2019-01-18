//
//  PhotoBrowser.m
//  SinaGames
//
//  Created by ZhangYingJie on 15/7/8.
//  Copyright (c) 2015年 bond. All rights reserved.
//

#import "PhotoBrowser.h"
#import "MWPhotoBrowserPrivate.h"



@interface PhotoBrowser ()<MWPhotoBrowserDelegate>
{
    CGRect _startRect;
    NSArray *_photoSourse;
    
}

@end

@implementation PhotoBrowser

+(PhotoBrowser *)sharedInstence
{
    static id instense;
    if (instense == nil) {
        instense = [[self alloc] init];
    }
    return instense;
}

- (NSArray *)photoSourse {
    
    if (!_photoSourse) {
        _photoSourse = [NSArray array];
    }
    return _photoSourse;
}

+ (void)presentViewController:(UIViewController *)viewController photoSourse:(NSArray *)photoSourse  startIndex:(NSUInteger)startIndex animated:(BOOL) animated delegate:(id<DeletePicDelegate>)delegate  type:(NSString *)typeStr completion:(void(^)(PhotoBrowser *browser))completion{
    [self sharedInstence].scanDelegate = delegate;
    [self sharedInstence].type = typeStr;
    
    [self presentViewController:viewController photoSourse:photoSourse startIndex:startIndex animated:YES completion:completion];
    
}


+ (void)presentViewController:(UIViewController *)viewController photoSourse:(NSArray *)photoSourse startIndex:(NSUInteger)startIndex animated:(BOOL)animated completion:(void (^)(PhotoBrowser *))completion{
    
    PhotoBrowser *browser = [PhotoBrowser browserWithPhotos:photoSourse];
   
    

    if ([browser.type isEqualToString:@"1"]) {
        browser.zoomPhotosToFill = YES;
        browser.alwaysShowControls = YES;
        browser.displayNavArrows = NO;
        browser.enableGrid = NO;
    } else {
        browser.zoomPhotosToFill = YES;
        browser.alwaysShowControls = NO;
        browser.displayNavArrows = NO;
        browser.enableGrid = NO;
        browser.displaySelectionButtons = NO;
    }
    NSAssert(startIndex < photoSourse.count  , @"索引不得大于等于图片个数");
    
    if (startIndex < photoSourse.count) {
        
        [browser setCurrentPhotoIndex:startIndex];
    }
    
    [browser reloadData];
    
    browser.modalPresentationStyle = UIModalPresentationFullScreen;
    browser.modalTransitionStyle =  UIModalTransitionStyleCrossDissolve;
    
    [viewController presentViewController:browser animated:animated completion:^{
        if (completion) {
            completion(browser);
        }
    }];
    
    browser.arr_image = [NSMutableArray arrayWithArray:photoSourse];
    browser.imageCount = photoSourse.count;
    browser.index = startIndex+1;
    [browser setToolBarView];
}

- (void)setToolBarView{
    _viewBack= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    _viewBack.center = CGPointMake(30, 40);
    _viewBack.backgroundColor = [UIColor clearColor];
    _viewBack.alpha = 0.6;
    [self.view addSubview:_viewBack];
    
    _pageControl = [[UIPageControl alloc]init];
    _pageControl.frame = CGRectMake(0, ScreenHeight-30, ScreenWidth, 10);
    _pageControl.numberOfPages = self.imageCount;
    _pageControl.currentPage = self.index-1;
    _pageControl.defersCurrentPageDisplay = YES;
    [self.view addSubview:_pageControl];
    _pageControl.hidden = YES;
    if (self.imageCount>1) {
        self.pageControl.hidden = NO;
    }
    
    
    
    //
    _btn_delete = [[UIButton alloc] init];
    [_btn_delete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    _btn_delete.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1];
    _btn_delete.frame = CGRectMake(ScreenWidth - 40, 25, 30, 30);
    _btn_delete.clipsToBounds = YES;
    _btn_delete.titleLabel.textAlignment = NSTextAlignmentRight;
    [_btn_delete setBackgroundImage:[UIImage imageNamed:@"delete@2x.png"] forState:UIControlStateNormal];
    [_btn_delete addTarget:self action:@selector(deleteImage) forControlEvents:UIControlEventTouchUpInside];
    
    if ([_type isEqualToString:@"1"]) {
        
    } else {
        [self.view addSubview:_btn_delete];

    }
}

+ (instancetype)browserWithPhotos:(NSArray *)photos
{
    PhotoBrowser *browser = [self sharedInstence];
   
    return [browser initWithSNPhotos:photos];
}

- (instancetype)initWithSNPhotos:(NSArray *)photos
{
    if (self = [super initWithDelegate:self]) {

        NSMutableArray *arrM = [NSMutableArray array];
        
        for (id result in photos) {
                MWPhoto *photo = nil;
            if ([result isKindOfClass:[UIImage class]]) { //图片类型
                photo = [MWPhoto photoWithImage:result];
            }else if([result isKindOfClass:[NSURL class]]){ //url 类型
                photo = [MWPhoto photoWithURL:result];
            }else if ([result isKindOfClass:[NSString class]]) {//string类型
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:result]];
            }else { //类型不匹配
            }
            [arrM addObject:photo];
        }
        _photoSourse = arrM.copy;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    [super scrollViewDidScroll:scrollView];
    NSInteger page = scrollView.contentOffset.x/ScreenWidth+1;
    _index = page;
    if (page == 0) {
        return;
    }
    _pageControl.currentPage = page-1;
    [_pageControl updateCurrentPageDisplay];
}

- (void)deleteImage{
    [_indexLabel removeFromSuperview];
    [_viewBack removeFromSuperview];
    [_btn_delete removeFromSuperview];
    [_pageControl removeFromSuperview];
    if ([self.scanDelegate respondsToSelector:@selector(photoBrowser:deleteImageForIndex:)]) {
            [self dismissViewControllerAnimated:YES completion:NULL];
            return  [self.scanDelegate photoBrowser:self deleteImageForIndex:_index];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
    return;
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.photoSourse.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    return [self.photoSourse objectAtIndex:index];
}

//重写父类方法 退出
- (void)toggleControls
{
    [_indexLabel removeFromSuperview];
    [_viewBack removeFromSuperview];
    [_btn_delete removeFromSuperview];
    [_pageControl removeFromSuperview];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
