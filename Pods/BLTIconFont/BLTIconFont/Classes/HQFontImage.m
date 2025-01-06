//
//  HQFontImage.m
//  IconFont
//
//  Created by hqlulu on 16/7/10.
//  Copyright © 2016年 Taodiandian. All rights reserved.
//

#import "HQFontImage.h"
#import "TBCityIconInfo.h"

@implementation HQFontImage

+ (NSDictionary *)IconDictionary
{
    return @{};
}

+ (NSString*)fontName
{
    return nil;
}

+ (NSString *)nameToUnicode:(NSString*)name
{
    NSDictionary *nameToUnicode = [self IconDictionary];
    NSString *code = nameToUnicode[name];
    return code ?: name;
}

+ (NSString *)namesToUnicodes:(NSArray<NSString *> *)names
{
    NSDictionary *nameToUnicode = [self IconDictionary];
    __block NSString *namesStr = @"";
    [names enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        namesStr = [namesStr stringByAppendingFormat:@"%@",(nameToUnicode[obj] ? : obj)];
    }];
    return namesStr;
}

+ (UIImage *)iconWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color
{
    return [self iconWithName:name fontSize:size color:color inset:UIEdgeInsetsZero withBackgroundColor:nil];
}

+ (UIImage *)iconWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color padding:(CGFloat)paddingPercent
{
    CGFloat padding = size * paddingPercent;
    UIEdgeInsets inset = UIEdgeInsetsMake(padding, padding, padding, padding);
    return [self iconWithName:name fontSize:size color:color inset:inset withBackgroundColor:nil];
}

+ (UIImage *)iconWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color inset:(UIEdgeInsets)inset
{
    return [self iconWithName:name fontSize:size color:color inset:inset withBackgroundColor:nil];
}

+ (UIImage *)iconWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color withBackgroundColor:(UIColor*)backgroundColor
{
    return [self iconWithName:name fontSize:size color:color inset:UIEdgeInsetsZero withBackgroundColor:backgroundColor];
}

+ (UIImage *)iconWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color padding:(CGFloat)paddingPercent withBackgroundColor:(UIColor*)backgroundColor
{
    CGFloat padding = size * paddingPercent;
    UIEdgeInsets inset = UIEdgeInsetsMake(padding, padding, padding, padding);
    return [self iconWithName:name fontSize:size color:color inset:inset withBackgroundColor:backgroundColor];
}


//主方法
+ (UIImage *)iconWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color inset:(UIEdgeInsets)inset withBackgroundColor:(UIColor*)backgroundColor
{
    NSString *code = [self nameToUnicode:name];
    TBCityIconInfo *info = [TBCityIconInfo iconInfoWithText:code size:size color:color inset:inset];
    if (backgroundColor) {
        info.backgroundColor = backgroundColor;
    }
    NSString *fontName = [self fontName];
    info.fontName = fontName ? : nil;
    return [UIImage iconWithInfo:info];
}

+ (UIImage *)iconDefaultAspectRatioWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color
{
    return [self iconDefaultAspectRatioWithName:name fontSize:size color:color inset:UIEdgeInsetsZero withBackgroundColor:nil];
}

+ (UIImage *)iconDefaultAspectRatioWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color padding:(CGFloat)paddingPercent
{
    CGFloat padding = size * paddingPercent;
    UIEdgeInsets inset = UIEdgeInsetsMake(padding, padding, padding, padding);
    return [self iconDefaultAspectRatioWithName:name fontSize:size color:color inset:inset withBackgroundColor:nil];
}

+ (UIImage *)iconDefaultAspectRatioWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color inset:(UIEdgeInsets)inset
{
    return [self iconDefaultAspectRatioWithName:name fontSize:size color:color inset:inset withBackgroundColor:nil];
}

+ (UIImage *)iconDefaultAspectRatioWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color withBackgroundColor:(UIColor *)backgroundColor
{
    return [self iconDefaultAspectRatioWithName:name fontSize:size color:color inset:UIEdgeInsetsZero withBackgroundColor:backgroundColor];
}

+ (UIImage *)iconDefaultAspectRatioWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color padding:(CGFloat)paddingPercent withBackgroundColor:(UIColor *)backgroundColor
{
    CGFloat padding = size * paddingPercent;
    UIEdgeInsets inset = UIEdgeInsetsMake(padding, padding, padding, padding);
    return [self iconDefaultAspectRatioWithName:name fontSize:size color:color inset:inset withBackgroundColor:backgroundColor];
}

