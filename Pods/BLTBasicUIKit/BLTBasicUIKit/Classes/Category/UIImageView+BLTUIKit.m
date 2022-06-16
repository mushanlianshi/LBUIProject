//
//  UIImageView+BLTUIKit.m
//  BLTBasicUIKit
//
//  Created by liu bin on 2021/3/2.
//

#import "UIImageView+BLTUIKit.h"


@implementation UIImageView (BLTUIKit)

+ (instancetype)blt_imageViewWithImage:(UIImage *)image{
    return [self blt_imageViewWithImage:image mode:UIViewContentModeScaleToFill];;
}

+ (instancetype)blt_imageViewWithMode:(UIViewContentMode)mode{
    return [self blt_imageViewWithImage:nil mode:mode];
}

+ (instancetype)blt_imageViewWithImage:(UIImage *)image mode:(UIViewContentMode)mode{
    UIImageView *imageView = [[self alloc] init];
    imageView.image = image;
    imageView.contentMode = mode;
    return imageView;
}

//把图片的颜色渲染成新的颜色  针对纯色图片   例如：箭头 小纯色icon等
- (void)blt_renderImageWithColor:(UIColor *)color{
    NSAssert(self.image != nil, @"LBLog image can not be nil, please set image first");
    if (self.image == nil) {
        return;
    }
    self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.tintColor = color;
}

@end
