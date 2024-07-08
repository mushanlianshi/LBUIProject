//
//  NSObject+LBMultipleDelegate.m
//  LBUIProject
//
//  Created by liu bin on 2022/6/23.
//

#import "NSObject+LBMultipleDelegate.h"
#import "LBMultipleDelegatesContainer.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "LBHelper.h"
#import <BLTUIKitProject/BLTUI.h>
#import "LBRuntime.h"

@interface NSObject ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, LBMultipleDelegatesContainer *> *lb_delegatesMap;

@end

@implementation NSObject (LBMultipleDelegate)

- (void)setLb_multipleDelegatesEnable:(BOOL)lb_multipleDelegatesEnable{
    objc_setAssociatedObject(self, @selector(lb_multipleDelegatesEnable), @(lb_multipleDelegatesEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (lb_multipleDelegatesEnable) {
        if (!self.lb_delegatesMap) {
            self.lb_delegatesMap = [[NSMutableDictionary alloc] init];
        }
//        注册方法 交换delegate dataSources  到容器去执行
        [self registerDelegateWithSelector:@selector(delegate)];
        if ([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) {
            [self registerDelegateWithSelector:@selector(dataSource)];
        }
    }
}

//处理交换delegate方法
- (void)registerDelegateWithSelector:(SEL)selector{
    if (!self.lb_multipleDelegatesEnable) {
        return;
    }
    if ([self respondsToSelector:@selector(delegate)] == false) {
        return;
    }
    
    NSString *selectorKey = NSStringFromSelector(selector);
    
    SEL originalSetter = setSelectorFromGetter(selector);
    Method originalMethod = class_getInstanceMethod([self class], originalSetter);
//    已经交换过方法  返回
    if (self.lb_delegatesMap[selectorKey]) {
        return;
    }
    
    objc_property_t property = class_getProperty(self.class, selectorKey.UTF8String);
//    char *propertyIsStrong = property_copyAttributeValue(property, "&");
    char *propertyIsWeak = property_copyAttributeValue(property, "W");
//    是weak属性的delegate
    if (propertyIsWeak != NULL) {
        LBMultipleDelegatesContainer *weakContainer = [LBMultipleDelegatesContainer weakDelegates];
        self.lb_delegatesMap[selectorKey] = weakContainer;
    }else{
        LBMultipleDelegatesContainer *strongContainer = [LBMultipleDelegatesContainer strongDelegates];
        self.lb_delegatesMap[selectorKey] = strongContainer;
    }
    
    SEL newSetter = newSetSelectorFromGetter(selector, @"lb");
    
    [LBHelper executeBlock:^{
        
//        原来的setDelegate方法
        IMP originalIMP = method_getImplementation(originalMethod);
        void (*originalSelectorIMP) (id, SEL , id) = (void(*)(id, SEL, id))originalIMP;
        
        //把新的setter方法添加 这里动态生成方法  因为selector可能是多样的
        BOOL isAddMethod = class_addMethod([self class], newSetter, imp_implementationWithBlock(^(NSObject *selfObj, id delegate){
            if (selfObj.lb_multipleDelegatesEnable == false) {
                NSLog(@"LBLog  lb_multipleDelegatesEnable == false");
                originalSelectorIMP(selfObj, originalSetter, delegate);
                return;
            }
            
            NSString *selectorKey = NSStringFromSelector(@selector(delegate));
            LBMultipleDelegatesContainer *delegateContainer = selfObj.lb_delegatesMap[selectorKey];
            if (!delegateContainer) {
                originalSelectorIMP(selfObj, originalSetter, delegate);
                return;
            }
        //    delegate 是nil  移除delegate
            if (delegate == nil) {
                [delegateContainer removeAllDelegates];
                return;
            }
            
        //    把delegate添加到容器中
            if (delegate != delegateContainer) {
                [delegateContainer addDelegate:delegate];
            }
            
            //    先清空delegate
            originalSelectorIMP(selfObj, originalSetter, nil);
            //    把新的delegate设置给容器  让容器去转发
            originalSelectorIMP(selfObj, originalSetter, delegateContainer);
        }), method_getTypeEncoding(originalMethod));
        
//        添加方法成功 交换方法
        if (isAddMethod) {
            Method newMethod = class_getInstanceMethod([self class], newSetter);
            method_exchangeImplementations(originalMethod, newMethod);
        }
    } onceIdentifier:[NSString stringWithFormat:@"MultipleDelegates %@ %@",NSStringFromClass([self class]), NSStringFromSelector(selector)]];
}

- (void)lb_removeDelegate:(id)delegate{
    if (!self.lb_multipleDelegatesEnable) {
        return;
    }
    
    [self.lb_delegatesMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, LBMultipleDelegatesContainer * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj removeDelegate:delegate];
    }];
}

//- (void)lb_setDelegate:(id)delegate{
//    if (self.lb_multipleDelegatesEnable == false) {
//        NSLog(@"LBLog  lb_multipleDelegatesEnable == false");
//        [self lb_setDelegate:delegate];
//        return;
//    }
//
//    NSString *selectorKey = NSStringFromSelector(@selector(delegate));
//    LBMultipleDelegatesContainer *delegateContainer = self.lb_delegatesMap[selectorKey];
//    if (!delegateContainer) {
//        [self lb_setDelegate:delegate];
//        return;
//    }
////    delegate 是nil  移除delegate
//    if (delegate == nil) {
//        [delegateContainer removeAllDelegates];
//        return;
//    }
//
////    把delegate添加到容器中
//    if (delegate != delegateContainer) {
//        [delegateContainer addDelegate:delegate];
//    }
//    [self lb_setDelegate:nil];
//    [self lb_setDelegate:delegateContainer];
//}



- (BOOL)lb_multipleDelegatesEnable{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setLb_delegatesMap:(NSMutableDictionary<NSString *,LBMultipleDelegatesContainer *> *)lb_delegatesMap{
    objc_setAssociatedObject(self, @selector(lb_delegatesMap), lb_delegatesMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString *,LBMultipleDelegatesContainer *> *)lb_delegatesMap{
    return objc_getAssociatedObject(self, _cmd);
}

@end