//主方法
+ (UIImage *)iconDefaultAspectRatioWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color inset:(UIEdgeInsets)inset withBackgroundColor:(UIColor*)backgroundColor
{
    // 处理某些图片存在切边问题
    UIEdgeInsets changeInset = inset;
    // 处理图片
    if (inset.bottom == 0) {
        changeInset.bottom = 1.0;
    }
    if (inset.top == 0) {
        changeInset.top = 1.0;
    }
    if (inset.left == 0) {
        changeInset.left = 1.0;
    }
    if (inset.right == 0) {
        changeInset.right = 1.0;
    }

    
    NSString *code = [self nameToUnicode:name];
    CGRect codeRect = [code boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName:[UIFont fontWithName:[self fontName] size:size]} context:nil];
    CGSize codeSize = codeRect.size;
    if (codeRect.size.height > codeRect.size.width) {
        codeSize = CGSizeMake(codeRect.origin.x + codeSize.width, codeSize.height);
    }
    TBCityIconInfo *info = [TBCityIconInfo iconInfoWithText:code size:size color:color inset:changeInset];
    info.codeSize = codeSize;
    if (backgroundColor) {
        info.backgroundColor = backgroundColor;
    }
    NSString *fontName = [self fontName];
    info.fontName = fontName ? : nil;
    return [UIImage iconDefaultAspectRatioWithInfo:info];
}

/**
 将参数转换自定义url
 */
+ (NSString *)codeStringWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color defaultAspectRatio:(BOOL)isDefaultAspectRatio
{
    return [self codeStringWithName:name fontSize:size color:color inset:UIEdgeInsetsZero withBackgroundColor:nil defaultAspectRatio:isDefaultAspectRatio];
}

+ (NSString *)codeStringWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color padding:(CGFloat)paddingPercent defaultAspectRatio:(BOOL)isDefaultAspectRatio
{
    CGFloat padding = size * paddingPercent;
    UIEdgeInsets inset = UIEdgeInsetsMake(padding, padding, padding, padding);
    return [self codeStringWithName:name fontSize:size color:color inset:inset withBackgroundColor:nil defaultAspectRatio:isDefaultAspectRatio];
}

+ (NSString *)codeStringWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color inset:(UIEdgeInsets)inset defaultAspectRatio:(BOOL)isDefaultAspectRatio
{
    return [self codeStringWithName:name fontSize:size color:color inset:inset withBackgroundColor:nil defaultAspectRatio:isDefaultAspectRatio];
}

+ (NSString *)codeStringWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color withBackgroundColor:(UIColor *)backgroundColor defaultAspectRatio:(BOOL)isDefaultAspectRatio
{
    return [self codeStringWithName:name fontSize:size color:color inset:UIEdgeInsetsZero withBackgroundColor:backgroundColor defaultAspectRatio:isDefaultAspectRatio];
}

+ (NSString *)codeStringWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color padding:(CGFloat)paddingPercent withBackgroundColor:(UIColor *)backgroundColor defaultAspectRatio:(BOOL)isDefaultAspectRatio
{
    CGFloat padding = size * paddingPercent;
    UIEdgeInsets inset = UIEdgeInsetsMake(padding, padding, padding, padding);
    return [self codeStringWithName:name fontSize:size color:color inset:inset withBackgroundColor:backgroundColor defaultAspectRatio:isDefaultAspectRatio];
}

+ (NSString *)codeStringWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color inset:(UIEdgeInsets)inset withBackgroundColor:(UIColor *)backgroundColor defaultAspectRatio:(BOOL)isDefaultAspectRatio
{
    // 如果必要参数不存在则返回nil
    if (!name || !color || !size) {
        return @"";
    }
    NSMutableString *codeString = [NSMutableString stringWithFormat:@"%@://name=%@&fontSize=%@",NSStringFromClass([self class]),name,@(size)];
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    [codeString appendFormat:@"&redColor=%@&greenColor=%@&blueColor=%@&colorAlpha=%@",@(r * 255),@(g * 255),@(b * 255),@(a)];
    
    if (backgroundColor) {
        CGFloat bgr,bgg,bgb,bga;
        [backgroundColor getRed:&bgr green:&bgg blue:&bgb alpha:&bga];
        [codeString appendFormat:@"&redBackgroundColor=%@&greenBackgroundColor=%@&blueBackgroundColor=%@&backgroundColorAlpha=%@",@(bgr * 255),@(bgg * 255),@(bgb * 255),@(bga)];
    }
    if (!UIEdgeInsetsEqualToEdgeInsets(inset, UIEdgeInsetsZero)) {
        [codeString appendFormat:@"&inset=%@",NSStringFromUIEdgeInsets(inset)];
    }
    [codeString appendFormat:@"&defaultAspectRatio=%@",@(isDefaultAspectRatio)];
    return [codeString copy];
}

@end
