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
#import <Selene/Selene.h>
#import "LBTextSplitter.h"
#import "NSString+LBExtension.h"

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

@interface AppDelegate ()<NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSMutableArray      *mArray;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [LBTabbarController new];
//    self.window.rootViewController = [TransparentTabBarController new];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    NSString *env = [[NSProcessInfo processInfo] environment][@"runEnvironment"];
    NSLog(@"LBLog env is %@", env);
#ifdef DEBUG
    //动态变化的
    // for iOS
//    [[NSBundle bundleWithPath:@"/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle"] load];
//    NSLog(@"LBLog injection ====");
    
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
    
//    [[LBFPSManager sharedInstance] startFPSObserver];
//    [self codeCoverageProfrawDump];
//    NSLog(@"LBlog getLocalIPAddress %@", [self getLocalIPAddress:false]);
//    NSLog(@"LBlog getPublicIPAddress %@", [self getNetworkIPAddress]);
    
//    NSURL *url = [[NSURL alloc] initWithString:@"http://jscss.baletoo.com/Public/app/wanjian/map@3x.png"];
//    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    NSLog(@"lblog ---- %@", idfv);
    
//    NSURL *chunkUrl = [NSURL URLWithString:@"http://localhost:8088"];
//    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
//        dataTaskWithURL:chunkUrl
//        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//            // 不走这里，因为是流式，不完整
//        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"LBLog 收到一段数据: %@", data);
//        NSLog(@"LBLog 收到一段数据 string: %@", string);
//        }];
//    task.delegate = self;
//    [task resume];
    [self testSliptor];
    NSLog(@"LBLog user default name is %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"name"]);
    [self testCompareStringVersion];
    return YES;
}

/// 外部 URL 回跳入口：点击灵动岛/锁屏 Live Activity（widgetURL lbuiproject://delivery）、
/// 其他 App 唤起本 App 都走这里。
/// 必须实现：Info.plist 配置了 LSSupportsOpeningDocumentsInPlace，
/// 系统要求 delegate 响应 openURL，缺失会抛 NSInternalInconsistencyException 直接崩溃
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    NSLog(@"LBLog openURL %@ options %@", url.absoluteString, options);
    if ([url.scheme isEqualToString:@"lbuiproject"]) {
        // 外卖配送灵动岛/锁屏卡片深链：lbuiproject://deliveryDetail?orderID=xxx
        // 由 Router 解析订单号，切到「SwiftUI」Tab 并 push 对应订单详情页
        [LBDeliveryDeepLinkRouter handleOpenURL:url];
    }
    return YES;
}
//typedef NS_CLOSED_ENUM(NSInteger, NSComparisonResult) {
//    NSOrderedAscending = -1L,
//    NSOrderedSame,
//    NSOrderedDescending
//};
- (void)testCompareStringVersion{
    NSLog(@"LBLog compare result %@", @([@"1.2.0.1" compare:@"1.2" options:NSNumericSearch]));
    NSLog(@"LBLog compare result %@", @([@"1.2.2.1" compare:@"1.2" options:NSNumericSearch]));
    NSLog(@"LBLog compare result %@", @([@"1.1.1" compare:@"1.2.0.1" options:NSNumericSearch]));
    NSLog(@"LBLog compare result %@", @([@"1.1" compare:@"1.1.0.1" options:NSNumericSearch]));
    NSLog(@"LBLog compare result %@", @([@"1.1" compare:@"1.1.0" options:NSNumericSearch]));
    NSLog(@"LBLog compare result %@", @([@"1.0" compare:@"1.0" options:NSNumericSearch]));
    NSLog(@"LBLog compare result %@", @([@"1.0.2" compare:@"1.0.02" options:NSNumericSearch]));
    NSLog(@"LBLog compare result %@", @([@"1.2.20" compare:@"1.2.20" options:NSNumericSearch]));
    NSLog(@"LBLog compare result ---------------------------------------------");
    NSLog(@"LBLog compare result %@", @([@"1.2.0.1" zy_compareWithOtherVersion:@"1.2"]));
    NSLog(@"LBLog compare result %@", @([@"1.2.2.1" zy_compareWithOtherVersion:@"1.2"]));
    NSLog(@"LBLog compare result %@", @([@"1.1.1" zy_compareWithOtherVersion:@"1.2.0.1"]));
    NSLog(@"LBLog compare result %@", @([@"1.1" zy_compareWithOtherVersion:@"1.1.0.1"]));
    NSLog(@"LBLog compare result %@", @([@"1.1" zy_compareWithOtherVersion:@"1.1.0"]));
    NSLog(@"LBLog compare result %@", @([@"1.0" zy_compareWithOtherVersion:@"1.0"]));
    NSLog(@"LBLog compare result %@", @([@"1.0.2" zy_compareWithOtherVersion:@"1.0.02"]));
    NSLog(@"LBLog compare result %@", @([@"1.2.20" zy_compareWithOtherVersion:@"1.2.20"]));
}
// 实现代理
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSString *chunk = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到一段数据: %@", chunk);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode != 200) {
        NSError *error = [NSError errorWithDomain:@"SSEErrorDomain" code:httpResponse.statusCode userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP request failed with status code %ld", (long)httpResponse.statusCode]}];
        NSLog(error.description);
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    completionHandler(NSURLSessionResponseAllow);
}

//performFetchWithCompletionHandler
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    printf("LBLog======");
    [SLNScheduler startWithCompletion:completionHandler];
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


- (void)testSliptor{
    // 假设这是你的一万字文本
    NSString *longText = [self readTxtFromBundleWithName:@"testLongText"];
    NSLog(@"LBLog longText length is %ld",longText.length);
        // 按大约500字和换行符分割
        NSArray<NSString *> *splitArray = [LBTextSplitter splitText:longText afterApproximateLength:500];
        
        // 输出结果
        NSLog(@"分割后的数组有 %lu 个元素", (unsigned long)splitArray.count);
    NSInteger totalCount = 0;
        for (NSUInteger i = 0; i < splitArray.count; i++) {
            NSString *segment = splitArray[i];
            NSLog(@"第 %lu 段长度: %lu", (unsigned long)i+1, (unsigned long)segment.length);
            totalCount += segment.length;
        }
    NSLog(@"LBLog totalCount length is %ld",totalCount);
}


- (NSString *)readTxtFromBundleWithName:(NSString *)fileName {
    // 获取文件路径（无需扩展名时会自动匹配）
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    if (!filePath) {
        NSLog(@"未找到资源文件: %@.txt", fileName);
        return nil;
    }
    
    // 读取文件内容，指定编码为UTF-8
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:filePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    
    if (error) {
        NSLog(@"读取文件失败: %@", error.localizedDescription);
        return nil;
    }
    
    return content;
}

@end

