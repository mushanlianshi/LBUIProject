//
//  LLLocationUtil.h
//  Baletoo_landlord
//
//  Created by baletu on 2018/8/23.
//  Copyright © 2018年 krisc.zampono. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/** 反向地理编码的回调 */
typedef void(^LocationToAddressBlock)(NSString *city, NSString *detailAddress);

/** 只经纬度的回调 */
typedef void(^LocationPostionBlock)(NSString *lat, NSString *lon);;

/**
 * 定位的工具 要申明成属性   不然请求弹框会一闪而过
 */
@interface LLLocationUtil : NSObject

@property (nonatomic, copy) LocationPostionBlock locationBlock;

@property (nonatomic, assign) BOOL keepRequestLocation; // 持续获取位置

@property (nonatomic, assign) CLLocationDistance distanceFilter;

/**
 开始定位
 */
-(void)startLocation;

/** 开始定位  需要反向地理位置编码   结果在回调里 */
-(void)startLocationNeedDetailAddress:(BOOL)needDetailAddress;

/**
 是否有定位权限
 */
-(BOOL)isHaveAuthLocation;

/** 去到打开定位的界面 */
- (void)goToOpenLocationSettings;

/** 请求权限 */
- (void)requestLocationAuth;

- (void)startLocationResultBlock:(LocationPostionBlock)resultBlock;

- (void)startLocationToAddress:(CLLocation *)location resultBlock:(LocationToAddressBlock)resultBlock;

/** 计算两个经纬度之间的距离 */
+ (CGFloat)distanceFromStartLon:(NSString *)startLon startLat:(NSString *)startLat endLon:(NSString *)endLon endLat:(NSString *)endLat;

@end
