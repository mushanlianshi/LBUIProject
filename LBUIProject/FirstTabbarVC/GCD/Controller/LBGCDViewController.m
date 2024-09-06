//
//  LBGCDViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/7/19.
//

#import "LBGCDViewController.h"
#import "Masonry.h"
#import <BLTUIKitProject/BLTUI.h>
#import <ReplayKit/ReplayKit.h>
#import "LBChainElement.h"

@interface LBGCDViewController (){
    dispatch_queue_t _concurrentQueue;
    NSMutableDictionary *_dic;
}

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) dispatch_queue_t asyncQueue;

@property (nonatomic, strong) dispatch_group_t group;

@property (nonatomic, strong) LBChainElement *firstChainElement;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, strong) NSObject *testObj;

@end

@implementation LBGCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _asyncQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT);
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
//    [self testConvertSyncToAsync];
//    [self testOperationQueue];
//    NSLog(@"LBLog viewDidLoad  ========");
//    _group = dispatch_group_create();
//    dispatch_group_enter(_group);
//    BLT_WS(weakSelf);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"LBLog LBGCDViewController dispatch_group_leave ========");
//        dispatch_group_leave(weakSelf.group);
//    });
//    dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
//        NSLog(@"LBLog LBGCDViewController dispatch_group_notify ========");
//    });
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"LBLog 111111  1===");
//        dispatch_group_enter(weakSelf.group);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            dispatch_group_leave(weakSelf.group);
//        });
//    });
    
//    [self testConvertAsyncToSync];
    
//    [self testPromiseChain];
//    _concurrentQueue = dispatch_queue_create("con queue", DISPATCH_QUEUE_CONCURRENT);
//    _dic = [NSMutableDictionary new];
//    [self testMutiReadSingleWrite];
//    [self testWeboInterviewQuestion];
//    局部变量不会触发release
    [self testMutiThreadReleaseVariable];
    [self testMutiThreadReleaseProperty];
}

//- (void)setTestObj:(NSObject *)testObj{
//
//}
//
//- (NSObject *)testObj{
//    if(_testObj == nil){
//        _testObj = [[NSObject alloc] init];
//    }
//    return _testObj;
//}


- (void)testMutiThreadReleaseProperty{
    for(int i = 0; i < 1000; i++){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.testObj = [[NSObject alloc] init];
        });
    }
    
//    for(int i = 0; i < 1000; i++){
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSLog(@"LBLog obj is %@",self.testObj);
//        });
//    }
    
}

- (void)testMutiThreadReleaseVariable{
    for(int i = 0; i < 100; i++){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //    局部变量不会触发release   所以不会crash
            NSObject *obj = [[NSObject alloc] init];
            NSLog(@"LBLog obj is %@",obj);
        });
    }
}


//最终的答案  3在0前面   0在789前面   789属性无法固定   1230 无法固定
- (void)testWeboInterviewQuestion{
    dispatch_queue_t queue = dispatch_queue_create("current", DISPATCH_QUEUE_CONCURRENT);
//    1 2 3的顺序则无法预测  一般情况下简单的任务  会先执行同步  在执行异步的 因为切换异步需要时间   但也可能先执行异步的  这和任务的复杂度有关
    dispatch_async(queue, ^{
        NSLog(@"LBLog 1");
    });
    dispatch_async(queue, ^{
        NSLog(@"LBLog 2");
    });
    
//    同步不会开启新线程  3肯定在0前面
    dispatch_sync(queue, ^{
        NSLog(@"LBLog 3");
    });
    NSLog(@"LBLog 0");
//    7 8 9 肯定在0后面 等前面的同步任务先执行完
    dispatch_async(queue, ^{
        NSLog(@"LBLog 7");
    });
    dispatch_async(queue, ^{
        NSLog(@"LBLog 8");
    });
    dispatch_async(queue, ^{
        NSLog(@"LBLog 9");
    });
}


