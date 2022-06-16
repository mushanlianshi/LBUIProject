//
//  LBStrategyModeController.m
//  LBUIProject
//
//  Created by liu bin on 2022/1/18.
//

#import "LBStrategyModeController.h"
#import "NSObject+LBCategory.h"


@interface LBTestStrategyObject : NSObject
- (NSString *)caculateDDD:(NSDictionary *)info;
@end


@implementation LBTestStrategyObject

- (NSString *)caculateDDD:(NSDictionary *)info{
    NSLog(@"LBLog caculateDDD ========");
    return info[@"url"];
}

@end





//使用策略模式来消除if-else
@interface LBStrategyModeController ()

@end

@implementation LBStrategyModeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *desc = [self getDescFromCode:@"1001"];
    NSLog(@"LBlog desc %@",desc);

    [self executeDifferentResult:@"3000"];
    [self executeDifferentResult:@"4000"];
    
//    id __weak array1 = [NSMutableArray new];
//    [array1 addObject:@"111"];
//    NSLog(@"LBLog array %@",array1);
//
//    id __unsafe_unretained array2 = [NSMutableArray new];
//    [array2 addObject:@"111"];
//    NSLog(@"LBLog array2 %@",array2);
}


//策略模式代替if-else    避免异常冗长难读
- (NSString *)getDescFromCode:(NSString *)code{
    NSDictionary *dic = @{
        @"1001" : @"网络出错了",
        @"1002" : @"ut校验失败",
        @"404" : @"没有找到接口",
    };
    NSString *desc = dic[code];
    return desc;
    
//    if ([code isEqualToString: @"1001"]) {
//        return @"网络出错了";
//    }else if ([code isEqualToString: @"1002"]){
//        return @"ut校验失败";
//    }else if([code isEqualToString: @"404"]){
//        return @"没有找到接口";
//    }
//    return nil;
}


//使用策略模式代替if-else
- (void)executeDifferentResult:(NSString *)type{
    NSDictionary *info = @{
        @"url" : @"http://www.baidu.com",
    };
    LBTestStrategyObject *object = [[LBTestStrategyObject alloc] init];
    NSDictionary *strategyDic = @{
        @"1000" : [self invocationWithSelector:@selector(saveUserInfo)],
        @"2000" : [self invocationWithSelector:@selector(presentTipAlert)],
        @"3000" : [self invocationWithSelector:@selector(pushWebVC:) arguments:@[]],
        @"4000" : [self invocationWithSelector:@selector(caculateDDD:) target:object arguments:@[info]]
    };
    
    NSInvocation *invocation = strategyDic[type];
    [invocation invoke];
    
    id __weak result = nil;
    NSLog(@"LBLog signture %s",invocation.methodSignature.methodReturnType);
    NSLog(@"LBLog signture %zd",invocation.methodSignature.methodReturnLength);
    
    if (strcmp(invocation.methodSignature.methodReturnType, "v") != 0) {
        [invocation getReturnValue:&result];
//        NSLog(@"LBLog result %@",result);
    }
//    这样是没有问题的
    static NSObject *obj;
    obj = [[NSObject alloc] init];
//    这样会编译错误  static修饰的数据存放在data区   alloc init在堆区   static修饰的常量在初始化的时候不是一个常量  是一个变量
//    static NSObject *obj22 = [[NSObject alloc] init];
//    NSObject *ttt = [[NSObject alloc] init];
//    static NSObject *obj22 = ttt;
    
    
//    if ([type isEqualToString:@"1000"]) {
//        [self saveUserInfo];
//    }else if ([type isEqualToString:@"2000"]){
//        [self presentTipAlert];
//    }else if ([type isEqualToString:@"3000"]){
//        [self pushWebVC:info];
//    }else if ([type isEqualToString:@"4000"]){
//        [self caculateDDD];
//    }
}


- (void)saveUserInfo{
    NSLog(@"LBLog saveuserinfo ========");
}

- (void)presentTipAlert{
    NSLog(@"LBLog presentTipAlert ========");
}

- (void)pushWebVC:(NSDictionary *)info{
    NSLog(@"LBLog pushWebVC ======== %@",info);
}

- (NSString *)caculateDDD:(NSDictionary *)info{
    NSLog(@"LBLog caculateDDD ========");
    return info[@"url"];
}

- (void)dealloc
{
    NSLog(@"LBLog %@ dealloc =================",NSStringFromClass([self class]));
}

@end

