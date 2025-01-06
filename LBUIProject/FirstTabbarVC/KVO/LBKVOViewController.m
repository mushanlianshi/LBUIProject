//
//  LBKVOViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/11/16.
//

#import "LBKVOViewController.h"

@interface LBKVOViewController ()

@end

@implementation LBKVOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    LBKVOObject *obj1 = [[LBKVOObject alloc] init];
    LBKVOObject *obj2 = [[LBKVOObject alloc] init];
    ///ob1 和obj2 对象的内存地址不同，但他们的setAge方法指向的地址是相同的，他们的isa指针指向的都是类，类的方法地址是固定的，所以他们的setAge方法最终都指向了类的方法里，类方法最终都指向了元类的方法列表
    NSLog(@"LBLog kvo before obj1  %p",obj1);
    NSLog(@"LBLog kvo before obj2  %p",obj2);
    NSLog(@"LBLog kvo before method p1 %p and p2 %p",[obj1 methodForSelector:@selector(setAge:)],[obj2 methodForSelector:@selector(setAge:)]);
    
    
    ///而添加obserer之后  两个对象的setAge方法的地址就不同了，说明发生了变化，添加observer的setAge方法的地址指向了新的内存地址，
    [obj1 addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    obj1.age = @"123";
    
    NSLog(@"LBLog kvo after method p1 %p and p2 %p",[obj1 methodForSelector:@selector(setAge:)],[obj2 methodForSelector:@selector(setAge:)]);
    NSLog(@"LBLog kvo after obj1  %p",obj1);
    NSLog(@"LBLog kvo after obj2  %p",obj2);
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"LBLog kvo observer %@",change);
}

@end



@implementation LBKVOObject

- (void)setAge:(NSString *)age{
    _age = age;
    NSLog(@"LBLog kvo setAge =====");
}

- (void)willChangeValueForKey:(NSString *)key{
    NSLog(@"LBLog kvo willChangeValueForKey begin");
    [super willChangeValueForKey:key];
    NSLog(@"LBLog kvo willChangeValueForKey end");
}

- (void)didChangeValueForKey:(NSString *)key{
    NSLog(@"LBLog kvo didChangeValueForKey begin");
//    [super didChangeValueForKey:key];
    NSLog(@"LBLog kvo didChangeValueForKey end");
}

@end
