//
//  NSObject+LBCategory.m
//  LBUIProject
//
//  Created by liu bin on 2022/1/18.
//

#import "NSObject+LBCategory.h"

@implementation NSObject (LBCategory)

- (NSInvocation *)invocationWithSelector:(SEL)selector{
    return [self invocationWithSelector:selector arguments:nil];
}

- (NSInvocation *)invocationWithSelector:(SEL)selector arguments:(NSArray *)arguments{
    return [self invocationWithSelector:selector target:self arguments:arguments];
}


- (NSInvocation *)invocationWithSelector:(SEL)selector target:(id)target arguments:(NSArray *)arguments{
    NSMethodSignature *signature = nil;
    if (target) {
        signature = [[target class] instanceMethodSignatureForSelector:selector];
    }else{
        signature = [[self class] instanceMethodSignatureForSelector:selector];
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target ? target : self;
    invocation.selector = selector;
    
#ifdef DEBUG
    //LB DEBUG TEST
//    id firstArgument = nil; 这样会crash  局部变量
//    使用__unsafe_unretained  不然firstArgument会被释放  导致多次释放  野指针的问题
//    id __unsafe_unretained firstArgument = nil;
    id __weak firstArgument = nil;
    [invocation getArgument:&firstArgument atIndex:0];
    NSLog(@"LBLog argument %@",firstArgument);
#endif
    [arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        从2开始  0和1是target和selector
        [invocation setArgument:&obj atIndex:idx + 2];
    }];
//    id __unsafe_unretained returnValue  = nil
//    [invocation getReturnValue:&returnValue];
    return invocation;
}

@end
