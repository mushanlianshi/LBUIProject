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

@end

@implementation LBTestRunloopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LBCrashManager sharedInstance] startCatchCrash];
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
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
}

- (void)crashClick{
    NSArray *array = @[@"123",@"234"];
    NSString *result = array[10];
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
