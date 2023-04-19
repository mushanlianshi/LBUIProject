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
#import <sys/socket.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

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

@property (nonatomic, strong) NSMutableArray      *mArray;

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
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[[LBLoadAndInitializeSubClassController alloc] init] test];
//    });
    [MMKV initializeMMKV:nil];
    
    [LYJInitSwiftManager initNeededSDK];
    [self setNavigationBarAppearance];
    self.mArray = [NSMutableArray new];
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"1",@"2", nil];
        self.mArray = arr;
    //// 12343 NULL
        void (^kcBlock)(void) = ^{
            [arr addObject:@"3"];
            [self.mArray addObject:@"a"];
            NSLog(@"LBLog KC %@",arr);
            NSLog(@"LBLog Cooci: %@",self.mArray);
        };
        [arr addObject:@"4"];
        [self.mArray addObject:@"5"];
        
        arr = nil;
        self.mArray = nil;
        
        kcBlock();
    
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
    
    
//    [[LBFPSManager sharedInstance] startFPSObserver];
//    [self codeCoverageProfrawDump];
//    NSLog(@"LBlog getLocalIPAddress %@", [self getLocalIPAddress:false]);
//    NSLog(@"LBlog getPublicIPAddress %@", [self getNetworkIPAddress]);
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

- (NSString *)getNetworkIPAddress {
    //方式一：淘宝api
    NSURL *ipURL = [NSURL URLWithString:@"http://ip.taobao.com/service/getIpInfo.php?ip=myip"];
    NSData *data = [NSData dataWithContentsOfURL:ipURL];
    NSDictionary *ipDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *ipStr = nil;
    if (ipDic && [ipDic[@"code"] integerValue] == 0) {
        //获取成功
        ipStr = ipDic[@"data"][@"ip"];
    }
    return (ipStr ? ipStr : @"0.0.0.0");
}



#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

- (NSString *)getLocalIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

- (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}

- (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}



@end

