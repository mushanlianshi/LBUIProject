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
#import "LBBaseNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"LBLog didFinishLaunchingWithOptions ==============");
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[LBBaseNavigationController alloc] initWithRootViewController:[ViewController new]];
    [[UINavigationBar appearance] setTranslucent:NO];
#ifdef DEBUG
    //动态变化的
    // for iOS
    [[NSBundle bundleWithPath:@"/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle"] load];
    NSLog(@"LBLog injection ====");
    
#endif
    [[[LBLoadAndInitializeSubClassController alloc] init] test];
    [MMKV initializeMMKV:nil];
    
    
    [self setNavigationBarAppearance];
    
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

- (void)setNavigationBarAppearance{
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundColor = [UIColor whiteColor];
        [appearance configureWithOpaqueBackground];
        
        UIBarButtonItemAppearance *doneAppearance = [[UIBarButtonItemAppearance alloc] init];
        doneAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName : UIColor.blackColor};
        
        appearance.doneButtonAppearance = doneAppearance;
        appearance.buttonAppearance = doneAppearance;
        appearance.backButtonAppearance = doneAppearance;
        
        [UINavigationBar appearance].scrollEdgeAppearance = appearance;
        [UINavigationBar appearance].standardAppearance = appearance;
        [UINavigationBar appearance].tintColor = [UIColor blackColor];
    } else {
        // Fallback on earlier versions
        [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
        [UINavigationBar appearance].tintColor = [UIColor blackColor];
    }
    
}


@end

