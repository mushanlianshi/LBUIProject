//
//  BLTBaseLabel.m
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/25.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import "BLTContentInsetLabel.h"

@implementation BLTContentInsetLabel

- (instancetype)initWithContentInsets:(UIEdgeInsets)insets{
    self = [super init];
    if (self) {
        self.contentEdgeInsets = insets;
    }
    return self;
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets{
    _contentEdgeInsets = contentEdgeInsets;
    [self setNeedsDisplay];
}

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.contentEdgeInsets)];
}

- (CGSize)sizeThatFits:(CGSize)size{
    size = [super sizeThatFits:CGSizeMake(size.width - self.contentEdgeInsets.left - self.contentEdgeInsets.right, size.height - self.contentEdgeInsets.top - self.contentEdgeInsets.bottom)];
    size = CGSizeMake(size.width + self.contentEdgeInsets.left + self.contentEdgeInsets.right, size.height + self.contentEdgeInsets.top + self.contentEdgeInsets.bottom);
    return size;
}

- (CGSize)intrinsicContentSize {
    CGFloat maxWidth = self.preferredMaxLayoutWidth > 0 ? self.preferredMaxLayoutWidth : CGFLOAT_MAX;
    return [self sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
}

@end



@implementation BLTGradientLabel

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:[self.gradientColors count]];
    [self.gradientColors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIColor class]]) {
            [colors addObject:(__bridge id)[obj CGColor]];
        } else if (CFGetTypeID((__bridge void *)obj) == CGColorGetTypeID()) {
            [colors addObject:obj];
        } else {
            @throw [NSException exceptionWithName:@"CRGradientLabelError"
                                           reason:@"Object in gradientColors array is not a UIColor or CGColorRef"
                                         userInfo:NULL];
        }
    }];
    
    CGContextSaveGState(context);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, NULL);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    if (self.gradientDirection == BLTGradientLabelDirectionTopToBottom) {
        startPoint = CGPointMake(0, CGRectGetMinY(rect));
        endPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    }else if (self.gradientDirection == BLTGradientLabelDirectionLeftTopToRightBottom){
        startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinX(rect));
        endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    }
    else if (self.gradientDirection == BLTGradientLabelDirectionLeftBottomToRightTop){
        startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
        endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    }
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint,
                                kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation);
    
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    
    [super drawRect: rect];
}


@end