- (void)testPromiseChain{
    NSLog(@"--------------------------------------------------------------------------------------");
    
    _firstChainElement = [[[[[LBChainElement alloc] initWithIdentifier:@"firstChainElement" executeTask:^(LBChainElement *promise) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"LBLog firstChainElement111111111");
            [promise next];
        });
    }] subscribe:^{
        NSLog(@"LBLog firstChainElement111111111  subscribe");
    }] dispose:^{
        NSLog(@"LBLog firstChainElement111111111  dispose");
    }] catchError:^(NSError *error) {
        NSLog(@"LBLog firstChainElement111111111  error %@", error.localizedDescription);
    }];
    
    LBChainElement *secondChainElement222 = [[self secondTaskChainElement] dispose:^{
        NSLog(@"LBLog firstChainElement222222 dispose");
    }];
    
    LBChainElement *secondChainElement333 = [[[[LBChainElement alloc] initWithIdentifier:@"secondChainElement333" executeTask:^(LBChainElement *promise){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"LBLog firstChainElement3333");
            [promise next];
//            [promise throwError:[NSError errorWithDomain:NSURLErrorDomain code:1001 userInfo:@{@"NSLocalizedDescription": @"throwError  there is an error"}]];
        });
    }] subscribe:^{
        NSLog(@"LBLog firstChainElement3333 subscribe");
    }] catchError:^(NSError *error) {
        NSLog(@"LBLog firstChainElement3333 error %@",error.localizedDescription);
    }];
    
    
    LBChainElement *secondChainElement4444 = [[[[LBChainElement alloc] initWithIdentifier:@"secondChainElement4444" executeTask:^(LBChainElement *promise){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"LBLog firstChainElement4444");
            [promise next];
        });
    }] subscribe:^{
        NSLog(@"LBLog firstChainElement44444 subscribe");
    }] catchError:^(NSError *error) {
        NSLog(@"LBLog firstChainElement44444 error %@",error.localizedDescription);
    }];
    
    _firstChainElement
    .then(secondChainElement222)
    .then(secondChainElement333)
    .then(secondChainElement4444);
    [_firstChainElement start];
    
    NSLog(@"--------------------------------------------------------------------------------------");
}

- (LBChainElement *)secondTaskChainElement{
    return [[LBChainElement alloc] initWithIdentifier:@"secondTask" executeTask:^(LBChainElement *promise) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"LBLog firstChainElement222222");
            [promise next];
        });
    }];;
}

- (void)dealloc
{
    NSLog(@"LBLog %@ dealloc =================",NSStringFromClass([self class]));
}



#pragma mark - NSOperationQueue 任务依赖
- (void)testOperationQueue{
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 5;
    __block NSString *string1 = nil;
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        string1 = [self convertAsyncToSync1];
    }];
    
    __block NSString *string2 = nil;
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        string2 = [self convertAsyncToSync2];
    }];
    
    NSBlockOperation *finalOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"LBLog result  %@ %@",string1, string2);
    }];
    [operation2 addDependency:operation1];
    
    [finalOperation addDependency:operation1];
    [finalOperation addDependency:operation2];
    
    [operationQueue addOperation:operation1];
    [operationQueue addOperation:operation2];
    [operationQueue addOperation:finalOperation];
}

#pragma mark - 异步变成同步处理
- (void)testConvertAsyncToSync{
//    _serialQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
    dispatch_async(_asyncQueue, ^{
        NSString *result1 = [self convertAsyncToSync1];
        NSString *result2 = [self convertAsyncToSync2];
        NSLog(@"LBLog result %@ %@ %@",result1,result2, [NSThread currentThread]);
        NSLog(@"LBLog wait form convert async to sync");
    });
}

- (void)testSemaphore{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_semaphore_t semaphore1 = dispatch_semaphore_create(0);
    dispatch_async(concurrentQueue, ^{
        __block NSString *result = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            result = @"after execure";
            dispatch_semaphore_signal(semaphore1);
//            如果4也需要等这个执行完  需要在发一个信号  让444的任务wait消失
            dispatch_semaphore_signal(semaphore1);
        });
//        让wait后面的代码进行等待信号量来了在执行
        dispatch_semaphore_wait(semaphore1, DISPATCH_TIME_FOREVER);
        NSLog(@"LBLog result %@ %@",result, [NSThread currentThread]);
    });
    
    dispatch_async(concurrentQueue, ^{
        NSLog(@"LBLog result 222222 %@ ", [NSThread currentThread]);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), concurrentQueue, ^{
//        dispatch_semaphore_wait(semaphore1, dispatch_semaphore_wait(semaphore1, DISPATCH_TIME_FOREVER));
        NSLog(@"LBLog result 33333 %@ ", [NSThread currentThread]);
    });
    
//    如果需要别的任务也根据上面的信号量发送了在执行，需要别的任务也wait
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(concurrentQueue, ^{
            dispatch_semaphore_wait(semaphore1, DISPATCH_TIME_FOREVER);
            NSLog(@"LBLog result 44444 %@ ", [NSThread currentThread]);
//            dispatch_semaphore_signal(semaphore1);
        });
    });
    
    return;;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_semaphore_signal(semaphore);
        NSLog(@"LBLog semaphore send  semaphore %@",[NSThread currentThread]);
    });
    __block int tempValue = 0;
    NSLog(@"LBLog semaphore will wait %@",[NSThread currentThread]);
    for (int i = 0; i < 3; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            NSLog(@"LBLog 测试semaphore是否组塞了当前并发队列%d %@", i,[NSThread currentThread]);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                tempValue ++;
                NSLog(@"LBLog 测试semaphore是否组塞了当前并发队列    %d ", i);
                dispatch_semaphore_signal(semaphore);
            });
        });
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"LBLog ================================= %@",[NSThread currentThread]);
        });
    });
}


