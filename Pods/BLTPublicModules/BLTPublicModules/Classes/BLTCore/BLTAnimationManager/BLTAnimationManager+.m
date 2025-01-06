//
//  BLTAnimationManager.m
//  Demo
//
//  Created by wll on 2019/2/21.
//  Copyright © 2019 wll. All rights reserved.
//

#import "BLTAnimationManager+.h"
#import <objc/message.h>

#define kAnimationDuration 0.25

@implementation UIView (animation)

/**
 下落展示隐藏动画 默认动画时间0.25s
 */
- (void)dropDownHideAnimation:(void(^)(UIView * view))finishBlk {
    __weak typeof(self) weakSelf = self;
    [self.layer dropDownHideAnimation:kAnimationDuration finishBlk:^(CALayer *layer) {
        __strong typeof(self) strongSelf = weakSelf;
        !finishBlk?:finishBlk(strongSelf);
    }];
}

/**
 下落隐藏效果动画
 */
- (void)dropDownHideAnimation:(CFTimeInterval)duration finishBlk:(void(^)(UIView * view))finishBlk {
    __weak typeof(self) weakSelf = self;
    [self.layer dropDownHideAnimation:duration finishBlk:^(CALayer *layer) {
        __strong typeof(self) strongSelf = weakSelf;
        !finishBlk?:finishBlk(strongSelf);
    }];
}

/**
 下落展示效果动画 默认动画时间0.25s
 */
- (void)dropDownShowAnimation {
    [self.layer dropDownShowAnimation:kAnimationDuration];
}

/**
 下落展示效果动画
 */
- (void)dropDownShowAnimation:(CFTimeInterval)duration {
    [self.layer dropDownShowAnimation:duration];
}

/**
 下拉展示效果动画 默认动画时间0.25s
 */
- (void)pullShowAnimation {
    
    [self.layer pullShowAnimationWithDuration:kAnimationDuration];
}

/**
 上拉关闭动画效果 默认动画时间0.25s
 */
- (void)pushHideAnimationWithFinishBlk:(void(^)(UIView * view))finishBlk {
    __weak typeof(self) weakSelf = self;
    [self.layer pushHideAnimationWithDuration:kAnimationDuration finishBlk:^(CALayer *layer) {
        __strong typeof(self) strongSelf = weakSelf;
        !finishBlk?:finishBlk(strongSelf);
    }];
}

/**
 下拉展示效果动画
 */
- (void)pullShowAnimationWithDuration:(CFTimeInterval)duration {
    
    [self.layer pullShowAnimationWithDuration:duration];
}

/**
 上拉关闭动画效果
 */
- (void)pushHideAnimationWithDuration:(CFTimeInterval)duration finishBlk:(void(^)(UIView * view))finishBlk {
    __weak typeof(self) weakSelf = self;
    [self.layer pushHideAnimationWithDuration:duration finishBlk:^(CALayer *layer) {
        __strong typeof(self) strongSelf = weakSelf;
        !finishBlk?:finishBlk(strongSelf);
    }];
}

/**
 上拉展示动画效果 默认动画时间0.25s
 */
- (void)pushShowAnimation {
    [self.layer pushShowAnimationWithDuration:kAnimationDuration];
}

/**
 上拉展示动画效果
 */
- (void)pushShowAnimationWithDuration:(CFTimeInterval)duration {
    [self.layer pushShowAnimationWithDuration:duration];

}

/**
 下拉关闭效果动画 默认动画时间0.25s
 */
- (void)pullHideAnimationWithFinishBlk:(void(^)(UIView * view))finishBlk {
    __weak typeof(self) weakSelf = self;
    [self.layer pullHideAnimationWithDuration:kAnimationDuration finishBlk:^(CALayer *layer) {
        __strong typeof(self) strongSelf = weakSelf;
        !finishBlk?:finishBlk(strongSelf);
    }];
}

/**
 下拉关闭效果动画
 */
- (void)pullHideAnimationWithDuration:(CFTimeInterval)duration finishBlk:(void(^)(UIView * view))finishBlk {
    __weak typeof(self) weakSelf = self;
    [self.layer pullHideAnimationWithDuration:duration finishBlk:^(CALayer *layer) {
        __strong typeof(self) strongSelf = weakSelf;
        !finishBlk?:finishBlk(strongSelf);
    }];
}

/**
 模仿系统弹框展示动画 默认动画时间0.25s
 */
