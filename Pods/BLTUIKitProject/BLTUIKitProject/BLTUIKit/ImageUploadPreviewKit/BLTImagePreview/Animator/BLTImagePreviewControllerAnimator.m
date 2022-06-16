//
//  BLTImagePreviewControllerAnimator.m
//  AliyunOSSiOS
//
//  Created by liu bin on 2020/4/7.
//

#import "BLTImagePreviewControllerAnimator.h"
#import "BLTImagePreviewController.h"
#import "BLTImagePreviewView.h"

@implementation BLTImagePreviewControllerAnimator

- (instancetype)init{
    self = [super init];
    if (self) {
        self.duration = 0.29;
    }
    return self;
}

//开始动画
- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    if (!self.imagePreviewController || !self.imagePreviewController.startAnimatingImageView) {
        return;
    }
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    //present开始的动画
    BOOL isPresenting = fromViewController.presentedViewController == toViewController;
    //点击图片的动画的view
    UIImageView *startImageView = self.imagePreviewController.startAnimatingImageView();
    //预览的imageView
    UIImageView *preViewImageView = [self.imagePreviewController.imagePreviewView imageViewAtIndex:self.imagePreviewController.imagePreviewView.currentIndex];
    
    UIImageView *dismissImageView = self.imagePreviewController.endAnimatingImageView(self.imagePreviewController.imagePreviewView.currentIndex);
//    endImageView = endImageView ? endImageView : self.imagePreviewController.imagePreviewView;
    //获取动画的容器
    UIView *containerView = transitionContext.containerView;
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    CGRect startRect = [startImageView convertRect:startImageView.bounds toView:containerView];
    CGRect previewRect = [preViewImageView convertRect:preViewImageView.bounds toView:containerView];
    CGRect dismissRect = [dismissImageView convertRect:dismissImageView.bounds toView:containerView];
    
    toView.frame = containerView.bounds;
    //添加toView  fromView系统自己已经添加
    if (isPresenting) {
        [containerView addSubview:toView];
    }else{
        [containerView insertSubview:toView belowSubview:fromView];
    }
    
    //present
    if (isPresenting) {
        UIImageView *tmpView = [[UIImageView alloc] init];
        tmpView.image = startImageView.image;
        tmpView.contentMode = UIViewContentModeScaleAspectFit;
        tmpView.clipsToBounds = YES;
        tmpView.frame = startRect;
        toView.alpha = 0;
        [containerView addSubview:tmpView];
        preViewImageView.hidden = YES;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toView.alpha = 1;
            tmpView.frame = previewRect;
        } completion:^(BOOL finished) {
            [tmpView removeFromSuperview];
            preViewImageView.hidden = NO;
            //如果动画过渡取消了就标记不完成，否则才完成，这里可以直接写YES，如果有手势过渡才需要判断，必须标记，否则系统不会中断动画完成的部署，会出现无法交互之类的bug
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
    //dismiss
    else{
        
        UIImageView *tmpView = [[UIImageView alloc] init];
        tmpView.image = preViewImageView.image;
        tmpView.contentMode = UIViewContentModeScaleAspectFit;
        tmpView.clipsToBounds = YES;
        tmpView.frame = previewRect;
        fromView.alpha = 1;
        [containerView addSubview:tmpView];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromView.alpha = 0;
            tmpView.frame = dismissRect;
        } completion:^(BOOL finished) {
            startImageView.hidden = NO;
            [tmpView removeFromSuperview];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
    
    
}

//动画的时长
- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

@end
