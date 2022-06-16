//
//  UILabel+LBInit.m
//  Baletoo_landlord
//
//  Created by baletu on 2018/7/31.
//  Copyright © 2018年 krisc.zampono. All rights reserved.
//

#import "UILabel+BLTUIKit.h"

@implementation UILabel (BLTUIKit)


+ (instancetype)blt_labelWithFont:(UIFont *)font textColor:(UIColor *)textColor{
    return [self blt_labelWithFrame:CGRectZero title:nil font:font textColor:textColor];
}
+ (instancetype)blt_labelWithTitle:(NSString *)title font:(UIFont *)font textColor:(UIColor *)textColor{
    return [self blt_labelWithFrame:CGRectZero title:title font:font textColor:textColor];
}

+ (instancetype)blt_labelWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font textColor:(UIColor *)textColor{
    return [self blt_labelWithFrame:frame title:title font:font textColor:textColor textAlignment:NSTextAlignmentLeft autoWidth:NO];
}

+ (instancetype)blt_labelWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment autoWidth:(BOOL)autoWidth{
    UILabel *label = [[self alloc] initWithFrame:frame];
    label.text = title;
    label.textColor = textColor;
    label.font = font;
    label.textAlignment = textAlignment;
    if (autoWidth) {
        CGFloat textW = [label sizeThatFits:CGSizeZero].width;
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, textW, label.frame.size.width);
    }
    return label;
}

/** 设置文字渐变色 */
- (void)blt_addGrandientTextStartColor:(UIColor *)startColor endColor:(UIColor *)endColor superView:(UIView *)superView{
    [self blt_addGrandientTextStartColor:startColor endColor:endColor superView:superView direction:LLGradientTextColorDirectionLeftToRight];
}

- (void)blt_addGrandientTextStartColor:(UIColor *)startColor endColor:(UIColor *)endColor superView:(UIView *)superView direction:(LLGradientTextColorDirection)direction{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(id)[UIColor redColor].CGColor, (id)[UIColor greenColor].CGColor, (id)[UIColor blueColor].CGColor];
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    switch (direction) {
        case LLGradientTextColorDirectionLeftToRight:
            startPoint = CGPointMake(0, 0);
            endPoint = CGPointMake(1, 0);
            break;
        case LLGradientTextColorDirectionTopToBottom:
            startPoint = CGPointMake(0, 0);
            endPoint = CGPointMake(0, 1);
            break;
        case LLGradientTextColorDirectionLeftTopToRightBottom:
            startPoint = CGPointMake(0, 0);
            endPoint = CGPointMake(1, 1);
            break;
        default:
            break;
    }
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    gradientLayer.frame = self.frame;
//    self.frame = gradientLayer.bounds;//设置_lable的坐标
    //    _lable.layer.frame = gradientLayer.bounds;//和上面的代码一个效果
    gradientLayer.mask = self.layer;//可以理解为([gradientLayer addSubview:_lable])
    [superView.layer addSublayer:gradientLayer];
}

@end
