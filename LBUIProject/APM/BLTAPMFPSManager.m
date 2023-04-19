//
//  BLTAPMFPSManager.m
//  chugefang
//
//  Created by liu bin on 2021/3/25.
//  Copyright © 2021 baletu123. All rights reserved.
//

#import "BLTAPMFPSManager.h"
#import <mach/mach.h>
//#import <sys/sysctl.h>
//#import <CrashReporter/CrashReporter.h>
//#import "BSBacktraceLogger.h"

@interface BLTAPMFPSManager (){
    dispatch_semaphore_t semaphore;
    CFRunLoopActivity activity;
    CFRunLoopObserverRef runloopObserver;
    BOOL observerValid;
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
        observerValid = true;
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
        runloopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                                kCFRunLoopAllActivities,
                                                                YES,
                                                                0,
                                                                &runLoopObserverCallBack,
                                                                &context);
        CFRunLoopAddObserver(CFRunLoopGetMain(), runloopObserver, kCFRunLoopCommonModes);
        // 创建信号
        semaphore = dispatch_semaphore_create(0);
        // 在子线程监控时长
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            while (self->observerValid)
            {
                // 假定连续5次超时50ms认为卡顿(当然也包含了单次超时250ms)
                long st = dispatch_semaphore_wait(self->semaphore, dispatch_time(DISPATCH_TIME_NOW, self.invalidInterval / intervalCount * NSEC_PER_MSEC));
                if (st != 0)
                {
                    //如果一直在触发source0和接受mach_port的状态 不经历别的状态   说明卡顿了
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

- (void)endObserver{
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), runloopObserver, kCFRunLoopCommonModes);
    CFRelease(runloopObserver);
    runloopObserver = NULL;
    observerValid = false;
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    NSLog(@"LBLog current thread %@  %@",[NSThread currentThread], @(activity), @(kCFRunLoopBeforeSources), @(kCFRunLoopAfterWaiting));
    instance->activity = activity;
    // 发送信号
    dispatch_semaphore_t semaphore = instance->semaphore;
    dispatch_semaphore_signal(semaphore);
}

- (void)p_uploadUnnormalFPS{
    thread_act_array_t threads;
        mach_msg_type_number_t threadCount = 0;
        const task_t thisTask = mach_task_self();
        kern_return_t kr = task_threads(thisTask, &threads, &threadCount);
        if (kr != KERN_SUCCESS) {
            return;
        }
        for (int i = 0; i < threadCount; i++) {
            thread_info_data_t threadInfo;
            thread_basic_info_t threadBaseInfo;
            mach_msg_type_number_t threadInfoCount = THREAD_INFO_MAX;
            if (thread_info((thread_act_t)threads[i], THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadInfoCount) == KERN_SUCCESS) {
                threadBaseInfo = (thread_basic_info_t)threadInfo;
                if (!(threadBaseInfo->flags & TH_FLAGS_IDLE)) {
                    integer_t cpuUsage = threadBaseInfo->cpu_usage / 10;
                    if (cpuUsage > 70) {
                        //cup 消耗大于 70 时打印和记录堆栈
//                        NSString *reStr = smStackOfThread(threads[i]);
                        //记录数据库中
    //                    [[[SMLagDB shareInstance] increaseWithStackString:reStr] subscribeNext:^(id x) {}];
//                        NSLog(@"CPU useage overload thread stack：\n%@",reStr);
                    }
                }
            }
        }

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
