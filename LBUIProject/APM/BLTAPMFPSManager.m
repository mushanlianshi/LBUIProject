//
//  BLTAPMFPSManager.m
//  chugefang
//
//  Created by liu bin on 2021/3/25.
//  Copyright © 2021 baletu123. All rights reserved.
//

#import "BLTAPMFPSManager.h"
//#import <CrashReporter/CrashReporter.h>
//#import "BSBacktraceLogger.h"

@interface BLTAPMFPSManager (){
    dispatch_semaphore_t semaphore;
    CFRunLoopActivity activity;
}

@property (nonatomic, copy) void(^observerCallback)(NSDictionary *resultInfo);

@end

@implementation BLTAPMFPSManager

static NSInteger timeoutCount = 0;

//间隔的次数 触发这个次数就认为是卡顿
static NSInteger intervalCount = 5;

static BLTAPMFPSManager *instance;

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BLTAPMFPSManager alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if(self){
        self.invalidInterval = 250;
    }
    return self;
}


//typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
//    kCFRunLoopEntry         = (1UL << 0), // 即将进入Loop
//    kCFRunLoopBeforeTimers  = (1UL << 1), // 即将处理 Timer
//    kCFRunLoopBeforeSources = (1UL << 2), // 即将处理 Source
//    kCFRunLoopBeforeWaiting = (1UL << 5), // 即将进入休眠
//    kCFRunLoopAfterWaiting  = (1UL << 6), // 刚从休眠中唤醒
//    kCFRunLoopExit          = (1UL << 7), // 即将退出Loop
//};

- (void)startObserverFPSCallBack:(void (^)(NSDictionary * _Nonnull))callback{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.observerCallback = callback;
        CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
        CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                                kCFRunLoopAllActivities,
                                                                YES,
                                                                0,
                                                                &runLoopObserverCallBack,
                                                                &context);
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
        // 创建信号
        semaphore = dispatch_semaphore_create(0);
        // 在子线程监控时长
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            while (YES)
            {
                // 假定连续5次超时50ms认为卡顿(当然也包含了单次超时250ms)
                long st = dispatch_semaphore_wait(self->semaphore, dispatch_time(DISPATCH_TIME_NOW, self.invalidInterval / intervalCount * NSEC_PER_MSEC));
                if (st != 0)
                {
//                    实时计算 kCFRunLoopBeforeSources 和 kCFRunLoopAfterWaiting 两个状态区域之间的耗时是否超过某个阀值
                    if (self->activity == kCFRunLoopBeforeSources || self->activity == kCFRunLoopAfterWaiting)
                    {
                        if (++ timeoutCount < intervalCount)
                            continue;
                        // 检测到卡顿，进行卡顿上报
//                        DEF_DEBUG(@"LBLog observer kadun -------");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self p_uploadUnnormalFPS];
                        });
                    }
                }
                timeoutCount = 0;
            }
        });
    });
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    instance->activity = activity;
    // 发送信号
    dispatch_semaphore_t semaphore = instance->semaphore;
    dispatch_semaphore_signal(semaphore);
}

- (void)p_uploadUnnormalFPS{
    

//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSString *string = [BSBacktraceLogger bs_backtraceOfMainThread];
//            PLCrashReporterConfig *config = [[PLCrashReporterConfig alloc] initWithSignalHandlerType:PLCrashReporterSignalHandlerTypeBSD
//                                                                               symbolicationStrategy:PLCrashReporterSymbolicationStrategyAll];
//            PLCrashReporter *crashReporter = [[PLCrashReporter alloc] initWithConfiguration:config];
//            NSData *data = [crashReporter generateLiveReport];
//            PLCrashReport *reporter = [[PLCrashReport alloc] initWithData:data error:NULL];
//            NSString *report = [PLCrashReportTextFormatter stringValueForCrashReport:reporter
//                                                                      withTextFormat:PLCrashReportTextFormatiOS];
//        DEF_DEBUG(@"LBLog kadun %@",report);
//    });
//    DEF_DEBUG(@"LBLog find kadun %@",report);
    
}

@end
