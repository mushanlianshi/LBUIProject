//
//  UIStackView+BLTUIKit.m
//  BLTBasicUIKit
//
//  Created by liu bin on 2021/7/20.
//

#import "UIStackView+BLTUIKit.h"


@implementation UIStackView (BLTUIKit)

+ (instancetype)blt_stackViewWithSpacing:(CGFloat)spacing{
    return [self blt_stackViewWithSpacing:spacing distribution:UIStackViewDistributionFill];
}

+ (instancetype)blt_stackViewWithSpacing:(CGFloat)spacing distribution:(UIStackViewDistribution)distribution{
    return [self blt_stackViewWithSpacing:spacing distribution:distribution alignment:UIStackViewAlignmentFill];;
}

+ (instancetype)blt_stackViewWithSpacing:(CGFloat)spacing distribution:(UIStackViewDistribution)distribution alignment:(UIStackViewAlignment)alignment{
    return [self blt_stackViewWithSpacing:spacing distribution:distribution alignment:alignment axis:UILayoutConstraintAxisHorizontal];
}

+ (instancetype)blt_stackViewWithSpacing:(CGFloat)spacing distribution:(UIStackViewDistribution)distribution alignment:(UIStackViewAlignment)alignment axis:(UILayoutConstraintAxis)axis{
    return [self blt_stackViewWithArrangeSubviews:nil spacing:spacing distribution:distribution alignment:alignment axis:axis];
}

+ (instancetype)blt_stackViewWithArrangeSubviews:(NSArray <UIView *>*)subviews spacing:(CGFloat)spacing distribution:(UIStackViewDistribution)distribution alignment:(UIStackViewAlignment)alignment axis:(UILayoutConstraintAxis)axis{
    UIStackView *stackView = [[self alloc] initWithArrangedSubviews:subviews];
    stackView.spacing = spacing;
    stackView.distribution = distribution;
    stackView.alignment = alignment;
    stackView.axis = axis;
    return stackView;
}


//横方向的stackView  添加多行label的，处理numberofline = 0 label不会换行  子控件等宽的问题 需要包一层view来处理的问题
- (void)blt_addMutiLineLabel:(UILabel *)label{
    label.numberOfLines = 0;
    [label setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = false;
    [view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self addArrangedSubview:view];
}

@end
