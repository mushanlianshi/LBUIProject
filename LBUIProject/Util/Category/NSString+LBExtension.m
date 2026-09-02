//
//  NSString+LBExtension.m
//  LBUIProject
//
//  Created by liu bin on 2022/6/23.
//

#import "NSString+LBExtension.h"

@implementation NSString (LBExtension)

- (NSString *)firstCapital{
    if (self.length <= 0) {
        return nil;
    }    
    return [NSString stringWithFormat:@"%@%@",[self substringToIndex:1].capitalizedString, [self substringFromIndex:1]];
}

- (NSComparisonResult)zy_compareWithOtherVersion:(NSString *)otherVersion{
    NSArray<NSString *> *arr1 = [self componentsSeparatedByString:@"."];
    NSArray<NSString *> *arr2 = [otherVersion componentsSeparatedByString:@"."];
    NSInteger maxCount = MAX(arr1.count, arr2.count);
    for (NSInteger i = 0; i < maxCount; i++) {
        NSInteger n1 = (i < arr1.count) ? arr1[i].integerValue : 0;
        NSInteger n2 = (i < arr2.count) ? arr2[i].integerValue : 0;
        if (n1 > n2) return NSOrderedDescending;
        if (n1 < n2) return NSOrderedAscending;
    }
    return NSOrderedSame;
}

@end
