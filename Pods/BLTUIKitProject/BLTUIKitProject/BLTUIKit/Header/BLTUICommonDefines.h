//
//  BLTUICommonDefines.h
//  BLTUIKit
//
//  Created by liu bin on 2020/2/26.
//  Copyright © 2020 liu bin. All rights reserved.
//


/**  一些UI常用的方法   */
#ifndef BLTUICommonDefines_h
#define BLTUICommonDefines_h
#import <objc/runtime.h>
#import "BLTUIKitProject+Private.h"

#define BLT_HEXCOLOR(rgbValue) BLT_HEXCOLORA(rgbValue, 1.0)

#define BLT_HEXCOLORA(rgbValue, a)                                                                                             \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
alpha:a]


#ifdef DEBUG
# define BLT_LOG(fmt, ...) NSLog((@"\n[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DEF_String_VAR(VARNAME) [NSString stringWithFormat:@"%@",@#VARNAME]

#define BLTAssert(condition) assert(condition)

#else
# define BLT_LOG(...) {}
#define BLTAssert(condition) {}
#endif

#define BLT_WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define BLT_ST(strongSelf) __strong __typeof(&*weakSelf)strongSelf = weakSelf;
#define BLT_WEAkOBJECT(weakSelf,object)  __weak __typeof(&*object)weakSelf = object;

#define BLT_DEF_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define BLT_DEF_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

#define BLT_DEF_SCREEN_SIZE   [[UIScreen mainScreen] bounds].size

#define BLT_IS_IPHONEX      BLTIsIPhoneX()

#define BLT_IPHONEX_MARGIN_TOP       44
#define BLT_IPHONEX_MARGIN_BOTTOM      34

#define BLT_SCREEN_BOTTOM_OFFSET (BLT_IS_IPHONEX ? BLT_IPHONEX_MARGIN_BOTTOM : 0)
#define BLT_SCREEN_TOP_OFFSET (BLT_IS_IPHONEX ? BLT_IPHONEX_MARGIN_TOP : 0)
#define BLT_SCREEN_NAVI_HEIGHT (BLT_IS_IPHONEX ? BLT_IPHONEX_MARGIN_TOP + 44 : 64)

