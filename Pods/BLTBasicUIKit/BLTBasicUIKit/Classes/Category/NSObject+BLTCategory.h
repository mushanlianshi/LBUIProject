//
//  NSObject+BLTCategory.h
//  BLTBasicUIKit
//
//  Created by liu bin on 2022/1/19.
//

#import <Foundation/Foundation.h>

@interface NSObject (BLTCategory)

//根据selector返回当前对象作为target
- (NSInvocation *)blt_invocationWithSelector:(SEL)selector;

//根据selector返回当前对象作为target arguments是参数
- (NSInvocation *)blt_invocationWithSelector:(SEL)selector arguments:(NSArray *)arguments;

//target是执行的对象 arguments是参数
- (NSInvocation *)blt_invocationWithSelector:(SEL)selector target:(id)target arguments:(NSArray *)arguments;

@end
