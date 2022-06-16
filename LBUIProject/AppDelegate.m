//
//  AppDelegate.m
//  LBUIProject
//
//  Created by liu bin on 2021/5/27.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "LBFPSManager.h"
#import <MMKV/MMKV.h>
#import <AvoidCrash/AvoidCrash.h>
#import "LBLoadAndInitializeSubClassController+Test4.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"LBLog didFinishLaunchingWithOptions ==============");
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    [[UINavigationBar appearance] setTranslucent:NO];
#ifdef DEBUG
    //动态变化的
    // for iOS
    [[NSBundle bundleWithPath:@"/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle"] load];
    NSLog(@"LBLog injection ====");
    
#endif
    [[[LBLoadAndInitializeSubClassController alloc] init] test];
    [MMKV initializeMMKV:nil];
    
//    [AvoidCrash makeAllEffective];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        CFTimeInterval startTime = CACurrentMediaTime();
//        for (int i = 0; i < 10000; i ++ ) {
//            MMKV *mmkv = [MMKV defaultMMKV];
//            [mmkv setInt32:32 forKey:[NSString stringWithFormat:@"%d",i]];
//        }
//        CFTimeInterval endTime = CACurrentMediaTime();
//        CFTimeInterval consumingTime = endTime - startTime;
//        NSLog(@"LBLog mmkv 耗时：%@", @(consumingTime));
//        
//        
//        CFTimeInterval startTime22 = CACurrentMediaTime();
//        for (int i = 0; i < 10000; i ++ ) {
//            NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
//            [userDef setObject:@(32) forKey:[NSString stringWithFormat:@"u%d",i]];
//        }
//        CFTimeInterval endTime22 = CACurrentMediaTime();
//        CFTimeInterval consumingTime22 = endTime22 - startTime22;
//        NSLog(@"LBLog nsuserdefault 耗时：%@", @(consumingTime22));
//    });
    
    
    [[LBFPSManager sharedInstance] startFPSObserver];
    return YES;
}



@end

