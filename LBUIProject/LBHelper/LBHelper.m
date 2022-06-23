//
//  LBHelper.m
//  LBUIProject
//
//  Created by liu bin on 2022/6/21.
//

#import "LBHelper.h"

@implementation LBHelper

static NSMutableSet <NSString *>*identifiers;
+ (BOOL)executeBlock:(dispatch_block_t)closure onceIdentifier:(NSString *)onceIdentifier{
    if (closure == nil || onceIdentifier.length <= 0) {
        return false;
    }
    @synchronized (self) {
        if (identifiers == nil) {
            identifiers = [NSMutableSet new];
        }
        if (![identifiers containsObject:onceIdentifier]) {
            [identifiers addObject:onceIdentifier];
            closure();
            return true;
        }
        return  false;
    }
}

@end
