//
//  HQFontImage.h
//  IconFont
//
//  Created by hqlulu on 16/7/10.
//  Copyright © 2016年 Taodiandian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBCityIconFont.h"

@interface HQFontImage : NSObject

/**
 获取对应图片icon文本
 */
+ (NSString *)nameToUnicode:(NSString *)name;

/**
 获取图片icon字符串，name不存在，则拼接name
 */
+ (NSString *)namesToUnicodes:(NSArray <NSString *> *)names;

/// 获取图片（正方形）
/// @param name 图片名称
/// @param size 大小
/// @param color 颜色
// @param inset 边缘空白间隔
// @param paddingPercent 填充百分比
// @param backgroundColor 图片背景色
+ (UIImage *)iconWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color;
+ (UIImage *)iconWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color padding:(CGFloat)paddingPercent;
+ (UIImage *)iconWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color inset:(UIEdgeInsets)inset;

//自定义背景色
+ (UIImage *)iconWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color withBackgroundColor:(UIColor*)backgroundColor;
+ (UIImage *)iconWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color padding:(CGFloat)paddingPercent withBackgroundColor:(UIColor*)backgroundColor;
+ (UIImage *)iconWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color inset:(UIEdgeInsets)inset withBackgroundColor:(UIColor*)backgroundColor;


/**
 根据设置高度，以及文本原始高宽比设置图片大小，当图片不是正方形时，取高度（1倍图），得到fontSize
 */
+ (UIImage *)iconDefaultAspectRatioWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color;
+ (UIImage *)iconDefaultAspectRatioWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor*)color padding:(CGFloat)paddingPercent;
+ (UIImage *)iconDefaultAspectRatioWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor*)color inset:(UIEdgeInsets)inset;

+ (UIImage *)iconDefaultAspectRatioWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color withBackgroundColor:(UIColor*)backgroundColor;
+ (UIImage *)iconDefaultAspectRatioWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color padding:(CGFloat)paddingPercent withBackgroundColor:(UIColor *)backgroundColor;
+ (UIImage *)iconDefaultAspectRatioWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color inset:(UIEdgeInsets)inset withBackgroundColor:(UIColor *)backgroundColor;

/**
 将参数转换成自定义url，部分情况需要将imageName放入对象，后通过imageWithName转换成图片时，通过改方法得到自定义url，然后通过 UIImage+BLTIconfontImage 中的 `-blt_imageWithCodeString:` 方法可转换成图片，该方法可区分原始图片的name和自定义url
 */
+ (NSString *)codeStringWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color defaultAspectRatio:(BOOL)isDefaultAspectRatio;
+ (NSString *)codeStringWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color padding:(CGFloat)paddingPercent defaultAspectRatio:(BOOL)isDefaultAspectRatio;
+ (NSString *)codeStringWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color inset:(UIEdgeInsets)inset defaultAspectRatio:(BOOL)isDefaultAspectRatio;

+ (NSString *)codeStringWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color padding:(CGFloat)paddingPercent withBackgroundColor:(UIColor *)backgroundColor defaultAspectRatio:(BOOL)isDefaultAspectRatio;
+ (NSString *)codeStringWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color withBackgroundColor:(UIColor *)backgroundColor defaultAspectRatio:(BOOL)isDefaultAspectRatio;
+ (NSString *)codeStringWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color inset:(UIEdgeInsets)inset withBackgroundColor:(UIColor *)backgroundColor defaultAspectRatio:(BOOL)isDefaultAspectRatio;

@end
