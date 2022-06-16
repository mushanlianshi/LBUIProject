//
//  BLTUIKitProject.h
//  BLTUIKitProject
//
//  Created by liu bin on 2022/1/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLTUIKitProject : NSObject

+ (void)startCatchExceptionCallBack:(void(^)(NSException *exception))callBack;

@end

NS_ASSUME_NONNULL_END
