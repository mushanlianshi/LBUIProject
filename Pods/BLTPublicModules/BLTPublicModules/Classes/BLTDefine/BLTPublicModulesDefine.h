//
//  BLTPublicMoudlesDefine.h
//  Pods
//
//  Created by zhaojh on 2022/4/11.
//

#ifndef BLTPublicModulesDefine_h
#define BLTPublicModulesDefine_h

#import "BLTPublicModulesColorDefine.h"
#import "BLTPublicModulesFontDefine.h"

// 适配
#define DEF_Width_SizeFit(args) ((args) / 375.0 * [[UIScreen mainScreen] bounds].size.width)
#define DEF_Height_SizeFit(args) ((args) / 667.0 * [[UIScreen mainScreen] bounds].size.height)
#define DEF_MAX_Width_SizeFit(args) MIN(args, DEF_Width_SizeFit(args))
#define DEF_LittleScreen_Scale(args) ceilf((DEF_SCREEN_WIDTH > 320 ? args : (args)/375.0 * DEF_SCREEN_WIDTH))

// 适配ios11和iPhone X
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)
#define kTopHeight (kStatusBarHeight + kNavBarHeight)
#define kSafeHeight (iPhoneX ? 34.0 : 0.0)
#define kBottomOffset -34.0
#define kBottomButtonY (DEF_SCREEN_HEIGHT - kTopHeight - kTabBarHeight)
#define kBottomSafeHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?34.0f:0)

// 获取window
#define KeyWindow (((AppDelegate *)[UIApplication sharedApplication].delegate).window)

/**
 *  主屏的宽
 */
#define DEF_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

/**
 *  主屏的高
 */
#define DEF_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

/**
 *  主屏的size
 */
#define DEF_SCREEN_SIZE   [[UIScreen mainScreen] bounds].size

#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define IOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 ? YES : NO)   //对ios9 的宏定义
#define IOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0 ? YES : NO)   //对ios10 的宏定义
#define IOS11 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0 ? YES : NO)   //对ios10 的宏定义
#define IOS12 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 12.0 ? YES : NO)
#define IOS13 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0 ? YES : NO)
#define IOS14 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 14.0 ? YES : NO)
#define IOS15 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 15.0 ? YES : NO)
#define IOS16 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 16.0 ? YES : NO)

#define iPhoneX (kStatusBarHeight > 20.0)

#define DEF_SAFE_AREA (iPhoneX ? 34.0 : 0.0)

// number
#define NumberValid(f) ([f isKindOfClass:[NSNumber class]])

// string
#define StrValid(f) (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""])
#define SafeStrRetureZero(f) (NumberValid(f) ? [NSString stringWithFormat:@"%@",f] : (StrValid(f) ? f:@"0"))
#define SafeStrRentureEmpty(f) (NumberValid(f) ? [NSString stringWithFormat:@"%@",f] : (StrValid(f) ? f:@""))
#define SafeStringExist(args) ((args && [args isKindOfClass:[NSString class]] && [args length]) || args && ([args isKindOfClass:[NSNumber class]]) && [args integerValue])

// dictionary
#define SafeDicExist(args) (args && [args isKindOfClass:[NSDictionary class]] && [[args allKeys] count])

// array
#define SafeArrayExist(args) (args && [args isKindOfClass:[NSArray class]] && [args count])

/** 区别于上面的 这个是数组类型就可以  可以是空数组 */
#define SafeArrayType(args) (args && [args isKindOfClass:[NSArray class]])

//版本号
#define blt_app_version  [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]

// weakSelf
#define WeakObject(weakSelf,object)  __weak __typeof(&*object)weakSelf = object;

static inline CGFloat IPHONE_SAFE_BOTTOM_HEIGHT() {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    } else {
        return 0.0;
    }
}

static inline CGFloat IPHONE_STATUS_TOP_HEIGHT() {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
    } else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

static inline CGFloat BLT_IPHONE_TOP_SAFE_HEIGHT() {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
    } else {
        return 0;
    }
}

#endif /* BLTPublicMoudlesDefine_h */
