//
//  NSString+LBExtension.h
//  LBUIProject
//
//  Created by liu bin on 2022/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (LBExtension)

- (NSString *)firstCapital;

- (NSComparisonResult)zy_compareWithOtherVersion:(NSString *)otherVersion;

@end

NS_ASSUME_NONNULL_END
