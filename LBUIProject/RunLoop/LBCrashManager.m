//
//  LBCrashManager.m
//  LBUIProject
//
//  Created by liu bin on 2022/5/27.
//

#import "LBCrashManager.h"
#import "stdatomic.h"

@implementation LBCrashManager

static LBCrashManager * instance = nil;

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LBCrashManager alloc] init];
    });
    return instance;
}

atomic_int  LBUncaughtExceptionCount = 0;
const int LBUncaughtExceptionMaxCount = 8;

void catchExceptionHandler(NSException * exception){
    NSLog(@"LBLog exction %@",exception);
//    atomic_fetch_add_explicit(&LBUncaughtExceptionCount, 1, memory_order_relaxed); // atomic
    atomic_int exceptionCount = atomic_fetch_add_explicit(&LBUncaughtExceptionCount, 1, memory_order_relaxed);
//    大于最大的捕捉个数
    NSLog(@"LBLog exctionCount = %zd %zd",exceptionCount, LBUncaughtExceptionCount);
    if (exceptionCount > LBUncaughtExceptionMaxCount) {
        return;
    }
    useRunloopAvoidCrash();
}


- (void)startCatchCrash{
    NSSetUncaughtExceptionHandler(&catchExceptionHandler);
}

//使用runloop 切换runloop的mode 让死掉的runloop重新运行
void useRunloopAvoidCrash(){
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFArrayRef array= CFRunLoopCopyAllModes(runloop);
    while (true) {
        for (NSString *model in ((__bridge NSArray *)array)) {
            NSLog(@"LBLog current runloop model is %@",model);
            CFRunLoopRunInMode((CFStringRef)model, 0.002, false);
        }
    }
}

@end
