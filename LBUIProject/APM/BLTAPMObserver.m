//
//  BLTAPMObserver.m
//  chugefang
//
//  Created by liu bin on 2021/3/12.
//  Copyright © 2021 baletu123. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "BLTAPMObserver.h"
//#import <YKWoodpecker/YKWoodpecker.h>
#import "NSTimer+YYAdd.h"
#import "BLTAPMCPUManager.h"
#import "BLTAPMMemoryManager.h"
#import "BLTAPMNetworkManager.h"
#import "BLTAPMFPSManager.h"
#import <BLTUIKitProject/BLTUI.h>

static CGFloat memoryUnit = (1024 * 1024);

@interface BLTAPMObserver ()

@property (nonatomic, strong) NSTimer *observerTimer;

@property (nonatomic, strong) BLTAPMNetworkManager *networkManager;

@property (nonatomic, strong) BLTAPMFPSManager *fpsManager;

@property (nonatomic, copy) void(^observerBlock) (BLTAPMObserverOptions option, NSDictionary *observerInfo);

@end

@implementation BLTAPMObserver


static BLTAPMObserver *instance;

//extern CFAbsoluteTime  startAppTime;

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BLTAPMObserver alloc] init];
        [instance initialize];
    });
    return instance;
}

- (void)initialize{
    self.observerMemoryCpuInterval = 5;
}



- (void)startObserverOption:(BLTAPMObserverOptions)options observerBlock:(void (^)(BLTAPMObserverOptions, NSDictionary * _Nonnull))observerBlock{
    self.observerBlock = observerBlock;
    //1.启动时间
    if(options & BLTAPMObserverStartApp){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(caculateStartAppTime) name:UIApplicationDidFinishLaunchingNotification object:nil];
    }
    
    //2.cpu和内存使用情况
    if(options & BLTAPMObserverCPUPercent || options & BLTAPMObserverMemory){
        [self observerTimer];
    }
    
    __weak __typeof(&*self)weakSelf = self;
    //3.网络
    if (options & BLTAPMObserverNetworkResponse) {
        [self.networkManager startNetworkWithOptions:BLTAPMNetworkOptionAll callback:^(NSDictionary *dic) {
            [weakSelf p_callBackWithOption:BLTAPMObserverNetworkResponse resultInfo:dic];
        }];
    }
    //4.卡顿
    if (options & BLTAPMObserverFPS) {
        [self.fpsManager startObserverFPSCallBack:^(NSDictionary * _Nonnull resultInfo) {
            [weakSelf p_callBackWithOption:BLTAPMObserverFPS resultInfo:resultInfo];
        }];
    }
}



- (void)caculateStartAppTime{
    CFAbsoluteTime nowTime = CFAbsoluteTimeGetCurrent();
//    CFAbsoluteTime offsetTime = nowTime - startAppTime;
    CFAbsoluteTime offsetTime = nowTime - 0;
//    DEF_DEBUG(@"LBLog caculate startAppTime %@",@(offsetTime));
    BLT_WS(weakSelf);
    if(self.observerBlock){
        NSMutableDictionary *resultDic = @{}.mutableCopy;
        [resultDic setValue:@(BLTAPMObserverStartApp) forKey:@"observerType"];
        [resultDic setValue:@(offsetTime) forKey:@"startAppTime"];
        [weakSelf p_callBackWithOption:BLTAPMObserverStartApp resultInfo:resultDic.copy];
    }
}


#pragma mark - timer selector
- (void)observerCpuMemory{
    CGFloat cpu = [BLTAPMCPUManager cpuPercent];
    uint64_t memory = [BLTAPMMemoryManager getResidentMemory] / memoryUnit;
    uint64_t vitualMemory = [BLTAPMMemoryManager getDeviceUsedMemory] / memoryUnit;
    uint64_t totalPhysicalMemory = [BLTAPMMemoryManager getDeviceTotalPhysicalMemory] / memoryUnit;
//    DEF_DEBUG(@"LBLog observer cpu memory %@ %@ %@ %@",@(cpu), @(memory),@(vitualMemory),@(totalPhysicalMemory));
    BLT_WS(weakSelf);
    if(self.observerBlock){
        NSMutableDictionary *resultInfo = @{}.mutableCopy;
        [resultInfo setValue:@(BLTAPMObserverCPUPercent) forKey:@"observerType"];
        [resultInfo setValue:@(cpu) forKey:@"cpu"];
        [resultInfo setValue:@(memory) forKey:@"memory"];
        [resultInfo setValue:@(vitualMemory) forKey:@"vitualMemory"];
        [resultInfo setValue:@(totalPhysicalMemory) forKey:@"totalPhysicalMemory"];
        [weakSelf p_callBackWithOption:BLTAPMObserverCPUPercent resultInfo:resultInfo.copy];
//        self.observerBlock(BLTAPMObserverCPUPercent, cpu);
//        self.observerBlock(BLTAPMObserverMemory, memory);
    }
}


#pragma mark - 回调
- (void)p_callBackWithOption:(BLTAPMObserverOptions)option resultInfo:(NSDictionary *)resultInfo{
    if (self.observerBlock) {
        self.observerBlock(option, resultInfo);
    }
}


#pragma mark - lazy load
- (BLTAPMNetworkManager *)networkManager{
    if(!_networkManager){
        _networkManager = [[BLTAPMNetworkManager alloc] init];
    }
    return _networkManager;
}

- (BLTAPMFPSManager *)fpsManager{
    if (!_fpsManager) {
        _fpsManager = [BLTAPMFPSManager sharedInstance];
    }
    return _fpsManager;
}

- (NSTimer *)observerTimer{
    if(!_observerTimer){
        _observerTimer = [NSTimer scheduledTimerWithTimeInterval:self.observerMemoryCpuInterval target:self selector:@selector(observerCpuMemory) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_observerTimer forMode:NSRunLoopCommonModes];
    }
    return _observerTimer;
}

@end
