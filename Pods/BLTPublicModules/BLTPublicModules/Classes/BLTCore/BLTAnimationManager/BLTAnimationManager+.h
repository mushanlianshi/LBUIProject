//
//  BLTAnimationManager.h
//  Demo
//
//  Created by wll on 2019/2/21.
//  Copyright © 2019 wll. All rights reserved.
//  轻量级动画处理类

#import <UIKit/UIView.h>


@interface UIView (animation)

/**
 下落展示隐藏动画 默认动画时间0.25s
 */
- (void)dropDownHideAnimation:(void(^)(UIView * view))finishBlk;

/**
 下落隐藏效果动画
 */
- (void)dropDownHideAnimation:(CFTimeInterval)duration finishBlk:(void(^)(UIView * view))finishBlk;

/**
 下落展示效果动画 默认动画时间0.25s
 */
- (void)dropDownShowAnimation;

/**
 下落展示效果动画
 */
- (void)dropDownShowAnimation:(CFTimeInterval)duration;

/**
 下拉展示效果动画 默认动画时间0.25s
 */
- (void)pullShowAnimation;

/**
 上拉关闭动画效果 默认动画时间0.25s
 */
- (void)pushHideAnimationWithFinishBlk:(void(^)(UIView * view))finishBlk;

/**
 下拉展示效果动画
 */
- (void)pullShowAnimationWithDuration:(CFTimeInterval)duration;

/**
 上拉关闭动画效果
 */
- (void)pushHideAnimationWithDuration:(CFTimeInterval)duration finishBlk:(void(^)(UIView * view))finishBlk;

/**
 上拉展示动画效果 默认动画时间0.25s
 */
- (void)pushShowAnimation;

/**
 上拉展示动画效果
 */
- (void)pushShowAnimationWithDuration:(CFTimeInterval)duration;

/**
 下拉关闭效果动画 默认动画时间0.25s
 */
- (void)pullHideAnimationWithFinishBlk:(void(^)(UIView * view))finishBlk;

/**
 下拉关闭效果动画
 */
- (void)pullHideAnimationWithDuration:(CFTimeInterval)duration finishBlk:(void(^)(UIView * view))finishBlk;

/**
 模仿系统弹框展示动画 默认动画时间0.25s
 */
- (void)systemAlertShowAnimation;

/**
 模仿系统弹框展示动画
 */
- (void)systemAlertShowAnimationWithDuration:(CFTimeInterval)duration;

/**
 模仿系统弹框关闭动画 默认动画时间0.25s
 */
- (void)systemAlertHideAnimationWithFinishBlk:(void(^)(UIView * view))finishBlk;

/**
 模仿系统弹框关闭动画
 */
- (void)systemAlertHideAnimationWithDuration:(CFTimeInterval)duration finishBlk:(void(^)(UIView * view))finishBlk;

@end















@interface CALayer (animation) <CAAnimationDelegate>

@property (nonatomic, assign) CGPoint originalAnchorPoint;

@property (nonatomic, assign) CGPoint originalPosition;

@property (nonatomic, copy) void(^finishBlk)(CALayer * layer);

/**
 下落展示隐藏动画 默认动画时间0.25s
 */
- (void)dropDownHideAnimation:(void(^)(CALayer * layer))finishBlk;

/**
 下落隐藏效果动画
 */
- (void)dropDownHideAnimation:(CFTimeInterval)duration finishBlk:(void(^)(CALayer * layer))finishBlk;

/**
 下落展示效果动画 默认动画时间0.25s
 */
- (void)dropDownShowAnimation;

/**
 下落展示效果动画
 */
- (void)dropDownShowAnimation:(CFTimeInterval)duration;

/**
 下拉展示效果动画 默认动画时间0.25s
 */
- (void)pullShowAnimation;

/**
 上拉关闭动画效果 默认动画时间0.25s
 */
- (void)pushHideAnimationWithFinishBlk:(void(^)(CALayer * layer))finishBlk;

/**
 下拉展示效果动画
 */
- (void)pullShowAnimationWithDuration:(CFTimeInterval)duration;

/**
 上拉关闭动画效果
 */
- (void)pushHideAnimationWithDuration:(CFTimeInterval)duration finishBlk:(void(^)(CALayer * layer))finishBlk;

/**
 上拉展示动画效果 默认动画时间0.25s
 */
- (void)pushShowAnimation;

/**
 上拉展示动画效果
 */
- (void)pushShowAnimationWithDuration:(CFTimeInterval)duration;

/**
 下拉关闭效果动画 默认动画时间0.25s
 */
- (void)pullHideAnimationWithFinishBlk:(void(^)(CALayer * layer))finishBlk;

/**
 下拉关闭效果动画
 */
- (void)pullHideAnimationWithDuration:(CFTimeInterval)duration finishBlk:(void(^)(CALayer * layer))finishBlk;

/**
 模仿系统弹框展示动画 默认动画时间0.25s
 */
- (void)systemAlertShowAnimation;

/**
 模仿系统弹框展示动画
 */
- (void)systemAlertShowAnimationWithDuration:(CFTimeInterval)duration;

/**
 模仿系统弹框关闭动画 默认动画时间0.25s
 */
- (void)systemAlertHideAnimationWithFinishBlk:(void(^)(CALayer * layer))finishBlk;

/**
 模仿系统弹框关闭动画
 */
- (void)systemAlertHideAnimationWithDuration:(CFTimeInterval)duration finishBlk:(void(^)(CALayer * layer))finishBlk;


@end


