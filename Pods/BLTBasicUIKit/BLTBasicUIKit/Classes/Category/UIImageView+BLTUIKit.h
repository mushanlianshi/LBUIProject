//
//  UIImageView+BLTUIKit.h
//  BLTBasicUIKit
//
//  Created by liu bin on 2021/3/2.
//


#import <UIKit/UIKit.h>


@interface UIImageView (BLTUIKit)

+ (instancetype)blt_imageViewWithImage:(UIImage *)image;

+ (instancetype)blt_imageViewWithMode:(UIViewContentMode)mode;

+ (instancetype)blt_imageViewWithImage:(UIImage *)image mode:(UIViewContentMode)mode;

//把图片的颜色渲染成新的颜色  针对纯色图片   例如：箭头 小纯色icon等
- (void)blt_renderImageWithColor:(UIColor *)color;

@end

