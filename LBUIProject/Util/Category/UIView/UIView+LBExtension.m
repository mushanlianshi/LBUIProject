//
//  UIView+LBExtension.m
//  LBUIProject
//
//  Created by liu bin on 2022/8/16.
//

#import "UIView+LBExtension.h"
#import <objc/runtime.h>
#import "LBHelper.h"
#import "LBRuntime.h"
#import <BLTUIKitProject/BLTUI.h>

@implementation UIView (LBExtension)

//+ (void)load{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        LBExchangeImplementationInClass([self class], @selector(hitTest:withEvent:), @selector(lb_hitTest:withEvent:));
//    });
//}
//
//- (UIView *)lb_hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    UIView *view = [self lb_hitTest:point withEvent:event];
//    NSLog(@"LBlog view is %@",view);
//    return  view;
//}


- (void)setLb_hitTestBlock:(UIView *(^)(CGPoint, UIEvent *, UIView *))lb_hitTestBlock{
    objc_setAssociatedObject(self, @selector(lb_hitTestBlock), lb_hitTestBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [LBHelper executeBlock:^{
//        重写他的hitTest方法
        ExtendImplementationOfNonVoidMethodWithTwoArguments([UIView class], @selector(hitTest:withEvent:), CGPoint, UIEvent *, UIView *, ^UIView *(UIView *selfObj, CGPoint point, UIEvent *event, UIView *originReturnView){
            NSLog(@"LBLog originreturnView %@ %@",self.lb_hitTestBlock,originReturnView);
            if (self.lb_hitTestBlock) {
               UIView *view= self.lb_hitTestBlock(point, event, originReturnView);
                return view;
            }
            return originReturnView;
        });
        
//        OverrideImplementation([UIView class], @selector(hitTest:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
//            return ^UIView *(UIView *obj, CGPoint point, UIEvent *event){
//                if (self.lb_hitTestBlock) {
//                    UIView *view = self.lb_hitTestBlock(point, event, obj);
//                    return view;
//                }
//                return obj;
//            };
//        });
//
    } onceIdentifier:@"UIView change HitTest"];
}

- (UIView *(^)(CGPoint, UIEvent *, UIView *))lb_hitTestBlock{
    return objc_getAssociatedObject(self, _cmd);
}


@end
