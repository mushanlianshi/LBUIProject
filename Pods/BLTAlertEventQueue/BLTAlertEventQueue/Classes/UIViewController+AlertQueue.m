//
//  UIViewController+AlertQueue.m
//  BLTAlertEventQueue
//
//  Created by yinxing on 2023/5/19.
//

#import "UIViewController+AlertQueue.h"
#import <objc/runtime.h>

@interface UIViewController ()
{
    dispatch_block_t _aqm_cancelBlock;
    dispatch_block_t _aqm_dismissBlock;
    BLTAlertQueueManagerBlock _aqm_presentBlock;
}

@end

@implementation UIViewController (AlertQueue)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(viewDidDisappear:);
        SEL swizzledSelector = @selector(aqm_viewDidDisappear:);
        
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        SEL originalSelector1 = @selector(presentViewController:animated:completion:);
        SEL swizzledSelector1 = @selector(aqm_presentViewController:animated:completion:);
        
        Method originalMethod1 = class_getInstanceMethod(self, originalSelector1);
        Method swizzledMethod1 = class_getInstanceMethod(self, swizzledSelector1);
        
        BOOL didAddMethod1 = class_addMethod(self, originalSelector1, method_getImplementation(swizzledMethod1), method_getTypeEncoding(swizzledMethod1));
        
        if (didAddMethod1) {
            class_replaceMethod(self, swizzledSelector1, method_getImplementation(originalMethod1), method_getTypeEncoding(originalMethod1));
        }else {
            method_exchangeImplementations(originalMethod1, swizzledMethod1);
        }
        
        SEL originalSelector2 = @selector(dismissViewControllerAnimated:completion:);
        SEL swizzledSelector2 = @selector(aqm_dismissViewControllerAnimated:completion:);
        
        Method originalMethod2 = class_getInstanceMethod(self, originalSelector2);
        Method swizzledMethod2 = class_getInstanceMethod(self, swizzledSelector2);
        
        BOOL didAddMethod2 = class_addMethod(self, originalSelector2, method_getImplementation(swizzledMethod2), method_getTypeEncoding(swizzledMethod2));
        
        if (didAddMethod2) {
            class_replaceMethod(self, swizzledSelector2, method_getImplementation(originalMethod2), method_getTypeEncoding(originalMethod2));
        }else {
            method_exchangeImplementations(originalMethod2, swizzledMethod2);
        }
    });
}


- (void)aqm_viewDidDisappear:(BOOL)animated
{
    [self aqm_viewDidDisappear:animated];
    // 用于viewController移除时，自动触发 autoContinueAlert 方法，弹出下一个弹窗
    if (self.aqm_cancelBlock) {
        self.aqm_cancelBlock();
    }
}

- (void)aqm_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    // 处理 present 目标 vc.modalPresentationStyle != UIModalPresentationFullScreen 时，无法触发 self 的 viewWillDisappear 方法
    if (self.aqm_presentBlock) {
        self.aqm_presentBlock(viewControllerToPresent);
    }
    
    [self aqm_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)aqm_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    __weak typeof(self) weakSelf = self;
    // 处理present时，页面vc.modalPresentationStyle != UIModalPresentationFullScreen时，关闭页面无法触发manager持有者的viewWillAppear
    [self aqm_dismissViewControllerAnimated:flag completion:^{
        if (completion) {
            completion();
        }
        
        if (weakSelf.aqm_dismissBlock) {
            weakSelf.aqm_dismissBlock();
        }
    }];
}

- (dispatch_block_t)aqm_cancelBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAqm_cancelBlock:(dispatch_block_t)aqm_cancelBlock
{
    objc_setAssociatedObject(self, @selector(aqm_cancelBlock), aqm_cancelBlock, OBJC_ASSOCIATION_COPY);
}

- (dispatch_block_t)aqm_dismissBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAqm_dismissBlock:(dispatch_block_t)aqm_dismissBlock
{
    objc_setAssociatedObject(self, @selector(aqm_dismissBlock), aqm_dismissBlock, OBJC_ASSOCIATION_COPY);
}

- (BLTAlertQueueManagerBlock)aqm_presentBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAqm_presentBlock:(BLTAlertQueueManagerBlock)aqm_presentBlock
{
    objc_setAssociatedObject(self, @selector(aqm_presentBlock), aqm_presentBlock, OBJC_ASSOCIATION_COPY);
}

@end
