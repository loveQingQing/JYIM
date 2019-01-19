//
//  JChatLocationViewController.m
//  JYIM
//
//  Created by jy on 2019/1/19.
//  Copyright © 2019年 jy. All rights reserved.
//

#import "JChatLocationViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BMKLocationKit/BMKLocationComponent.h>//引入定位功能所有的头文件


@interface JChatLocationViewController ()<BMKGeneralDelegate,BMKMapViewDelegate,BMKLocationManagerDelegate,BMKLocationAuthDelegate>

@property (nonatomic, strong) BMKMapManager *mapManager; //主引擎类
@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong) BMKLocationManager * locationManager;

@end

@implementation JChatLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"位置";
    
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0, 0, 40, 40);
    UIBarButtonItem * leftBI = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftBI;
    
    
    //要使用百度地图，请先启动BMKMapManager
    _mapManager = [[BMKMapManager alloc] init];
    
    /**
     百度地图SDK所有API均支持百度坐标（BD09）和国测局坐标（GCJ02），用此方法设置您使用的坐标类型.
     默认是BD09（BMK_COORDTYPE_BD09LL）坐标.
     如果需要使用GCJ02坐标，需要设置CoordinateType为：BMK_COORDTYPE_COMMON.
     */
    if ([BMKMapManager setCoordinateTypeUsedInBaiduMapSDK:BMK_COORDTYPE_BD09LL]) {
        NSLog(@"经纬度类型设置成功");
    } else {
        NSLog(@"经纬度类型设置失败");
    }

    //启动引擎并设置AK并设置delegate
    BOOL result = [_mapManager start:BaiduMapKey generalDelegate:self];
    if (!result) {
        NSLog(@"启动引擎失败");
    }
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    //设置mapView的代理
    _mapView.delegate = self;
    //将mapView添加到当前视图中
    [self.view addSubview:_mapView];
    
    if (_locationType == LocationType_show) {
        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D  locationCoordinate = CLLocationCoordinate2DMake([_lat doubleValue], [_lon doubleValue]);
        annotation.coordinate = locationCoordinate;
        annotation.title = _locationDetailStr;
        [_mapView setCenterCoordinate:locationCoordinate];
        [_mapView addAnnotation:annotation];
    }else{
        
        UIButton * sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        sendBtn.frame = CGRectMake(0, 0, 40, 40);
        UIBarButtonItem * rightBI = [[UIBarButtonItem alloc] initWithCustomView:sendBtn];
        self.navigationItem.rightBarButtonItem = rightBI;
        
        //在定位之前，需要先判断鉴权
        [[BMKLocationAuth sharedInstance] checkPermisionWithKey:BaiduMapKey authDelegate:self];
        
        //初始化实例
        _locationManager = [[BMKLocationManager alloc] init];
        //设置delegate
        _locationManager.delegate = self;
        //设置返回位置的坐标系类型
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        //设置距离过滤参数
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        //设置预期精度参数
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设置应用位置类型
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        //设置是否自动停止位置更新
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        //设置是否允许后台定位
        _locationManager.allowsBackgroundLocationUpdates = NO;
        //设置位置获取超时时间
        _locationManager.locationTimeout = 10;
        //设置获取地址信息超时时间
        _locationManager.reGeocodeTimeout = 10;

        [self.locationManager setLocatingWithReGeocode:YES];
        [self.locationManager startUpdatingLocation];
        
    }
    
    
}

- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didUpdateLocation:(BMKLocation * _Nullable)location orError:(NSError * _Nullable)error

{
    if (error)
    {
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    }
    if (location) {//得到定位信息，添加annotation
        
        if (location.rgcData && location.location) {
            NSLog(@"rgc = %@",[location.rgcData description]);
            CLLocationCoordinate2D coordinate = location.location.coordinate;
           
            BMKLocationReGeocode * locationReGeocode = location.rgcData;
            _lat = [NSString stringWithFormat:@"%f",coordinate.latitude];
            _lon = [NSString stringWithFormat:@"%f",coordinate.longitude];
            _locationDetailStr = [NSString stringWithFormat:@"%@%@%@%@",locationReGeocode.province,locationReGeocode.city,locationReGeocode.district,locationReGeocode.street];
            BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
            annotation.coordinate = coordinate;
            annotation.title = _locationDetailStr;
             [_mapView setCenterCoordinate:coordinate];
            [_mapView addAnnotation:annotation];
            
        }
    }
}


/**
 联网结果回调
 
 @param iError 联网结果错误码信息，0代表联网成功
 */
- (void)onGetNetworkState:(int)iError {
    if (0 == iError) {
        NSLog(@"联网成功");
    } else {
        NSLog(@"联网失败：%d", iError);
    }
}

/**
 鉴权结果回调
 
 @param iError 鉴权结果错误码信息，0代表鉴权成功
 */
- (void)onGetPermissionState:(int)iError {
    if (0 == iError) {
        NSLog(@"授权成功");
    } else {
        NSLog(@"授权失败：%d", iError);
    }
}
/**
 *@brief 返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKLocationAuthErrorCode
 */
- (void)onCheckPermissionState:(BMKLocationAuthErrorCode)iError{
    if (BMKLocationAuthErrorSuccess == iError) {
        NSLog(@"鉴权成功");
    }else{
        NSLog(@"鉴权失败");
    }
    
}

-(void)backAction{
    if (_locationType == LocationType_send) {
        //停止持续定位
        [self.locationManager stopUpdatingLocation];

    }else{
        
    }
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)sendAction
{
    if(_locationMessageSendBlock){
        _locationMessageSendBlock(_lat,_lon,_locationDetailStr);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
