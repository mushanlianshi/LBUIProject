//
//  UIView+LBColor.m
//  LBUIProject
//
//  Created by liu bin on 2023/7/18.
//

#import "UIView+LBColor.h"
#import <objc/runtime.h>
#import <BLTUIKitProject/BLTUI.h>

@implementation UIView (LBColor)


+ (void)load{
    swizzleInstanceMethod([self class], @selector(layoutSubviews), @selector(lb_layoutSubviews));
}

- (void)setStartColor:(UIColor *)startColor{
    objc_setAssociatedObject(self, @selector(startColor), startColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)startColor{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEndColor:(UIColor *)endColor{
    objc_setAssociatedObject(self, @selector(endColor), endColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)endColor{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setXCornerRadius:(double)xCornerRadius {
    self.layer.cornerRadius = xCornerRadius;
    self.layer.masksToBounds = YES;
}

- (double)xCornerRadius {
    return self.layer.cornerRadius;
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor  {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderWidth:(double)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (double)borderWidth {
    return self.layer.borderWidth;
}

- (void)lb_layoutSubviews{
    [self lb_layoutSubviews];
    if (!self.startColor || !self.endColor){
        return;
    }
    NSLog(@"LBLog start color endcolor %@ %@", self.startColor, self.endColor);
    [self blt_addGrandientLayerStartColor:self.startColor endColor:self.endColor direction:BLTGrandientLayerDirectionLeftToRight];
}

@end
