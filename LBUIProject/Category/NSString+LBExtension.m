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

@end
