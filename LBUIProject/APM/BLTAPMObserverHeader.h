//
//  BLTAPMObserverHeader.h
//  blt_realtorwell
//
//  Created by liu bin on 2021/3/25.
//  Copyright © 2021 baletu123. All rights reserved.
//

#ifndef BLTAPMObserverHeader_h
#define BLTAPMObserverHeader_h
#import "BLTAPMObserver.h"

static NSString * const kBLTAPMNetworkObserverNotification = @"BLTAPMNetworkObserverNotification";

static NSString * const kBLTAPMUploadSensorReqeustNetWorkStateKey = @"requestNetworkState";

static NSString * const kBLTAPMUploadSensorReqeustInterfaceSlowKey = @"requestInterfaceSlow";

static NSString * const kBLTAPMUploadSensorRequestHasProxy = @"requestHasProxy";

static NSString * const kBLTAPMUploadSensorRequestTimeout = @"requestTimeout";

static NSString * const kBLTAPMUploadSensorUnnormalUrl = @"requestUnnormalUrl";

//网络监控的类型
typedef NS_OPTIONS(NSUInteger,BLTAPMNetworkOptions){
    BLTAPMNetworkOptionState = 1 << 0,        //联网状态
    BLTAPMNetworkOptionInterfaceSlow = 1 << 1,    //接口慢
    BLTAPMNetworkOptionHasProxy = 1 << 2 ,        //设置了代理
    BLTAPMNetworkOptionTimeout = 1 << 3,        //超时
    BLTAPMNetworkOptionAll = ~0UL,
};



#endif /* BLTAPMObserverHeader_h */
