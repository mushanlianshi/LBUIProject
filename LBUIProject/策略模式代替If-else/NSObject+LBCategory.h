//
//  NSObject+LBCategory.h
//  LBUIProject
//
//  Created by liu bin on 2022/1/18.
//

#import <Foundation/Foundation.h>


@interface NSObject (LBCategory)

- (NSInvocation *)invocationWithSelector:(SEL)selector;

- (NSInvocation *)invocationWithSelector:(SEL)selector arguments:(NSArray *)arguments;

- (NSInvocation *)invocationWithSelector:(SEL)selector target:(id)target arguments:(NSArray *)arguments;

@end


