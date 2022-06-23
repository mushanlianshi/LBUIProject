//
//  NSPointerArray+LBExtension.m
//  LBUIProject
//
//  Created by liu bin on 2022/6/23.
//

#import "NSPointerArray+LBExtension.h"

@implementation NSPointerArray (LBExtension)

- (BOOL)lb_containsPointer:(void *)pointer{
    if (!pointer) {
        return false;
    }
    
    if ([self lb_indexOfPointer:pointer] == NSNotFound) {
        return false;
    }
    return true;
}


- (NSUInteger)lb_indexOfPointer:(void *)pointer{
    if (!pointer) {
        return  NSNotFound;
    }
    
    NSPointerArray *array = [self copy];
    for(int i = 0; i < array.count; i++){
        if ([array pointerAtIndex:i] == pointer) {
            return i;
        }
    }
    
    return NSNotFound;
}

@end
