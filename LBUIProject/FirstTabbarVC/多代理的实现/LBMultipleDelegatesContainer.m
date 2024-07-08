//
//  LBMultipleDelegates.m
//  LBUIProject
//
//  Created by liu bin on 2022/6/23.
//

#import "LBMultipleDelegatesContainer.h"
#import "NSPointerArray+LBExtension.h"

//实现多代理的容器   利用消息转发来实现多代理
@interface LBMultipleDelegatesContainer ()

@property (nonatomic, strong, readwrite) NSPointerArray *delegates;

@end


@implementation LBMultipleDelegatesContainer

//若引用delegate的容器
+ (instancetype)weakDelegates{
    LBMultipleDelegatesContainer *container = [[LBMultipleDelegatesContainer alloc] init];
    container.delegates = [NSPointerArray weakObjectsPointerArray];
    return container;
}
//强引用delegate的容器
+ (instancetype)strongDelegates{
    LBMultipleDelegatesContainer *container = [[LBMultipleDelegatesContainer alloc] init];
    container.delegates = [NSPointerArray strongObjectsPointerArray];
    return container;
}

- (void)addDelegate:(id)delegate{
    if (delegate == nil) {
        return;
    }
    if ([self containDelegate:delegate] || delegate == self) {
        return;
    }
    [self.delegates addPointer:(__bridge void *)delegate];
}

- (BOOL)removeDelegate:(id)delegate{
    NSUInteger index = [self.delegates lb_indexOfPointer:(__bridge void *)(delegate)];
    if (index == NSNotFound) {
        return false;
    }
    [self.delegates removePointerAtIndex:index];
    return true;
}

- (void)removeAllDelegates{
    for (NSInteger i = self.delegates.count - 1 ; i >= 0; i++) {
        [self.delegates removePointerAtIndex:i];
    }
}

- (BOOL)containDelegate:(id)delegate{
    return [self.delegates lb_indexOfPointer:(__bridge void * _Nonnull)(delegate)] != NSNotFound;
}

#pragma 重写消息转发   实现多协议
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *signature = nil;
    NSPointerArray *array = self.delegates.copy;
    for (id delegate in array) {
        signature = [delegate methodSignatureForSelector:aSelector];
        if (signature && [delegate respondsToSelector:aSelector]) {
            return signature;
        }
    }
//    返回一个不会崩溃的方法签名
    return  [NSMethodSignature signatureWithObjCTypes:"@^v^c"];;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    SEL selector = anInvocation.selector;
    
//    遍历delegate  都执行一遍seletor
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:selector]) {
            [anInvocation invokeWithTarget:delegate];
        }
    }
}

#pragma override

- (BOOL)respondsToSelector:(SEL)aSelector{
    if ([super respondsToSelector:aSelector]) {
        return true;
    }
    
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:aSelector]) {
            return true;
        }
    }
    
    return false;
}

//重写 isKindOfClass 方法  如果delegates里有一个是这个类  默认就是true
- (BOOL)isKindOfClass:(Class)aClass{
    BOOL result = [super isKindOfClass:aClass];
    if (result) {
        return  true;
    }
    
    for (id delegate in self.delegates) {
        if ([delegate isKindOfClass:aClass]) {
            return true;
        }
    }
    
    return false;
}

- (BOOL)isMemberOfClass:(Class)aClass{
    BOOL result = [super isMemberOfClass:aClass];
    if (result) {
        return  true;
    }
    
    for (id delegate in self.delegates) {
        if ([delegate isMemberOfClass:aClass]) {
            return true;
        }
    }
    
    return false;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol{
    BOOL confirm = [super conformsToProtocol:aProtocol];
    if (confirm) {
        return true;
    }
    
    for (id delegate in self.delegates) {
        if ([delegate conformsToProtocol:aProtocol]) {
            return true;
        }
    }
    
    return false;
}

@end
