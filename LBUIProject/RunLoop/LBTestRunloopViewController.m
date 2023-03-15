//
//  LBTestRunloopViewController.m
//  LBUIProject
//
//  Created by liu bin on 2022/5/27.
//

#import "LBTestRunloopViewController.h"
#import "Masonry.h"
#import "LBCrashManager.h"

@interface LBTestRunloopViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSObject *testFuzhiProperty;

@end

@implementation LBTestRunloopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[LBCrashManager sharedInstance] startCatchCrash];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor blackColor];
    [button setTitle:@"crash" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(crashClick) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 60));
    }];
    
    UIButton *button2 = [[UIButton alloc] init];
    button2.backgroundColor = [UIColor blackColor];
    [button2 setTitle:@"多线程赋值crash" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(testMutiThreadFuzhi) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:button2];
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(button.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 60));
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
}

- (void)crashClick{
    NSArray *array = @[@"123",@"234"];
    NSString *result = array[10];
}

- (void)testMutiThreadFuzhi{
    ///针对多线程对属性赋值的崩溃   我们可以修改nonatomic 到atomic  保证set方法的原子性  不会崩溃
    for (int i = 0; i < 10000; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.testFuzhiProperty = [[NSObject alloc] init];
            NSLog(@"LBlog self.test fuzhi property %@", self.testFuzhiProperty);
        });
    }
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 20000);
        _scrollView.backgroundColor = [UIColor lightTextColor];
    }
    return _scrollView;
}

@end
