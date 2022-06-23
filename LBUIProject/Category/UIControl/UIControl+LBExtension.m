//
//  UIControl+LBExtension.m
//  LBUIProject
//
//  Created by liu bin on 2022/6/21.
//

#import "UIControl+LBExtension.h"
#import <objc/runtime.h>
#import "LBUIProject-Swift.h"
#import "LBHelper.h"
#import <BLTUIKitProject/BLTUI.h>

@implementation UIControl (LBExtension)


- (void)setLb_preventRepeatTouchUpInside:(bool)lb_preventRepeatTouchUpInside{
    objc_setAssociatedObject(self, @selector(lb_preventRepeatTouchUpInside), @(lb_preventRepeatTouchUpInside), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (lb_preventRepeatTouchUpInside) {
        [LBHelper executeBlock:^{
            swizzleInstanceMethod([self class], @selector(sendAction:to:forEvent:), @selector(lb_sendAction:to:forEvent:));
        } onceIdentifier:@"UIControl lb_preventRepeatTouch"];
    }
}

- (bool)lb_preventRepeatTouchUpInside{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
    
}


- (void)lb_sendAction:(SEL)action to:(nullable id)target forEvent:(nullable UIEvent *)event{
    if (self.lb_preventRepeatTouchUpInside) {
//        获取当前target多个actions 是否能响应这个action  不能可能存在消息转发别的情况的
        NSArray<NSString *> *actions = [self actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
        if (actions == nil) {
            actions = [self actionsForTarget:target forControlEvent:UIControlEventPrimaryActionTriggered];
        }
        NSLog(@"LBLog touch actions %@",actions);
        if ([actions containsObject:NSStringFromSelector(action)]) {
            UITouch *touch = event.allTouches.anyObject;
            NSLog(@"LBLog touch count %@",@(touch.tapCount));
            if (touch.tapCount > 1) {
                return;
            }
        }
    }
    
    [self lb_sendAction:action to:target forEvent:event];
}


@end
