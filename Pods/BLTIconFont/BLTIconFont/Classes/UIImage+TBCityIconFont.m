//
//  UIImage+TBCityIconFont.m
//  iCoupon
//
//  Created by John Wong on 10/12/14.
//  Copyright (c) 2014 Taodiandian. All rights reserved.
//

#import "UIImage+TBCityIconFont.h"
#import "TBCityIconFont.h"
#import <CoreText/CoreText.h>

@implementation UIImage (TBCityIconFont)

+ (UIImage *)iconWithInfo:(TBCityIconInfo *)info
{
    CGFloat w1 = info.size - info.imageInsets.left - info.imageInsets.right;
    CGFloat w2 = info.size - info.imageInsets.top - info.imageInsets.bottom;
    CGFloat size = MIN(w1, w2);
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat realSize = size * scale;
    CGFloat imageSize = info.size * scale;
    UIFont *font = info.fontName ?
        [TBCityIconFont fontWithSize:realSize withFontName:info.fontName] :
        [TBCityIconFont fontWithSize:realSize];
    
    UIGraphicsBeginImageContext(CGSizeMake(imageSize, imageSize));
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (info.backgroundColor) {
        [info.backgroundColor set];
        UIRectFill(CGRectMake(0.0, 0.0, imageSize, imageSize)); //fill the background
    }
    CGPoint point = CGPointMake(info.imageInsets.left*scale, info.imageInsets.top*scale);
 
    if ([info.text respondsToSelector:@selector(drawAtPoint:withAttributes:)]) {
        /**
         * 如果这里抛出异常，请打开断点列表，右击All Exceptions -> Edit Breakpoint -> All修改为Objective-C
         * See: http://stackoverflow.com/questions/1163981/how-to-add-a-breakpoint-to-objc-exception-throw/14767076#14767076
         */
        [info.text drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: info.color}];
    } else {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGContextSetFillColorWithColor(context, info.color.CGColor);
        [info.text drawAtPoint:point withFont:font];
#pragma clang pop
    }
    
    UIImage *image = [UIImage imageWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage scale:scale orientation:UIImageOrientationUp];
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)iconDefaultAspectRatioWithInfo:(TBCityIconInfo *)info
{
    CGFloat imageWidth = info.codeSize.width + info.imageInsets.left + info.imageInsets.right;
    CGFloat imageHeight = info.codeSize.height + info.imageInsets.top + info.imageInsets.bottom;
    CGFloat insetWidth = 0.0;
    if (info.codeSize.height > info.codeSize.width) {
        insetWidth = info.codeSize.height - info.codeSize.width;
        imageWidth = imageWidth - insetWidth;
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    UIFont *font = info.fontName ? [TBCityIconFont fontWithSize:info.codeSize.height * scale withFontName:info.fontName] : [TBCityIconFont fontWithSize:info.codeSize.height * scale];
    
    UIGraphicsBeginImageContext(CGSizeMake(imageWidth * scale, imageHeight * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (info.backgroundColor) {
        [info.backgroundColor set];
        UIRectFill(CGRectMake(0.0, 0.0, imageWidth * scale, imageHeight * scale)); //fill the background
    }
    CGPoint point = CGPointMake((info.imageInsets.left - insetWidth) * scale, info.imageInsets.top * scale);
    
    if ([info.text respondsToSelector:@selector(drawAtPoint:withAttributes:)]) {
        /**
         * 如果这里抛出异常，请打开断点列表，右击All Exceptions -> Edit Breakpoint -> All修改为Objective-C
         * See: http://stackoverflow.com/questions/1163981/how-to-add-a-breakpoint-to-objc-exception-throw/14767076#14767076
         */
        [info.text drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: info.color}];
    } else {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGContextSetFillColorWithColor(context, info.color.CGColor);
        [info.text drawAtPoint:point withFont:font];
#pragma clang pop
    }
    
    UIImage *image = [UIImage imageWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage scale:scale orientation:UIImageOrientationUp];
    UIGraphicsEndImageContext();
    
    return image;
}


@end
