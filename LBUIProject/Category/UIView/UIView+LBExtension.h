//
//  UIView+LBExtension.h
//  LBUIProject
//
//  Created by liu bin on 2022/8/16.
//

#import <UIKit/UIKit.h>

@interface UIView (LBExtension)

@property (nonatomic, copy) UIView *(^lb_hitTestBlock)(CGPoint point, UIEvent *event, UIView *originView);

@end

