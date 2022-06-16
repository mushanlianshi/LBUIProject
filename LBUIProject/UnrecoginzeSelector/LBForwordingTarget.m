//
//  LBForwordingTarget.m
//  LBUIProject
//
//  Created by liu bin on 2022/5/27.
//

#import "LBForwordingTarget.h"
#import <objc/message.h>

//为什么转发到 LBForwordingTarget  在动态添加方法来避免崩溃  而不是直接交换的时候动态添加方法来避免崩溃，
//那样的话 每个类都可能被动态添加了不属于自己的方法  影响效率和隔离，我们把所有找不到方法的都转发到LBForwordingTarget这个类中然后给这个类
//动态添加方法来避免崩溃，可以做到隔离，分类更清晰
@implementation LBForwordingTarget

id newDynamicMethodAvoidCrash(id self, SEL _cmd){
    return  [NSNull null];
}

//消息转发第一步 判断有没有动态添加方法来避免崩溃  如果没有走第二部
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    class_addMethod(self.class, sel, (IMP)newDynamicMethodAvoidCrash, "@@:");
    return [super resolveInstanceMethod:sel];
}

//消息转发第二部 有没有转发到别的target来避免崩溃  没有转发target 走第三部
- (id)forwardingTargetForSelector:(SEL)aSelector{
    return [super forwardingTargetForSelector:aSelector];
}



//消息转发第三部  返回一个方法签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    return [super methodSignatureForSelector:aSelector];
}

//谁来执行这个invocation
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    [super forwardInvocation:anInvocation];
}

- (void)thirdStepSignatureNullMethod{
    
}


@end
