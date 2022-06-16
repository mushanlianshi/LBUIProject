//
//  LBTestLLDBViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/7/7.
//

#import "LBTestLLDBViewController.h"
#import "Masonry.h"
//1.修改UI的背景色
//expression e self.lldbView.backgroundColor = [UIColor whiteColor];
//2.修改完后界面不会变  需要刷新
// expression [CATransaction flush]
@interface LBTestLLDBViewController ()

@property (nonatomic, strong) UIView *lldbView;

@property (nonatomic, strong) NSString *testString;

@property (nonatomic, weak) NSString *weakString;

@end

@implementation LBTestLLDBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.lldbView];
    [self.lldbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    
    _testString = @"123h好饿哈佛和文浩我饿后卫和欧华为耦合欧文哈佛我哈佛我黑哦好我耳环我饿哈佛维护费文化佛合欧文哈佛我哈佛我黑哦好我耳环我饿哈佛维护费文化合欧文哈佛我哈佛我黑哦好我耳环我饿哈佛维护费文化合欧文哈佛我哈佛我黑哦好我耳环我饿哈佛维护费文化合欧文哈佛我哈佛我黑哦好我耳环我饿哈佛维护费文化合欧文哈佛我哈佛我黑哦好我耳环我饿哈佛维护费文化合欧文哈佛我哈佛我黑哦好我耳环我饿哈佛维护费文化";
    _weakString = _testString;
    _testString = nil;
    NSLog(@"LLBog weakString --------- %@ %p %p",_weakString, _testString, _weakString);
}

- (void)injected{
    self.lldbView.alpha = 0;
    NSLog(@"LBLog lldbView alpha %f",self.lldbView.alpha);
}

- (UIView *)lldbView{
    if (!_lldbView) {
        _lldbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _lldbView.backgroundColor = [UIColor blueColor];
    }
    return _lldbView;
}

@end
