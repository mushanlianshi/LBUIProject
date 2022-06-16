//
//  BLTAPMObserver.h
//  chugefang
//
//  Created by liu bin on 2021/3/12.
//  Copyright © 2021 baletu123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLTAPMObserverHeader.h"

typedef NS_OPTIONS(NSUInteger, BLTAPMObserverOptions){
    BLTAPMObserverNetworkResponse = 1 << 0, //网络监控
    BLTAPMObserverCPUPercent = 1 << 1,      //cpu使用情况
    BLTAPMObserverMemory = 1 << 2,          //内存
    BLTAPMObserverVCRender = 1 << 3,        //界面渲染
    BLTAPMObserverStartApp = 1 << 4,    //启动时间
    BLTAPMObserverFPS = 1 << 5,         //监控卡顿
    BLTAPMObserverAll = ~0UL,
};

// 已处理网络响应监控  cpu  应用使用的memory
@interface BLTAPMObserver : NSObject

+ (instancetype)sharedInstance;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

//启动监控 回调是给神策上传的字段，可直接上传或则自己在转换处理
- (void)startObserverOption:(BLTAPMObserverOptions)options;

- (void)startObserverOption:(BLTAPMObserverOptions)options observerBlock:(void(^)(BLTAPMObserverOptions option, NSDictionary *observerInfo))observerBlock;

//监控内存 cpu默认的时间间隔  默认30秒间隔
@property (nonatomic, assign) NSTimeInterval observerMemoryCpuInterval;

@end

