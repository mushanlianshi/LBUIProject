//
//  LBBlockViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/8/7.
//

#import "LBBlockViewController.h"
#import <BLTUIKitProject/BLTUI.h>

@interface LBBlockViewController ()

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) void(^testBlock)(void);

@property (nonatomic, copy) void(^testParamsBlock)(LBBlockViewController *vc);

@end

@implementation LBBlockViewController

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"LBlog viewwillappear before");
    [super viewWillAppear:animated];
    NSLog(@"LBlog viewwillappear after");
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _name = @"liubin";
    
//    //1.第一种解决循环引用的 weakSelf 传一个弱引用进去
//    __weak __typeof(&*self)weakSelf = self;
//    self.testBlock = ^(void) {
//        //解决还没执行异步任务返回就被释放的   弱引用和强引用都有一个散列表维护着    当执行完后进行相应的释放操作
//        __strong __typeof(weakSelf)strongSelf = weakSelf;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSLog(@"LBLog testBlock %@",strongSelf.name);
//        });
//    };
//    self.testBlock();
    
    //2.第二种解决循环引用的 传一个临时变量进去   中间者设计模式
    __weak LBBlockViewController *weakSelf = self;
     void (^tmpVarBlock)() = ^() {
        //解决还没执行异步任务返回就被释放的   弱引用和强引用都有一个散列表维护着    当执行完后进行相应的释放操作
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"LBLog testBlock %@",strongSelf.name);
        });
    };
    tmpVarBlock();
    
    //3.第三种解决循环引用的 当成block的参数传进去  block就是一个匿名函数   函数的参数会被压栈出栈的  block的参数是不会被捕获的，   中间者设计模式
    self.testParamsBlock = ^(LBBlockViewController *vc) {
        //解决还没执行异步任务返回就被释放的   弱引用和强引用都有一个散列表维护着    当执行完后进行相应的释放操作
//        __strong __typeof(weakSelf)strongSelf = weakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"LBLog testBlock %@",vc.name);
        });
    };
    self.testParamsBlock(self);
    [self testBlockType];
}


- (void)testBlockType{
    __block NSInteger tmpValue = 100;
    void(^block1)(void)= ^{
        NSLog(@"LBLog block1 tmpValue %@",@(tmpValue));
    };
    
//    全局block
    void(^block2)(void) = ^{
        
    };
    
    __weak __typeof(self)weakSelf = self;
    void(^block3)(void) = ^{
        NSLog(@"LBLog block3 view %@",weakSelf.view);
    };
    
    NSLog(@"LBLog block1 %@",block1);
    NSLog(@"LBLog block2 %@",block2);
    NSLog(@"LBLog block3 %@",block3);
    NSLog(@"LBLog block4 %@",[self testStackBlock]);
}

//栈block
- (dispatch_block_t)testStackBlock {
    __block NSInteger i = 0;
    dispatch_block_t block = ^() {
        NSLog(@"%ld", ++i);
    };
    return block;
}


- (void)dealloc
{
    NSLog(@"LBLog %@ dealloc =================",NSStringFromClass([self class]));
}

@end
