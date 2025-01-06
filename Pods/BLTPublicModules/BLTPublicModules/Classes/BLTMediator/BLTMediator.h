//
//  BLTMediator.h
//  Baletu
//
//  Created by Baletoo on 2020/3/25.
//  Copyright © 2020 Baletu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLTMediatorConfiguration.h"

extern NSString * _Nonnull const kBLTMediatorParamsKeySwiftTargetModuleName;

@interface BLTMediator : NSObject

@property (nonatomic, strong) BLTMediatorConfiguration *configuration;

+ (instancetype _Nonnull)sharedInstance;

// 远程App调用入口
- (id _Nullable)performActionWithUrl:(NSURL * _Nullable)url completion:(void(^_Nullable)(NSDictionary * _Nullable info))completion;
// 本地组件调用入口
- (id _Nullable )performTarget:(NSString * _Nullable)targetName action:(NSString * _Nullable)actionName params:(NSDictionary * _Nullable)params shouldCacheTarget:(BOOL)shouldCacheTarget;
- (void)releaseCachedTargetWithTargetName:(NSString *_Nullable)targetName;

@end
