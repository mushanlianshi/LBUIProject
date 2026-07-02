//
//  LBFSPagerViewLayoutAttributes.m
//  LBUIProject
//
//  Created by Wenchao Ding on 26/02/2017.
//  Copyright © 2017 Wenchao Ding. All rights reserved.
//  Converted to Objective-C with LB prefix
//

#import "LBFSPagerViewLayoutAttributes.h"

@implementation LBFSPagerViewLayoutAttributes

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[LBFSPagerViewLayoutAttributes class]]) {
        return NO;
    }

    LBFSPagerViewLayoutAttributes *other = (LBFSPagerViewLayoutAttributes *)object;
    BOOL isEqual = [super isEqual:object];
    isEqual = isEqual && (self.position == other.position);
    return isEqual;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    LBFSPagerViewLayoutAttributes *copy = [super copyWithZone:zone];
    copy.position = self.position;
    return copy;
}

@end