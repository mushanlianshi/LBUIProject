//
//  NSObject+BLTCategory.m
//  BLTBasicUIKit
//
//  Created by liu bin on 2022/1/19.
//

#import "NSObject+BLTCategory.h"

@implementation NSObject (BLTCategory)

//根据selector返回当前对象作为target
- (NSInvocation *)blt_invocationWithSelector:(SEL)selector{
    return [self blt_invocationWithSelector:selector arguments:nil];
}

//根据selector返回当前对象作为target arguments是参数
- (NSInvocation *)blt_invocationWithSelector:(SEL)selector arguments:(NSArray *)arguments{
    return [self blt_invocationWithSelector:selector target:self arguments:arguments];
}

//根据selector返回当前对象作为target arguments是参数
- (NSInvocation *)blt_invocationWithSelector:(SEL)selector target:(id)target arguments:(NSArray *)arguments{
    NSMethodSignature *signature = nil;
    if (target) {
        signature = [[target class] instanceMethodSignatureForSelector:selector];
    }else{
        signature = [[self class] instanceMethodSignatureForSelector:selector];
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target ? target : self;
    invocation.selector = selector;
    [arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        从2开始  0和1是target和selector
        [invocation setArgument:&obj atIndex:idx + 2];
    }];
    
#ifdef DEBUG
    //LB DEBUG TEST
//    id firstArgument = nil;
//    使用__unsafe_unretained 不然firstArgument会被释放  导致多次释放  野指针的问题
//    id __unsafe_unretained firstArgument = nil;
    id __weak firstArgument = nil;
    [invocation getArgument:&firstArgument atIndex:0];
    NSLog(@"LBLog argument %@",firstArgument);
#endif
    
    return invocation;
}
    
@end
