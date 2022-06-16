//
//  BLTAlertTransitioningAnimator.h
//  AliyunOSSiOS
//
//  Created by liu bin on 2020/4/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BLTAlertTransitioningAnimateStyle) {
    BLTAlertTransitioningAnimateStylePopUp = 0,          // 从中间弹出
    BLTAlertTransitioningAnimateStylePopOutFromBottom,   // 从底部弹出
};

@interface BLTAlertTransitioningAnimator : NSObject<UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong, readonly) UIView *maskView;
@property (nonatomic, strong) NSNumber *transitionDuration;

@property (nonatomic, assign) BLTAlertTransitioningAnimateStyle      animateStyle;

/** 当展现alert时，背景mask的alpha值。默认为0.3 */
@property (nonatomic) CGFloat maskViewAlpha;


@end

NS_ASSUME_NONNULL_END