//使用semaphore控制最大并发线程数   semaphore控制的是线程
- (void)useSemaphoreControlThreadCount{
    __block NSInteger i = 0;
//    控制最大线程数为2
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    while (i < 10) {
        NSLog(@"LBLog i is before %zd , %@",i, [NSThread currentThread]);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            i ++;
            NSLog(@"LBLog i is %zd , %@",i, [NSThread currentThread]);
//            发送一个信号量   会导致打印11 因为打印完10会发送一个singal  让while循环等待的下一个任务wait状态消失(因为while循环执行特别快 wait还没生效就开始执行下一个while了  看打印可以开出来before会有两个0的打印立马出来 )  继续往下执行
            dispatch_semaphore_signal(semaphore);
        });
    }
    NSLog(@"LBLog i === %zd",i);
//    NSLog(@"LBLog -----------------------------------------------------------------------------------");
//    NSLog(@"LBLog -----------------------------------------------------------------------------------");
//    NSLog(@"LBLog -----------------------------------------------------------------------------------");
//
//    dispatch_semaphore_t semaphore1 = dispatch_semaphore_create(1);
//    for(int a = 0; a< 10; a++) {
//        dispatch_semaphore_wait(semaphore1, DISPATCH_TIME_FOREVER);
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSLog(@"LBLog a is %d , %@",a, [NSThread currentThread]);
//            dispatch_semaphore_signal(semaphore1);
//        });
//    }
//    NSLog(@"LBLog a ========= aaaaaa");
}

//多线程执行任务的不确定性
- (void)testMutiThreadExecute{
    __block NSInteger i = 0;
    while (i < 10) {
//        由于多线程执行 所以执行的不一定就是10次  最少执行10次  最多不确定
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            i ++;
            NSLog(@"LBLog i is %zd",i);
        });
    }
//    打印的不一定就是10   可能比10大  当执行到i= 10的时候 正好有个线程也在i++   就会出现i大于10了
    NSLog(@"LBLog i === %zd",i);
}

- (void)injected{
    [self useSemaphoreControlThreadCount];
}


//把异步转场同步来处理
- (NSString *)convertAsyncToSync1{
    __block NSString *result1 = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    dispatch_after(<#dispatch_time_t when#>, <#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), _asyncQueue, ^{
        result1 = @"result1";
        NSLog(@"LBLog  current queue %@ ",[NSThread currentThread]);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LBLog async mainqueue ");
        });
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"LBLog convertAsyncToSync1  ======= %@",[NSThread currentThread]);
    return result1;
}


- (NSString *)convertAsyncToSync2{
    __block NSString *result2 = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), _asyncQueue, ^{
        result2 = @"result2";
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"LBLog convertAsyncToSync2  ======= %@", [NSThread currentThread]);
    return result2;
}


- (void)semaphoreMakeGroup{
    _semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"LBLog task1111");
        dispatch_semaphore_signal(_semaphore);
    });
    
    dispatch_async(queue, ^{
        sleep(1);
        NSLog(@"LBLog task222222");
        dispatch_semaphore_signal(_semaphore);
    });
    
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"LBLog task33333");
    });
}


- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor lightGrayColor];
        _scrollView.contentSize = CGSizeMake(BLT_DEF_SCREEN_WIDTH, BLT_DEF_SCREEN_HEIGHT * 3);
    }
    return _scrollView;
}


- (void)testMutiReadSingleWrite{
    NSLog(@"LBLog name %@",[self lb_safeObjectForKey:@"name"]);
    NSLog(@"LBLog age %@",[self lb_safeObjectForKey:@"age"]);
    for (int i = 0; i < 100; i++) {
        [self lb_safeSetObject:[NSString stringWithFormat:@"liubin %@",@(i)] forKey:@"name"];
        [self lb_safeSetObject:@(i) forKey:@"age"];
    }
    
    for (int i = 0; i < 100; i++) {
        NSLog(@"LBLog name %@",[self lb_safeObjectForKey:@"name"]);
        NSLog(@"LBLog age %@",[self lb_safeObjectForKey:@"age"]);
    }
    
}


- (void)lb_safeSetObject:(id)object forKey:(NSString *)key{
    key = key.copy;
    dispatch_barrier_async(_concurrentQueue, ^{
        [_dic setObject:object forKey:key];
        NSLog(@"LBLog setobject %@",[NSThread currentThread]);
    });
}

- (id)lb_safeObjectForKey:(NSString *)key{
    key = key.copy;
    __block id object = nil;
    dispatch_sync(_concurrentQueue, ^{
        object = [_dic objectForKey:key];
//        NSLog(@"LBLog object forkey %@",[NSThread currentThread]);
    });
    return object;
}


@end
