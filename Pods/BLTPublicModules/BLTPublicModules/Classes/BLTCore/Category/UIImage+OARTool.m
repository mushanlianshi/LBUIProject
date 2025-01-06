//
//  UIImage+OARTool.m
//  chugefang
//
//  Created by liu bin on 2020/11/23.
//  Copyright © 2020 baletu123. All rights reserved.
//

#import "UIImage+OARTool.h"


@implementation UIImage (OARTool)

/** 根据网络图片返回一个scale过的图片 */
- (UIImage *)scaleImageFromURLKey:(NSString *)urlKey{
    if (!self) return nil;
    CGFloat scale = 1;
    if ([urlKey containsString:@"2x."]) {
        scale = 2;
    }else if ([urlKey containsString:@"3x."]){
        scale = 3;
    }
    UIImage *scaledImage = [[UIImage alloc] initWithCGImage:self.CGImage scale:scale orientation:self.imageOrientation];
    return scaledImage;
}

+ (UIImage *)oar_readImageFromFileBundle:(NSString *)bundleName imageName:(NSString *)imageName{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"]];
    UIImage *image = [[UIImage imageWithContentsOfFile:[bundle pathForResource:imageName ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return image;
}

+ (UIImage *)composeBottomImage:(UIImage *)image upImage:(UIImage *)upImage upImageFrame:(CGRect)upImageFrame{
    //将底部的一张的大小作为所截取的合成图的尺寸
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
    // Draw image2，底下的
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [upImage drawInRect:upImageFrame];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

/**
 *  修改图片size
 *
 *  @param image      原图片
 *  @param targetSize 要修改的size
 *
 *  @return 修改后的图片
 */
+ (UIImage *)image:(UIImage *)image byScalingToSize:(CGSize)targetSize
{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = CGPointZero;
    thumbnailRect.size.width = targetSize.width;
    thumbnailRect.size.height = targetSize.height;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
