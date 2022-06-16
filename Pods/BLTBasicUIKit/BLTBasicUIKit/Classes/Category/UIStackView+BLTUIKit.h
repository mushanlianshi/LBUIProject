//
//  UIStackView+BLTUIKit.h
//  BLTBasicUIKit
//
//  Created by liu bin on 2021/7/20.
//

#import <UIKit/UIKit.h>


@interface UIStackView (BLTUIKit)

+ (instancetype)blt_stackViewWithSpacing:(CGFloat)spacing;

+ (instancetype)blt_stackViewWithSpacing:(CGFloat)spacing distribution:(UIStackViewDistribution)distribution;

+ (instancetype)blt_stackViewWithSpacing:(CGFloat)spacing distribution:(UIStackViewDistribution)distribution alignment:(UIStackViewAlignment)alignment;

+ (instancetype)blt_stackViewWithSpacing:(CGFloat)spacing distribution:(UIStackViewDistribution)distribution alignment:(UIStackViewAlignment)alignment axis:(UILayoutConstraintAxis)axis;


+ (instancetype)blt_stackViewWithArrangeSubviews:(NSArray <UIView *>*)subviews spacing:(CGFloat)spacing distribution:(UIStackViewDistribution)distribution alignment:(UIStackViewAlignment)alignment axis:(UILayoutConstraintAxis)axis;

//横方向的stackView  添加多行label的，处理numberofline = 0 label不会换行  子控件等宽的问题 需要包一层view来处理的问题
- (void)blt_addMutiLineLabel:(UILabel *)label;

@end

