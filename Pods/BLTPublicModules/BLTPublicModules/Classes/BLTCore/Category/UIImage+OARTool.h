//
//  UIImage+OARTool.h
//  chugefang
//
//  Created by liu bin on 2020/11/23.
//  Copyright © 2020 baletu123. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (OARTool)

- (UIImage *)scaleImageFromURLKey:(NSString *)urlKey;

+ (UIImage *)oar_readImageFromFileBundle:(NSString *)bundleName imageName:(NSString *)imageName;

+ (UIImage *)composeBottomImage:(UIImage *)image upImage:(UIImage *)upImage upImageFrame:(CGRect)upImageFrame;

+ (UIImage *)image:(UIImage *)image byScalingToSize:(CGSize)targetSize;

@end

NS_ASSUME_NONNULL_END
