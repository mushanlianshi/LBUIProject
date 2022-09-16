//
//  AppDelegate.m
//  LBUIProject
//
//  Created by liu bin on 2021/5/27.
//

#import "AppDelegate.h"
#import "LBHomeViewController.h"
#import "LBFPSManager.h"
#import <MMKV/MMKV.h>
#import <AvoidCrash/AvoidCrash.h>
#import "LBLoadAndInitializeSubClassController+Test4.h"
#import "LBBaseNavigationController.h"
#import "LBUIProject-Swift.h"

struct A{
    int    a;
    char   b;
    short  c;
};
struct B{
    char   b;
    int    a;
    short  c;
};


//extern "C" {
//extern int __llvm_profile_set_filename(const char*);
//extern int __llvm_profile_write_file(void);
//}

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"LBLog didFinishLaunchingWithOptions ==============");
    struct A a;
    struct B b;
    NSLog(@"LBLog a %@ ==============",@(sizeof(a)));
    NSLog(@"LBLog b %@ ==============",@(sizeof(b)));
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [LBTabbarController new];
//    self.window.rootViewController = [LBHomeViewController new];
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
//    [self codeCoverageProfrawDump];
    return YES;
}

//- (void)codeCoverageProfrawDump{
//    NSString *name = @"lb.profraw";
//    NSError *error = nil;
//    NSURL *url = [NSFileManager.defaultManager URLForDirectory:NSDocumentationDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:false error:&error];
//    url = [url URLByAppendingPathComponent:name];
////    char *fileName = url.absoluteString.UTF8String;
//    __llvm_profile_set_filename(url.absoluteString.UTF8String);
//    __llvm_profile_write_file();
//}


// MARK: - 代码覆盖率
//func codeCoverageProfrawDump(fileName: String = "cc") {
//    let name = "\(fileName).profraw"
//    let fileManager = FileManager.default
//    do {
//        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
//        let filePath: NSString = documentDirectory.appendingPathComponent(name).path as NSString
//        __llvm_profile_set_filename(filePath.utf8String)
//        print("File at: \(String(cString: __llvm_profile_get_filename()))")
//        __llvm_profile_write_file()
//    } catch {
//        print(error)
//    }
//}


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

