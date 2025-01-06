//
//  NSObject+LBResponseChain.m
//  LBUIProject
//
//  Created by liu bin on 2022/7/25.
//

#import "NSObject+LBResponseChain.h"
#import <objc/runtime.h>

@implementation NSObject (LBResponseChain)

- (void)setLb_nextChain:(id)lb_nextChain{
    objc_setAssociatedObject(self, @selector(lb_nextChain), lb_nextChain, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)lb_nextChain{
    return objc_getAssociatedObject(self, _cmd);
}


@end
