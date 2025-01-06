//
//  LLLocationUtil.m
//  Baletoo_landlord
//
//  Created by baletu on 2018/8/23.
//  Copyright © 2018年 krisc.zampono. All rights reserved.
//

#import "LLLocationUtil.h"
#import "BLTPublicModulesLogDefine.h"
#import "BLTPublicModulesDefine.h"

@interface LLLocationUtil ()<CLLocationManagerDelegate>

@property(nonatomic,strong)CLLocationManager *locationManager;

/** 是否需要反向地理编码 */
@property (nonatomic, assign) BOOL needDetailAddress;

/** 用来判断第一次定位授权是否授权还是没授权的 */
@property (nonatomic, copy) NSString *status;

@end

@implementation LLLocationUtil

- (instancetype)init
{
    self = [super init];
    if (self) {
        _keepRequestLocation = NO;
        _distanceFilter = 10.0f;
    }
    return self;
}

-(void)startLocation{
    //每次开始的时候设置delegate = self； 获取到定位的时候delegate =nil  防止触发多次 didUpdateLocations
    self.locationManager.delegate = self;
    [self startLocationNeedDetailAddress:NO];
}

/** 开始定位  需要反向地理位置编码   结果在回调里 */
-(void)startLocationNeedDetailAddress:(BOOL)needDetailAddress{
    _needDetailAddress = needDetailAddress;
    if (![self isHaveAuthLocation]) {
        return;
    }
    float version=[[[UIDevice currentDevice] systemVersion] floatValue];
    if (version>8.0){
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    CLAuthorizationStatus authorization=[CLLocationManager authorizationStatus];
    if (authorization < kCLAuthorizationStatusAuthorizedAlways) {
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"getAddress" object:@"权限未开启"];
        return;
    }
    //开始定位  IOS8以后可以请求权限
    [self.locationManager startUpdatingLocation];
}

/** 判断用户权限发生变化 */
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"用户授权发生变化了 %d ",status);
    if (status == kCLAuthorizationStatusNotDetermined) {
        self.status = @"0";
    }else if (status == kCLAuthorizationStatusDenied && [self.status isEqualToString:@"0"]){
        [self firstDenyAuth];
    }else if ((status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) && [self.status isEqualToString:@"0"]){
        [self firstAuthSuccess];
    }
}

- (void)firstDenyAuth{
}

- (void)firstAuthSuccess{
    [self.locationManager startUpdatingLocation];
}

/**
 * 用户位置更新了触发的协议 和设置最小多少更新有关 变化10米触发
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{

    if (!self.keepRequestLocation) {
        // 如果只是定位  获取位置信息后停止更新  防止多次触发没必要
        [_locationManager stopUpdatingLocation];
        ////每次开始的时候设置delegate = self； 获取到定位的时候delegate =nil  防止触发多次 didUpdateLocations
        _locationManager.delegate = nil;
    }
    //获取当前的位置
    CLLocation *location=[locations lastObject];
    NSString *lat = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    NSString *altitude = [NSString stringWithFormat:@"%f",location.altitude];
    DEF_DEBUG(@"lat is %@ ",lat);
    DEF_DEBUG(@"lon is %@ ",lon);
    DEF_DEBUG(@"latitude is %@ ",altitude);
    if (self.locationBlock) {
        self.locationBlock(lat, lon);
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"getLoation" object:location];
    //反地理编码  placemark中包含信息
    if (self.needDetailAddress) {
        [self startLocationToAddress:location resultBlock:^(NSString *city, NSString *detailAddress) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getAddress" object:city];
        }];
    }
}

- (void)startLocationResultBlock:(LocationPostionBlock)resultBlock{
    [self startLocation];
    self.locationBlock = resultBlock;
}


#pragma mark - 反地址编码
- (void)startLocationToAddress:(CLLocation *)location resultBlock:(LocationToAddressBlock)resultBlock{
    //获取经纬度之后 反地理编码
    CLGeocoder *geocoder=[[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error){
        if (error==nil) {
            NSLog(@"反地理编码");
            if ([placemarks count]>0) {
                //这个类是反地理编码后的信息封装的类
                CLPlacemark *mark=[placemarks lastObject];
                NSDictionary *infoDic=[mark addressDictionary];
                NSLog(@"info DIC IS %@ ",infoDic);
                NSString *city=[infoDic objectForKey:@"City"];
                //中国上海市浦东新区金桥经济技术开发区杨高中路789号
                NSString *name=[infoDic objectForKey:@"Name"];
                NSString *Street=[infoDic objectForKey:@"Street"];
                NSString *Thoroughfare=[infoDic objectForKey:@"Thoroughfare"];
                NSString *SubLocality=[infoDic objectForKey:@"SubLocality"];
                NSString *detailAddress = infoDic[@"FormattedAddressLines"];
                DEF_DEBUG(@"LBLog detail address %@ %@ %@ %@ %@",name,Street,Thoroughfare,SubLocality,detailAddress);
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"getAddress" object:name];
                
                if (resultBlock) {
                    resultBlock(city,detailAddress);
                }
            }
        }else{
            NSLog(@"反地理编码失败===");
            if (resultBlock) {
                resultBlock(nil, nil);
            }
        }
    }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"定位失败======= error is %@ ",error);
    [_locationManager stopUpdatingLocation];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"getAddress" object:@"定位失败"];
}

-(void)dealloc{
    NSLog(@"LBLog locationUtls dealloc==========");
}

-(BOOL)isHaveAuthLocation{
    if (![CLLocationManager locationServicesEnabled]) {
        return NO;
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}

- (void)goToOpenLocationSettings{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

/** 请求权限 */
- (void)requestLocationAuth{
    [self.locationManager requestWhenInUseAuthorization];
}

- (CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager=[[CLLocationManager alloc] init];
//        _locationManager.delegate=self;
        //设置定位精度十米左右
        _locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
        //位置变化超过10米 才触发协议
        _locationManager.distanceFilter=self.distanceFilter;
    }
    return _locationManager;
}


/** 计算两个经纬度之间的距离 */
+ (CGFloat)distanceFromStartLon:(NSString *)startLon startLat:(NSString *)startLat endLon:(NSString *)endLon endLat:(NSString *)endLat{
    if (!SafeStringExist(startLat) || !SafeStringExist(startLon) || !SafeStringExist(endLon) || !SafeStringExist(endLat)) {
        return NSNotFound;
    }
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:startLat.floatValue longitude:startLon.floatValue];
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:endLat.floatValue longitude:endLon.floatValue];
    return [startLocation distanceFromLocation:endLocation];
}

@end