- (void)systemAlertShowAnimation {
    [self.layer systemAlertShowAnimationWithDuration:kAnimationDuration];
}

/**
 模仿系统弹框展示动画
 */
- (void)systemAlertShowAnimationWithDuration:(CFTimeInterval)duration {
    [self.layer systemAlertShowAnimationWithDuration:duration];
}

/**
 模仿系统弹框关闭动画 默认动画时间0.25s
 */
- (void)systemAlertHideAnimationWithFinishBlk:(void(^)(UIView * view))finishBlk {
    __weak typeof(self) weakSelf = self;
    [self.layer systemAlertHideAnimationWithDuration:kAnimationDuration finishBlk:^(CALayer *layer) {
        __strong typeof(self) strongSelf = weakSelf;
        !finishBlk?:finishBlk(strongSelf);
    }];
}

/**
 模仿系统弹框关闭动画
 */
- (void)systemAlertHideAnimationWithDuration:(CFTimeInterval)duration finishBlk:(void(^)(UIView * view))finishBlk {
    __weak typeof(self) weakSelf = self;
    [self.layer systemAlertHideAnimationWithDuration:duration finishBlk:^(CALayer *layer) {
        __strong typeof(self) strongSelf = weakSelf;
        !finishBlk?:finishBlk(strongSelf);
    }];
}

@end








//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CALayer (animation)

/**
 下落展示隐藏动画 默认动画时间0.25s
 */
- (void)dropDownHideAnimation:(void(^)(CALayer * layer))finishBlk {
    [self dropDownHideAnimation:kAnimationDuration finishBlk:finishBlk];
}

/**
 下落隐藏效果动画
 */
- (void)dropDownHideAnimation:(CFTimeInterval)duration finishBlk:(void(^)(CALayer * layer))finishBlk {
    CGFloat y = self.frame.origin.y;
    self.originalAnchorPoint = self.anchorPoint;
    self.originalPosition = self.position;
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.delegate = self;
    animation.duration = duration ?: kAnimationDuration;
    animation.fromValue = @(y);
    animation.toValue = @([UIScreen mainScreen].bounds.size.height);
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [self addAnimation:animation forKey:@"dropDownHideAnimation"];
}

/**
 下落展示效果动画 默认动画时间0.25s
 */
- (void)dropDownShowAnimation {
    [self dropDownShowAnimation:kAnimationDuration];
}

/**
 下落展示效果动画
 */
- (void)dropDownShowAnimation:(CFTimeInterval)duration {
    CGFloat y = self.frame.origin.y;
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.duration = duration ?: kAnimationDuration;
    animation.fromValue = @(-[UIScreen mainScreen].bounds.size.height);
    animation.toValue = @(y);
    [self addAnimation:animation forKey:@"dropDownShowAnimation"];
}



/**
 下拉展示效果动画 默认动画时间0.25s
 */
- (void)pullShowAnimation {
    [self pullShowAnimationWithDuration:kAnimationDuration];
}

/**
 下拉展示效果动画
 */
- (void)pullShowAnimationWithDuration:(CFTimeInterval)duration {

    CGFloat y = self.frame.origin.y;
    self.originalAnchorPoint = self.anchorPoint;
    self.originalPosition = self.position;
    self.anchorPoint = CGPointMake(0.5, 0);
    self.position = CGPointMake(self.position.x, y);
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    animation.delegate = self;
    animation.duration = duration ?: kAnimationDuration;
    animation.fromValue = @0;
    animation.toValue = @1;
    [self addAnimation:animation forKey:@"pullShowAnimation"];
}



/**
 上拉关闭动画效果 默认动画时间0.25s
 */
- (void)pushHideAnimationWithFinishBlk:(void(^)(CALayer * layer))finishBlk {
    [self pushHideAnimationWithDuration:kAnimationDuration finishBlk:finishBlk];
}

/**
 上拉关闭动画效果
 */
- (void)pushHideAnimationWithDuration:(CFTimeInterval)duration finishBlk:(void(^)(CALayer * layer))finishBlk {
    self.finishBlk = finishBlk;
    CGFloat y = self.frame.origin.y;
    self.originalAnchorPoint = self.anchorPoint;
    self.originalPosition = self.position;
    self.anchorPoint = CGPointMake(0.5, 0);
    self.position = CGPointMake(self.position.x, y);
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    animation.delegate = self;
    animation.duration = duration ?: kAnimationDuration;
    animation.fromValue = @1;
    animation.toValue = @0;
    [self addAnimation:animation forKey:@"pushHideAnimation"];

}

