//
//  NSObject+UnRecognizeSelector.m
//  LBUIProject
//
//  Created by liu bin on 2022/5/27.
//

#import "NSObject+UnRecognizeSelector.h"
#import <objc/message.h>
#import "LBForwordingTarget.h"

@implementation NSObject (UnRecognizeSelector)


static LBForwordingTarget *forwordingTarget = nil;

+ (void)exchangeMethodClass:(Class)class sel1:(SEL)sel1 sel2:(SEL)sel2{
    Method originalMethod = class_getInstanceMethod(class, sel1);
    Method swizzleMethod = class_getInstanceMethod(class, sel2);

    if (class_addMethod([self class], sel1, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))) {
        class_replaceMethod([self class], sel2, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
}

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
//        第二部来拦截
        forwordingTarget = [[LBForwordingTarget alloc] init];
//        [NSObject exchangeMethodClass:[self class] sel1:@selector(forwardingTargetForSelector:) sel2:@selector(lb_forwardingTargetForSelector:)];
        
//        第三部来拦截  不在第二部是因为有很多UI NSObject 系统的方法会被拦截掉 导致异常
//        [NSObject exchangeMethodClass:[self class] sel1:@selector(forwardInvocation:) sel2:@selector(lb_forwardInvocation:)];
//        [NSObject exchangeMethodClass:[self class] sel1:@selector(methodSignatureForSelector:) sel2:@selector(lb_methodSignatureForSelector:)];
    });
}

- (id)lb_forwardingTargetForSelector:(SEL)sel{
    id result = [self lb_forwardingTargetForSelector:sel];
    NSLog(@"LBLog result %@ %@",result, NSStringFromSelector(sel));
    return forwordingTarget;
}

- (void)lb_forwardInvocation:(NSInvocation *)invocation{
//    [self lb_forwardInvocation:invocation];
//    1.让invocation的target指向一个有实现方法的
//    [invocation invokeWithTarget:forwordingTarget];
//    2.不执行这个invocation
}

//创建一个方法签名
- (NSMethodSignature *)lb_methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *signature = [self lb_methodSignatureForSelector:aSelector];
    if (signature == nil) {
        signature = [LBForwordingTarget instanceMethodSignatureForSelector:@selector(thirdStepSignatureNullMethod)];
    }
    return signature;
}

@end
