//
//  BLTIconFontModel.h
//  Baletu
//
//  Created by 尹星 on 2020/2/18.
//  Copyright © 2020 朱 亮亮. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BLTIconFontModel : NSObject

/**
 iconfont对应的类名
 */
@property (nonatomic, copy) NSString                                     *iconfontClassName;

/**
 iconfont映射名称
 */
@property (nonatomic, copy) NSString                                      *name;

/**
 iconfont字体大小
 */
@property (nonatomic, assign) CGFloat                                     fontSize;

/**
 iconfont字体颜色
 */
@property (nonatomic, strong) UIColor                                     *color;

/**
 iconfont转图片，周边间距
 */
@property (nonatomic, assign) UIEdgeInsets                                inset;

/**
 iconfont转图片，图片背景色
 */
@property (nonatomic, strong) UIColor                                     *backgroundColor;

/**
 iconfont转图片，图片是否按照iconfont文本大小比例设置（YES：图片宽高比和iconfont宽高比相同，NO：图片为正方形）
 */
@property (nonatomic, assign, getter=isDefaultAspectRatio) BOOL           defaultAspectRatio;

+ (instancetype)conversionUrlString:(NSString *)urlString;

@end
