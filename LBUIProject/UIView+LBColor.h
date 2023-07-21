//
//  UIView+LBColor.h
//  LBUIProject
//
//  Created by liu bin on 2023/7/18.
//

#import <UIKit/UIKit.h>


@interface UIView (LBColor)

///倒角
@property (nonatomic, strong) IBInspectable   UIColor  *startColor;

@property (nonatomic, strong) IBInspectable   UIColor  *endColor;

///倒角
@property (nonatomic, assign) IBInspectable   double  xCornerRadius;
///边框颜色
@property (nonatomic, strong) IBInspectable   UIColor *borderColor;
///边框宽度
@property (nonatomic, assign) IBInspectable   double  borderWidth;


@end

