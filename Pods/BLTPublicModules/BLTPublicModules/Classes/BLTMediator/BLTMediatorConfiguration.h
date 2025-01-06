//
//  BLTMediatorConfiguration.h
//  Baletu
//
//  Created by Baletoo on 2020/3/25.
//  Copyright © 2020 Baletu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BLTMediatorPerformCircleProtocol <NSObject>

@optional

- (BOOL)shouldPerformWithTarget:(NSString * _Nullable)targetName
                         action:(NSString * _Nullable)actionName
                         params:(NSDictionary * _Nullable)params
              shouldCacheTarget:(BOOL)shouldCacheTarget;

@end

@class BLTMediatorURLParseObject;

typedef BLTMediatorURLParseObject * _Nullable(^BLTMediatorURLCustomParseBlock)(NSURL *url);

@interface BLTMediatorConfiguration : NSObject

@property (nonatomic, copy) BLTMediatorURLCustomParseBlock urlCustomParseBlock;

@end

@interface BLTMediatorURLParseObject : NSObject

@property (nonatomic, copy) NSString *targetName;

@property (nonatomic, copy) NSString *actionName;

@property (nonatomic, copy) NSDictionary *params;

@end

NS_ASSUME_NONNULL_END
