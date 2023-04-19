//
//  BLTOnceManager.m
//  Baletoo_landlord
//
//  Created by liu bin on 2022/9/5.
//  Copyright © 2022 com.wanjian. All rights reserved.
//

#import "BLTOnceManager.h"

static NSMutableSet <NSString *> *identifierSet;
@implementation BLTOnceManager

+ (BOOL)executeBlock:(dispatch_block_t)block onceIdentifier:(NSString *)onceIdentifier{
    if (block == nil || onceIdentifier.length <= 0) {
        return false;
    }
    
    @synchronized (self) {
        if (identifierSet == nil) {
            identifierSet = [NSMutableSet new];
        }
        if (![identifierSet containsObject:onceIdentifier]) {
            [identifierSet addObject:onceIdentifier];
            block();
            return true;
        }
        
        return false;
    }
}

@end
