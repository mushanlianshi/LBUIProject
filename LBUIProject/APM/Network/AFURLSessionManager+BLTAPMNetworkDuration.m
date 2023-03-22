//
//  AFURLSessionManager+BLTAPMNetworkDuration.m
//  chugefang
//
//  Created by liu bin on 2021/3/23.
//  Copyright © 2021 baletu123. All rights reserved.
//

#import "AFURLSessionManager+BLTAPMNetworkDuration.h"
#import "BLTAPMObserverHeader.h"
#import <BLTUIKitProject/BLTUI.h>


static NSInteger const kRequestTimeoutCode = -1001;

@implementation AFURLSessionManager (BLTAPMNetworkDuration)

//监控 接口慢 没网 代理的
+ (void)startObserverNormalNetworkRun{
    if (@available(iOS 10.0, *)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            swizzleInstanceMethod([AFURLSessionManager class], @selector(URLSession:task:didFinishCollectingMetrics:), @selector(blt_duration_URLSession:task:didFinishCollectingMetrics:));
        });
    }
}

//监控超时的
+ (void)startObserverTimeOut{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzleInstanceMethod([AFURLSessionManager class], @selector(URLSession:task:didCompleteWithError:), @selector(blt_timeout_URLSession:task:didCompleteWithError:));
    });
}


- (void)blt_duration_URLSession:(NSURLSession *)session
                           task:(NSURLSessionTask *)task
     didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics
API_AVAILABLE(ios(10.0)){
    [self blt_duration_URLSession:session task:task didFinishCollectingMetrics:metrics];
    NSMutableDictionary *dic = @{}.mutableCopy;
    if ([self p_checkProxySetting]) {
        [dic setValue:@(1) forKey:kBLTAPMUploadSensorRequestHasProxy];
    }
    [dic setValue:@(metrics.taskInterval.duration) forKey:kBLTAPMUploadSensorReqeustInterfaceSlowKey];
    [dic setValue:task.currentRequest.URL.absoluteString forKey:kBLTAPMUploadSensorUnnormalUrl];
    [self p_postNotificationWithDictionary:dic.copy];
}

- (void)blt_timeout_URLSession:(NSURLSession *)session
                          task:(NSURLSessionTask *)task
          didCompleteWithError:(NSError *)error{
    [self blt_timeout_URLSession:session task:task didCompleteWithError:error];
    if (error.code == kRequestTimeoutCode) {
        [self p_postNotificationWithDictionary:@{kBLTAPMUploadSensorRequestTimeout : @(1),
                                                 kBLTAPMUploadSensorUnnormalUrl : task.currentRequest.URL.absoluteString ?:@"",
        }];
    }
}

- (void)p_postNotificationWithDictionary:(NSDictionary *)dictionary{
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLTAPMNetworkObserverNotification object:self userInfo:dictionary];
}


- (BOOL) p_checkProxySetting {
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
        //是否开启了http代理
        if ([proxySettings[@"HTTPEnable"] boolValue] && proxySettings[@"HTTPProxy"]) {
            return YES;
        }
        if ([proxySettings[@"HTTPSEnable"] boolValue] && proxySettings[@"HTTPSProxy"]) {
            return YES;
        }
        return NO;
}


@end
