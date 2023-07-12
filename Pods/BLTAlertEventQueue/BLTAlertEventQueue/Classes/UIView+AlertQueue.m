//
//  UIView+AlertQueue.m
//  BLTAlertEventQueue
//
//  Created by yinxing on 2023/5/19.
//

#import "UIView+AlertQueue.h"
#import <objc/runtime.h>

@interface UIView ()
{
    dispatch_block_t _aqm_cancelBlock;
}

@end

@implementation UIView (AlertQueue)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector1 = @selector(didMoveToSuperview);
        SEL swizzledSelector1 = @selector(aqm_didMoveToSuperview);
        
        Method originalMethod1 = class_getInstanceMethod(self, originalSelector1);
        Method swizzledMethod1 = class_getInstanceMethod(self, swizzledSelector1);
        
        BOOL didAddMethod1 = class_addMethod(self, originalSelector1, method_getImplementation(swizzledMethod1), method_getTypeEncoding(swizzledMethod1));
        
        if (didAddMethod1) {
            class_replaceMethod(self, swizzledSelector1, method_getImplementation(originalMethod1), method_getTypeEncoding(originalMethod1));
        }else {
            method_exchangeImplementations(originalMethod1, swizzledMethod1);
        }
    });
}

- (void)aqm_didMoveToSuperview
{
    [self aqm_didMoveToSuperview];
    
    // 用于view移除时，自动触发 autoContinueAlert 方法，弹出下一个弹窗
    if (!self.superview && self.aqm_cancelBlock) {
        self.aqm_cancelBlock();
    }
}

- (dispatch_block_t)aqm_cancelBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAqm_cancelBlock:(dispatch_block_t)aqm_cancelBlock
{
    objc_setAssociatedObject(self, @selector(aqm_cancelBlock), aqm_cancelBlock, OBJC_ASSOCIATION_COPY);
}

@end