/**
 上拉展示动画效果 默认动画时间0.25s
 */
- (void)pushShowAnimation {
    [self pushShowAnimationWithDuration:kAnimationDuration];
}

/**
 上拉展示动画效果
 */
- (void)pushShowAnimationWithDuration:(CFTimeInterval)duration {
    CGFloat y = self.frame.origin.y + self.bounds.size.height;
    self.originalAnchorPoint = self.anchorPoint;
    self.originalPosition = self.position;
    self.anchorPoint = CGPointMake(0.5, 1);
    self.position = CGPointMake(self.position.x, y);
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    animation.delegate = self;
    animation.duration = duration ?: kAnimationDuration;
    animation.fromValue = @0;
    animation.toValue = @1;
    [self addAnimation:animation forKey:@"pushShowAnimation"];
}

/**
 下拉关闭效果动画 默认动画时间0.25s
 */
- (void)pullHideAnimationWithFinishBlk:(void(^)(CALayer * layer))finishBlk {
    [self pullHideAnimationWithDuration:kAnimationDuration finishBlk:finishBlk];
}

/**
 下拉关闭效果动画
 */
- (void)pullHideAnimationWithDuration:(CFTimeInterval)duration finishBlk:(void(^)(CALayer * layer))finishBlk {
    self.finishBlk = finishBlk;
    CGFloat y = self.frame.origin.y + self.bounds.size.height;
    self.originalAnchorPoint = self.anchorPoint;
    self.originalPosition = self.position;
    self.anchorPoint = CGPointMake(0.5, 1);
    self.position = CGPointMake(self.position.x, y);
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    animation.delegate = self;
    animation.duration = duration ?: kAnimationDuration;
    animation.fromValue = @1;
    animation.toValue = @0;
    [self addAnimation:animation forKey:@"pullHideAnimation"];
}


/**
 模仿系统弹框展示动画 默认动画时间0.25s
 */
- (void)systemAlertShowAnimation {
    [self systemAlertShowAnimationWithDuration:kAnimationDuration];
}

/**
 模仿系统弹框展示动画
 */
- (void)systemAlertShowAnimationWithDuration:(CFTimeInterval)duration {
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = duration;
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    animation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self addAnimation:animation forKey:@"systemAlertShowAnimation"];
}

/**
 模仿系统弹框关闭动画 默认动画时间0.25s
 */
- (void)systemAlertHideAnimationWithFinishBlk:(void(^)(CALayer * layer))finishBlk {
    [self systemAlertHideAnimationWithDuration:kAnimationDuration finishBlk:finishBlk];
}

/**
 模仿系统弹框关闭动画
 */
- (void)systemAlertHideAnimationWithDuration:(CFTimeInterval)duration finishBlk:(void(^)(CALayer * layer))finishBlk {
    self.finishBlk = finishBlk;
    self.originalAnchorPoint = self.anchorPoint;
    self.originalPosition = self.position;
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = duration;
    animation.values = @[
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)]
                         ];
    animation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    animation.delegate = self;
    [self addAnimation:animation forKey:@"systemAlertHideAnimation"];
}

//MARK:、、、、、、、、、、、、、、、、、、animationDelegate、、、、、、、、、、、、、、、
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.anchorPoint = self.originalAnchorPoint;
    self.position = self.originalPosition;
    !self.finishBlk?:self.finishBlk(self);
}











//////////////////////////////////////////////////////内部使用/////////////////////////////////////////////////////////
- (void)setOriginalAnchorPoint:(CGPoint)originalAnchorPoint {
    objc_setAssociatedObject(self, @selector(originalAnchorPoint), [NSValue valueWithCGPoint:originalAnchorPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)originalAnchorPoint {
    return [objc_getAssociatedObject(self,@selector(originalAnchorPoint)) CGPointValue];
}

- (void)setOriginalPosition:(CGPoint)originalPosition {
    objc_setAssociatedObject(self, @selector(originalPosition), [NSValue valueWithCGPoint:originalPosition], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (CGPoint)originalPosition {
    return [objc_getAssociatedObject(self,@selector(originalPosition)) CGPointValue];

}

- (void)setFinishBlk:(void (^)(CALayer *))finishBlk {
    objc_setAssociatedObject(self, @selector(finishBlk), finishBlk, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(CALayer *))finishBlk {
    return objc_getAssociatedObject(self, @selector(finishBlk));
}

@end



