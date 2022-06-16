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
    NSLog(@"LBLog kvo before obj1  %p",obj1);
    NSLog(@"LBLog kvo before obj2  %p",obj2);
    NSLog(@"LBLog kvo before method p1 %p and p2 %p",[obj1 methodForSelector:@selector(setAge:)],[obj2 methodForSelector:@selector(setAge:)]);
    
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
    [super didChangeValueForKey:key];
    NSLog(@"LBLog kvo didChangeValueForKey end");
}

@end
