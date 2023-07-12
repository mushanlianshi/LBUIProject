//
//  UINavigationController+AlertQueue.m
//  BLTAlertEventQueue
//
//  Created by yinxing on 2023/5/24.
//

#import "UINavigationController+AlertQueue.h"
#import <objc/runtime.h>

@interface UINavigationController ()
{
    BLTAlertQueueManagerPushBlock _aqm_qushBlock;
}

@end

@implementation UINavigationController (AlertQueue)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(pushViewController:animated:);
        SEL swizzledSelector = @selector(aqm_pushViewController:animated:);
        
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)aqm_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 用于处理从alert跳转页面后，继续push导致无法调用到 aqm_dismissBlock 回调
    if (self.aqm_qushBlock) {
        self.aqm_qushBlock(viewController);
    }
    [self aqm_pushViewController:viewController animated:animated];
    
}

- (BLTAlertQueueManagerPushBlock)aqm_qushBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAqm_qushBlock:(BLTAlertQueueManagerPushBlock)aqm_qushBlock
{
    objc_setAssociatedObject(self, @selector(aqm_qushBlock), aqm_qushBlock, OBJC_ASSOCIATION_COPY);
}

@end
