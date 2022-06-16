//
//  BLTAlertTransitioningAnimator.m
//  AliyunOSSiOS
//
//  Created by liu bin on 2020/4/17.
//

#import "BLTAlertTransitioningAnimator.h"

@interface BLTAlertTransitioningAnimator ()

@property (nonatomic, strong, readwrite) UIView *maskView;

@end

@implementation BLTAlertTransitioningAnimator

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maskViewAlpha = 0.3;
    }
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return  self.transitionDuration ? [self.transitionDuration doubleValue] : 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    toViewController.view.frame = [transitionContext containerView].frame;
    self.maskView.frame = toViewController.view.bounds;
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:[transitionContext containerView]];
    if (toViewController.isBeingPresented) {
        self.maskView.alpha = 0;
        [[transitionContext containerView] addSubview:self.maskView];
        [[transitionContext containerView] addSubview:toViewController.view];

        if (self.animateStyle == BLTAlertTransitioningAnimateStylePopUp) {
            toViewController.view.transform = CGAffineTransformMakeScale(1.15, 1.15);
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:10 options:0 animations:^{
                toViewController.view.transform = CGAffineTransformIdentity;
                self.maskView.alpha = self.maskViewAlpha;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:finished];
            }];
        }else if (self.animateStyle == BLTAlertTransitioningAnimateStylePopOutFromBottom) {
            CGRect toViewControllerFrame = toViewController.view.frame;
            toViewControllerFrame.origin.y = toViewControllerFrame.size.height;
            toViewController.view.frame = toViewControllerFrame;
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toViewController.view.frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                self.maskView.alpha = self.maskViewAlpha;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:finished];
            }];
        }
    } else {
        if (self.animateStyle == BLTAlertTransitioningAnimateStylePopUp) {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:10 options:0 animations:^{
                self.maskView.alpha = 0;
                fromViewController.view.alpha = 0;
                
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:finished];
            }];
        }else if (self.animateStyle == BLTAlertTransitioningAnimateStylePopOutFromBottom) {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                self.maskView.alpha = 0;
                fromViewController.view.alpha = 0;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:finished];
            }];
        }
    }
}

#pragma mark - getter @property
- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIButton alloc] init];
        _maskView.backgroundColor = [UIColor blackColor];
    }
    return _maskView;
}

@end