CG_INLINE void swizzleInstanceMethod(Class cls, SEL originSelector, SEL swizzleSelector){
    if (!cls) {
        return;
    }
    /* if current class not exist selector, then get super*/
    Method originalMethod = class_getInstanceMethod(cls, originSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzleSelector);
    
    /* add selector if not exist, implement append with method */
    if (class_addMethod(cls,
                        originSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        /* replace class instance method, added if selector not exist */
        /* for class cluster , it always add new selector here */
        class_replaceMethod(cls,
                            swizzleSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        /* swizzleMethod maybe belong to super */
        class_replaceMethod(cls,
                            swizzleSelector,
                            class_replaceMethod(cls,
                                                originSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}

CG_INLINE void blt_dispatch_main_sync_safe(dispatch_block_t safeBlock){
    if(!safeBlock){
        return;
    }
    if ([NSThread isMainThread]) {
        safeBlock();
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            safeBlock();
        });
    }
}

#pragma mark - 设备判断
CG_INLINE BOOL BLTIsIPhoneX(){
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    return iPhoneXSeries;
}

#pragma mark - 字体
CG_INLINE UIFont *UIFontPFFontSize(CGFloat x){
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:x] ? [UIFont fontWithName:@"PingFangSC-Regular" size:x] : [UIFont systemFontOfSize:x];
    return font;
}

CG_INLINE UIFont *UIFontPFBoldFontSize(CGFloat x){
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Semibold" size:x] ? [UIFont fontWithName:@"PingFangSC-Semibold" size:x] : [UIFont boldSystemFontOfSize:x];
    return font;
}

CG_INLINE UIFont *UIFontPFMediumFontSize(CGFloat x){
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Medium" size:x] ? [UIFont fontWithName:@"PingFangSC-Medium" size:x] : [UIFont systemFontOfSize:x];
    return font;
}


CG_INLINE UIImage * UIImageNamed(NSString *imageName){
    return [UIImage imageNamed:imageName];
}

CG_INLINE UIImage* UIImageNamedFromBLTUIKItBundle(NSString *imageName){
    NSBundle *BLTUIKitBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:NSClassFromString(@"BLTAlertController")] pathForResource:@"BLTUIKitBundle" ofType:@"bundle"]];
    NSString *imageFullName = [NSString stringWithFormat:@"%@@%zdx",imageName, (NSInteger)[UIScreen mainScreen].scale];
    return [[UIImage imageWithContentsOfFile:[BLTUIKitBundle pathForResource:imageFullName ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


CG_INLINE UIImage* UIImageFromBundle(NSString *imageName, NSString *bundleName){
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"]];
    NSString *imageFullName = [NSString stringWithFormat:@"%@@%zdx",imageName,(NSInteger)[UIScreen mainScreen].scale];
    return [[UIImage imageWithContentsOfFile:[bundle pathForResource:imageFullName ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

CG_INLINE UIImage *UIImageFromFileName(NSString *fileName){
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@%zdx",fileName,(NSInteger)[UIScreen mainScreen].scale] ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}


CG_INLINE CGFloat BLTLineViewHeight(){
    return 1.0 / [UIScreen mainScreen].scale;
}

/** 判断字符串是否存在 */
CG_INLINE BOOL NSStringIsExist(id string){
    if (string && [string isKindOfClass:[NSString class]] && ([string length] > 0)) {
        return YES;
    }
    return NO;
}

CG_INLINE BOOL NSDictionaryIsExist(NSDictionary *dictionary){
    if (dictionary && [dictionary isKindOfClass:[NSDictionary class]] && dictionary.allKeys.count > 0) {
        return YES;
    }
    return NO;
}

CG_INLINE BOOL NSArrayIsExist(NSArray *array){
    if (array && [array isKindOfClass:[NSArray class]] && array.count > 0) {
        return YES;
    }
    return NO;
}


typedef NS_ENUM(NSInteger, LLMoneyStyleType){
    LLMoneyStyleTypeDefault = 0,    //默认不处理小数个数的
    LLMoneyStyleTypeTwoPoint,       //保留两位小数的格式的
    LLMoneyStyleTypeDeleteLastZore, //去除后面.00的最后面的00的
};
/** 服务器返回的金钱转换*/
CG_INLINE NSString *StringFromMoneyWithStyle(id money,LLMoneyStyleType styleType){
    NSString *originalMoney = @"";
    if ([money isKindOfClass:[NSString class]] && [money length]) {
        originalMoney = money;
    }else if ([money isKindOfClass:[NSNumber class]]){
        originalMoney = [NSString stringWithFormat:@"%.3f",[money doubleValue]];
    }else{
        originalMoney = @"0";
    }
    
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:originalMoney];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.maximumFractionDigits = 2;
    formatter.minimumIntegerDigits = 1;
    if (styleType == LLMoneyStyleTypeDefault) {
        return originalMoney;
    }else if (styleType == LLMoneyStyleTypeTwoPoint){
        formatter.minimumFractionDigits = 2;
        formatter.minimumIntegerDigits = 1;
    }else if (styleType == LLMoneyStyleTypeDeleteLastZore){
        
//        return [number stringValue];
    }
    NSString *numberStr = [formatter stringFromNumber:number];
    return numberStr;
}

/** 服务器返回的金钱转换*/
CG_INLINE NSString *StringFromMoneyWithStyleWithFormatter(id money,LLMoneyStyleType styleType, NSNumberFormatterStyle style){
    NSString *originalMoney = @"";
    if ([money isKindOfClass:[NSString class]] && [money length]) {
        originalMoney = money;
    }else if ([money isKindOfClass:[NSNumber class]]){
        originalMoney = [NSString stringWithFormat:@"%.3f",[money doubleValue]];
    }else{
        originalMoney = @"0";
    }
    
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:originalMoney];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.maximumFractionDigits = 2;
    formatter.minimumIntegerDigits = 1;
    formatter.numberStyle = style;
    if (styleType == LLMoneyStyleTypeDefault) {
        return originalMoney;
    }else if (styleType == LLMoneyStyleTypeTwoPoint){
        formatter.minimumFractionDigits = 2;
        formatter.minimumIntegerDigits = 1;
    }else if (styleType == LLMoneyStyleTypeDeleteLastZore){
        
//        return [number stringValue];
    }
    NSString *numberStr = [formatter stringFromNumber:number];
    return numberStr;
}

/** 可变字典添加键值对的 */
CG_INLINE void NSMutableDictionaryAddKeyValue(NSMutableDictionary *dic, NSString *key, id value){
//#ifdef DEBUG
    if (!dic || ![dic isKindOfClass:[NSMutableDictionary class]]) {
        return;
    }
    if (!value || ![value isKindOfClass:[NSObject class]]) {
        return;
    }
    [dic setValue:value forKey:key];
//#endif
    
//    @try {
//        [dic setObject:value forKey:key];
//    }
//    @catch (NSException *exception) {
//        BLTAssert(0);
//        [BLTUIKitProject catchException:exception];
//    }
//    @finally{
//
//    }
}

/** 字典取值的 */
CG_INLINE id NSDictionaryObjetForKey(NSDictionary *dic, NSString *key){
    if (!dic || ![dic isKindOfClass:[NSDictionary class]] || dic.allKeys.count <= 0) {
        [BLTUIKitProject catchException:[NSException exceptionWithName:@"NSDictionary is not correct" reason:@"NSDictionary is not correct" userInfo:nil]];
        return nil;
    }
    return [dic objectForKey:key];
}

/** 数组添加  获取object的 */
CG_INLINE void NSMutableArrayAddObject(NSMutableArray *array, id object){
    if (!array || (![array isKindOfClass:[NSMutableArray class]])) {
        return;
    }
    if (object && [object isKindOfClass:[NSObject class]]) {
        [array addObject:object];
    }
}

CG_INLINE id NSArrayObjectAtIndex(NSArray *array, NSInteger index){
    if (!array || !([array isKindOfClass:[NSArray class]]) || index >= array.count) {
        [BLTUIKitProject catchException:[NSException exceptionWithName:@"NSArray is not correct" reason:@"NSArray is not correct" userInfo:nil]];
        BLTAssert(0);
        return nil;
    }
    return array[index];
}



#endif /* BLTUICommonDefines_h */
