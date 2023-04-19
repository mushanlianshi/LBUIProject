//
//  BLTAPMFPSManager.h
//  chugefang
//
//  Created by liu bin on 2021/3/25.
//  Copyright © 2021 baletu123. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLTAPMFPSManager : NSObject

+ (instancetype)sharedInstance;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
//监控卡顿
- (void)startObserverFPSCallBack:(void(^)(NSDictionary *resultInfo))callback;

- (void)endObserver;

//超过这个值 认为就是卡顿 默认250ms
@property (nonatomic, assign) NSTimeInterval invalidInterval;

@end

NS_ASSUME_NONNULL_END
