//
//  LBLoadAndInitializeController.m
//  LBUIProject
//
//  Created by liu bin on 2021/11/16.
//

#import "LBLoadAndInitializeController.h"
@interface LBLoadAndInitializeController ()

@end

@implementation LBLoadAndInitializeController

- (void)viewDidLoad {
    [super viewDidLoad];
    LBLoadAndInitializeSubClassController *vc1 = [[LBLoadAndInitializeSubClassController alloc] init];
    LBLoadAndInitializeSubClassController22 *vc2 = [[LBLoadAndInitializeSubClassController22 alloc] init];
//    UIButton *btn = [[UIButton alloc] init];
//    btn.backgroundColor = [UIColor lightGrayColor];
//    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.view addSubview:btn];
//    btn.frame = CGRectMake(100, 100, 200, 50);
//
//    [btn addTarget:self action:@selector(testMutiTarget) forControlEvents:UIControlEventTouchUpInside];
//    [btn addTarget:vc1 action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
}

- (void)testMutiTarget:(UIButton *)btn{
    NSLog(@"LBLog muti target =====");
//    [NSObject cancelPreviousPerformRequestsWithTarget:<#(nonnull id)#> selector:<#(nonnull SEL)#> object:<#(nullable id)#>];
}

+ (void)load{
    NSLog(@"LBlog load ========");
}

+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"LBlog initialize ========");
    });
}

@end




@implementation LBLoadAndInitializeSubClassController

+ (void)load{
    [super load];
    NSLog(@"LBlog subClass load ========");
}

+ (void)initialize{
    NSLog(@"LBlog subClass initialize ========");
}

- (void)test{
    NSLog(@"LBlog test");
}

@end





@implementation LBLoadAndInitializeSubClassController22

+ (void)load{
    NSLog(@"LBlog subClass22 load ========");
}

//+ (void)initialize{
//    NSLog(@"LBlog subClass22 initialize ========");
//}

- (void)test{
    NSLog(@"LBlog test22");
}

@end


@implementation LBLoadAndInitializeSubClassController (Test1)

+ (void)load{
    NSLog(@"LBlog Test1 subClass load ========");
}

//+ (void)initialize{
//    NSLog(@"LBlog Test1 subClass initialize ========");
//}

@end


@implementation LBLoadAndInitializeSubClassController (Test2)

+ (void)load{
    NSLog(@"LBlog Test2 subClass load ========");
}

//+ (void)initialize{
//    NSLog(@"LBlog Test2 subClass initialize ========");
//}

@end
