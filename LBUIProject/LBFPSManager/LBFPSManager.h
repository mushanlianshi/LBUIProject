//
//  LBFPSManager.h
//  LBUIProject
//
//  Created by liu bin on 2021/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBFPSManager : NSObject

+ (instancetype)sharedInstance;

- (void)startFPSObserver;

- (void)stopFPSObserver;

@end

NS_ASSUME_NONNULL_END
