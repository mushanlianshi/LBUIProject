//
//  SystemUtils.m
//  Baletoo_landlord
//
//  Created by baletu on 2018/7/26.
//  Copyright © 2018年 krisc.zampono. All rights reserved.
//

#import "SystemUtils.h"
#import <AddressBook/AddressBook.h>
#import <AdSupport/AdSupport.h>
#import "BLTPublicModulesDefine.h"

@implementation SystemUtils

//iOS 判断是否开启定位
+ (BOOL)isLocationServiceOpen {
    if ([ CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return NO;
    } else
        return YES;
}

+ (void)requestLocationPermissionIfNotAuth:(void (^)(CLAuthorizationStatus))result{
    if (!result) {
        return;
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        [[[CLLocationManager alloc] init] requestWhenInUseAuthorization];
    }
    result([CLLocationManager authorizationStatus]);
}
//iOS 判断是否允许消息通知
+ (BOOL)isMessageNotificationServiceOpen {
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        return [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    } else {
        return UIRemoteNotificationTypeNone != [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    }
}

//iOS 联系人状态判断
+ (BOOL)isContactServiceOpen{
    ABAuthorizationStatus authStatus =
    ABAddressBookGetAuthorizationStatus();
    if (authStatus == kABAuthorizationStatusAuthorized) {
        return YES;
    }else{
        return NO;
    }
}

//iOS 跳转系统设置打开定位页面
+ (void)openLocationSettings{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if (IOS10) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }else{
                [[UIApplication sharedApplication] openURL:url];
            }
            
        }
    }
}


//iOS 跳转系统设置打开消息页面
+ (void)openNotificationSettings{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (IOS10) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }else{
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

+ (BOOL)todayHasOpenNotifcationAlert{
    NSString *openDate = [[NSUserDefaults standardUserDefaults] valueForKey:openNotificationSettingsDate];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *today = [df stringFromDate:[NSDate date]];
    if (SafeStringExist(openDate) && [today isEqualToString:openDate]) {
        return  YES;
    }
    return NO;
}


/** 广告位标识  获取失败传空串给后台 0多余20默认获取*/
+ (NSString *)idfaIndentifier{
    NSString
    *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    if (!idfa || [idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"] || [idfa isEqualToString:@"00000000000000000000000000000000"]) {
        idfa = @"";
    }
    return idfa;
}

@end
