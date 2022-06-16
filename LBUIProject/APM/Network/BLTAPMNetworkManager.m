//
//  BLTAPMNetworkManager.m
//  chugefang
//
//  Created by liu bin on 2021/3/25.
//  Copyright © 2021 baletu123. All rights reserved.
//

#import "BLTAPMNetworkManager.h"
#import "AFURLSessionManager+BLTAPMNetworkDuration.h"
#import "AFNetworkReachabilityManager.h"

@interface BLTAPMNetworkManager ()

@property (nonatomic, copy) void(^observerCallback)(NSDictionary *resultDic);

@property (nonatomic, assign) BLTAPMNetworkOptions option;

@end

@implementation BLTAPMNetworkManager

- (instancetype)init{
    self = [super init];
    if (self) {
        _limitInterval = 3;
    }
    return self;
}

//callback里的字典可以直接上传给神策  如果需要修改键值   自己转换
- (void)startNetworkWithOptions:(BLTAPMNetworkOptions)options callback:(void(^)(NSDictionary *dic))callback{
    self.observerCallback = callback;
    self.option = options;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bltAPMObserverNetwork:) name:kBLTAPMNetworkObserverNotification object:nil];
    if (options & BLTAPMNetworkOptionTimeout) {
        [AFURLSessionManager startObserverTimeOut];
    }
    if (options & BLTAPMNetworkOptionHasProxy ||
        options & BLTAPMNetworkOptionInterfaceSlow) {
        [AFURLSessionManager startObserverNormalNetworkRun];
    }
    
    if (options & BLTAPMNetworkOptionState) {
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown) {
                [self p_callBackWithDictionary:@{kBLTAPMUploadSensorReqeustNetWorkStateKey : @(status)}];
            }
        }];
    }
}

- (void)bltAPMObserverNetwork:(NSNotification *)notification{
    NSDictionary *info = notification.userInfo;
    NSMutableDictionary *tmpDic = @{}.mutableCopy;
    //1.代理
    if ((self.option & BLTAPMNetworkOptionHasProxy) && [info[kBLTAPMUploadSensorRequestHasProxy] integerValue] > 0) {
        [tmpDic setValue:info[kBLTAPMUploadSensorRequestHasProxy] forKey:kBLTAPMUploadSensorRequestHasProxy];
    }
    
    //2 接口慢
    if ((self.option & BLTAPMNetworkOptionInterfaceSlow) && [info[kBLTAPMUploadSensorReqeustInterfaceSlowKey] floatValue] > self.limitInterval) {
        [tmpDic setValue:info[kBLTAPMUploadSensorReqeustInterfaceSlowKey] forKey:kBLTAPMUploadSensorReqeustInterfaceSlowKey];
    }
    
    //3.超时
    if ((self.option & BLTAPMNetworkOptionTimeout) && [info[kBLTAPMUploadSensorRequestTimeout] integerValue] > 0) {
        [tmpDic setValue:info[kBLTAPMUploadSensorRequestTimeout] forKey:kBLTAPMUploadSensorRequestTimeout];
    }
    [self p_callBackWithDictionary:tmpDic];
}

- (void)p_callBackWithDictionary:(NSDictionary *)dic{
    if (!dic || dic.allKeys.count == 0) {
        return;;
    }
    if (self.observerCallback) {
        self.observerCallback(dic);
    }
}


@end
