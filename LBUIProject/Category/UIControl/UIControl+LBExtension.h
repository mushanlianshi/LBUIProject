//
//  UIControl+LBExtension.h
//  LBUIProject
//
//  Created by liu bin on 2022/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (LBExtension)

//防止多次点击
@property (nonatomic, assign) bool lb_preventRepeatTouchUpInside;

@end

NS_ASSUME_NONNULL_END
