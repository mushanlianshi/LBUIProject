//
//  BLTMediator.m
//  Baletu
//
//  Created by Baletoo on 2020/3/25.
//  Copyright © 2020 Baletu. All rights reserved.
//

#import "BLTMediator.h"
#import <objc/runtime.h>
#import "BLTModulesConfigManager.h"
#import "BLTModuleMediatorConfigDelegate.h"

NSString * const kBLTMediatorParamsKeySwiftTargetModuleName = @"kBLTMediatorParamsKeySwiftTargetModuleName";

@interface BLTMediator ()

@property (nonatomic, strong) NSMutableDictionary *cachedTarget;

@end

@implementation BLTMediator

#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static BLTMediator *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[BLTMediator alloc] init];
    });
    return mediator;
}

/*
 scheme://[target]/[action]?[params]
 
 url sample:
 aaa://targetA/actionB?id=1234
 */

- (id)performActionWithUrl:(NSURL *)url completion:(void (^)(NSDictionary *))completion
{
    if (url == nil) {
        return nil;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *actionName = nil;
    NSString *targetName = nil;
    if (self.configuration.urlCustomParseBlock) {
        // 若configuration实现了URL自定义解析，则执行自定义的解析
        BLTMediatorURLParseObject *parseResult = self.configuration.urlCustomParseBlock(url);
        params = parseResult.params.mutableCopy;
        targetName = parseResult.targetName;
        actionName = parseResult.actionName;
    }
    else {
        NSString *urlString = [url query];
        for (NSString *param in [urlString componentsSeparatedByString:@"&"]) {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if([elts count] < 2) continue;
            [params setObject:[elts lastObject] forKey:[elts firstObject]];
        }
        
        actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
        if ([actionName hasPrefix:@"native"]) {
            return nil;
        }
        
        targetName = url.host;
    }
        
    id<NSObject> config = [BLTModulesConfigManager modulesConfig];
    if ([config conformsToProtocol:@protocol(BLTModuleMediatorConfigDelegate)]) {
        id<BLTModuleMediatorConfigDelegate> mConfig = (id<BLTModuleMediatorConfigDelegate>)config;
        if ([mConfig respondsToSelector:@selector(bltMediatorSwiftModuleParamasWithTarget:action:paramas:)]) {
            params = [mConfig bltMediatorSwiftModuleParamasWithTarget:targetName action:actionName paramas:params].mutableCopy;
        }
    }

    id result = [self performTarget:targetName action:actionName params:params shouldCacheTarget:NO];
    if (completion) {
        if (result) {
            completion(@{@"result":result});
        } else {
            completion(nil);
        }
    }
    return result;
}

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget
{
    if (targetName == nil || actionName == nil) {
        return nil;
    }
    
    NSString *swiftModuleName = params[kBLTMediatorParamsKeySwiftTargetModuleName];
    
    // generate target
    NSString *targetClassString = nil;
    if (swiftModuleName.length > 0) {
        targetClassString = [NSString stringWithFormat:@"%@.Target_%@", swiftModuleName, targetName];
    } else {
        targetClassString = [NSString stringWithFormat:@"Target_%@", targetName];
    }
    NSObject *target = self.cachedTarget[targetClassString];
    if (target == nil) {
        Class targetClass = NSClassFromString(targetClassString);
        target = [[targetClass alloc] init];
    }
    
    // 若target实现了shouldPerformWithTarget:action:params:shouldCacheTarget:方法，检查是否允许执行
    if ([target conformsToProtocol:@protocol(BLTMediatorPerformCircleProtocol)]) {
        if ([target respondsToSelector:@selector(shouldPerformWithTarget:action:params:shouldCacheTarget:)]) {
            BOOL shouldPerform = [(id<BLTMediatorPerformCircleProtocol>)target shouldPerformWithTarget:targetName action:actionName params:params shouldCacheTarget:shouldCacheTarget];
            if (!shouldPerform) {
                return nil;
            }
        }
    }

    // generate action
    NSString *actionString = [NSString stringWithFormat:@"Action_%@:", actionName];
    SEL action = NSSelectorFromString(actionString);
    
    if (target == nil) {
        //TODO 处理无响应请求
        
        [self NoTargetActionResponseWithTargetString:targetClassString selectorString:actionString originParams:params];
        return nil;
    }
    
    if (shouldCacheTarget) {
        self.cachedTarget[targetClassString] = target;
    }

    if ([target respondsToSelector:action]) {
        id returnObject = [self safePerformAction:action target:target params:params];

        id<NSObject> config = [BLTModulesConfigManager modulesConfig];
        if ([config conformsToProtocol:@protocol(BLTModuleMediatorConfigDelegate)]) {
            id<BLTModuleMediatorConfigDelegate> mConfig = (id<BLTModuleMediatorConfigDelegate>)config;
            
            if ([config respondsToSelector:@selector(bltMediatorWillReturnObject:paramas:)]) {
                [mConfig bltMediatorWillReturnObject:returnObject paramas:params];
            }
        }
        return returnObject;
    } else {
        //TODO 处理无响应请求，如果无响应，则尝试调用对应target的notFound方法统一处理
        SEL action = NSSelectorFromString(@"notFound:");
        if ([target respondsToSelector:action]) {
            return [self safePerformAction:action target:target params:params];
        } else {
            //TODO 处理无响应请求
            
            [self NoTargetActionResponseWithTargetString:targetClassString selectorString:actionString originParams:params];
            [self.cachedTarget removeObjectForKey:targetClassString];
            return nil;
        }
    }
}

- (void)releaseCachedTargetWithTargetName:(NSString *)targetName
{
    if (targetName == nil) {
        return;
    }
    NSString *targetClassString = [NSString stringWithFormat:@"Target_%@", targetName];
    [self.cachedTarget removeObjectForKey:targetClassString];
}

#pragma mark - private methods
- (void)NoTargetActionResponseWithTargetString:(NSString *)targetString selectorString:(NSString *)selectorString originParams:(NSDictionary *)originParams
{
    SEL action = NSSelectorFromString(@"Action_response:");
    NSObject *target = [[NSClassFromString(@"Target_NoTargetAction") alloc] init];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"originParams"] = originParams;
    params[@"targetString"] = targetString;
    params[@"selectorString"] = selectorString;
    
    [self safePerformAction:action target:target params:params];
}

- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(NSDictionary *)params
{
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    if(methodSig == nil) {
        return nil;
    }
    const char* retType = [methodSig methodReturnType];

    if (strcmp(retType, @encode(void)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        return nil;
    }

    if (strcmp(retType, @encode(NSInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(BOOL)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        BOOL result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(CGFloat)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(NSUInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
}

#pragma mark - getters and setters
- (NSMutableDictionary *)cachedTarget
{
    if (_cachedTarget == nil) {
        _cachedTarget = [[NSMutableDictionary alloc] init];
    }
    return _cachedTarget;
}

@end
