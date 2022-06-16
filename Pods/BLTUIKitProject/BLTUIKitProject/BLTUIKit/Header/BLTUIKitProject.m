//
//  BLTUIKitProject.m
//  BLTUIKitProject
//
//  Created by liu bin on 2022/1/7.
//

#import "BLTUIKitProject.h"

@interface BLTUIKitProject ()

+ (instancetype)sharedInstance;

@property (nonatomic, copy) void(^callBack)(NSException *exception);

@end

@implementation BLTUIKitProject


+ (instancetype)sharedInstance{
    static BLTUIKitProject *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BLTUIKitProject alloc] init];
    });
    return instance;
}


+ (void)startCatchExceptionCallBack:(void(^)(NSException *exception))callBack{
    [BLTUIKitProject sharedInstance].callBack = callBack;
}

+ (void)catchException:(NSException *)exception{
    if ([BLTUIKitProject sharedInstance].callBack){
        [BLTUIKitProject sharedInstance].callBack(exception);
    }
}

@end
