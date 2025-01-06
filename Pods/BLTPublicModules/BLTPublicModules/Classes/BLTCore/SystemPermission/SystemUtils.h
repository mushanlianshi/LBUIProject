//
//  SystemUtils.h
//  Baletoo_landlord
//
//  Created by baletu on 2018/7/26.
//  Copyright © 2018年 krisc.zampono. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define openNotificationSettingsDate @"openNotificationSettingsDate"

/**
 * 系统工具类 一些 定位 通知等工具
 */
@interface SystemUtils : NSObject

//iOS 判断是否开启定位
+ (BOOL)isLocationServiceOpen;

+ (void)requestLocationPermissionIfNotAuth:(void(^)(CLAuthorizationStatus status))result;

//iOS 判断是否允许消息通知
+ (BOOL)isMessageNotificationServiceOpen;

//iOS 联系人状态判断
+ (BOOL)isContactServiceOpen;

//iOS 跳转系统设置打开定位页面
+ (void)openLocationSettings;

//iOS 跳转系统设置打开消息页面
+ (void)openNotificationSettings;

/** 判断今天是否弹通知提醒框 */
+ (BOOL)todayHasOpenNotifcationAlert;

/** 广告位标识  获取失败传空串给后台 0多余20默认获取*/
+ (NSString *)idfaIndentifier;

@end
