//
//  UIButton+LBInit.h
//  nhExample
//
//  Created by liubin on 17/3/28.
//  Copyright © 2017年 liubin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 快速创建button的方法
 */
@interface UIButton (BLTUIKit)

/** 展示文字的按钮 */
+ (instancetype)blt_buttonWithTitle:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor target:(id)target selector:(SEL)selector;
/** 展示图片的按钮 */
+ (instancetype)blt_buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector;
/** 展示图片 文字的按钮 */
+ (instancetype)blt_buttonWithFrame:(CGRect)frame image:(UIImage *)image title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor target:(id)target selector:(SEL)selector;

//把图片的颜色渲染成新的颜色  针对纯色图片   例如：箭头 小纯色icon等
- (void)blt_renderImageWithColor:(UIColor *)color;

/** 设置按钮的安中无效果 无高亮的属性 */
@property (nonatomic, assign) BOOL blt_noHighlight;

@end
