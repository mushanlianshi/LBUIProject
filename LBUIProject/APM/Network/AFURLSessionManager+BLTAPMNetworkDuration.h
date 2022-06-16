//
//  AFURLSessionManager+BLTAPMNetworkDuration.h
//  chugefang
//
//  Created by liu bin on 2021/3/23.
//  Copyright © 2021 baletu123. All rights reserved.
//

#import "AFURLSessionManager.h"

//监控请求的接口时长
@interface AFURLSessionManager (BLTAPMNetworkDuration)

//监控 接口慢 没网 代理的
+ (void)startObserverNormalNetworkRun;

//监控超时的
+ (void)startObserverTimeOut;

@end

