//
//  UILabel+LBInit.h
//  Baletoo_landlord
//
//  Created by baletu on 2018/7/31.
//  Copyright © 2018年 krisc.zampono. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LLGradientTextColorDirection){
    LLGradientTextColorDirectionLeftToRight = 0,    //默认左到右
    LLGradientTextColorDirectionTopToBottom,        //上到下
    LLGradientTextColorDirectionLeftTopToRightBottom, //左上到右下
};

@interface UILabel (BLTUIKit)




+ (instancetype)blt_labelWithFont:(UIFont *)font textColor:(UIColor *)textColor;
+ (instancetype)blt_labelWithTitle:(NSString *)title font:(UIFont *)font textColor:(UIColor *)textColor;

+ (instancetype)blt_labelWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font textColor:(UIColor *)textColor;

+ (instancetype)blt_labelWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment autoWidth:(BOOL)autoWidth;

/** 设置文字渐变色 */
- (void)blt_addGrandientTextStartColor:(UIColor *)startColor endColor:(UIColor *)endColor superView:(UIView *)superView;

- (void)blt_addGrandientTextStartColor:(UIColor *)startColor endColor:(UIColor *)endColor superView:(UIView *)superView direction:(LLGradientTextColorDirection)direction;

@end
