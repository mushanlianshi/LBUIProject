//
//  LBCrashManager.h
//  LBUIProject
//
//  Created by liu bin on 2022/5/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBCrashManager : NSObject

+ (instancetype)sharedInstance;

- (void)startCatchCrash;

@end

NS_ASSUME_NONNULL_END
