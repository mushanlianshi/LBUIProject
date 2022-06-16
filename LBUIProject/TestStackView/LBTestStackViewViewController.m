//
//  LBTestStackViewViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/5/27.
//

#import "LBTestStackViewViewController.h"
#import "Masonry.h"

@interface LBTestStackViewViewController ()

@property (nonatomic, strong) UIButton *control;

@property (nonatomic, strong) UIStackView *stackView;

@property (nonatomic, strong) UIView *testView;

@end

@implementation LBTestStackViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.control];
    [self.control addSubview:self.stackView];
//    [self.control addSubview:self.testView];
    [self setConstraints];
}


- (void)setConstraints{
    [self.control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view);
        make.left.right.equalTo(self.view);
//        make.height.mas_equalTo(50);
    }];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.control);
        make.left.right.mas_equalTo(self.view);
        make.top.bottom.equalTo(self.control);
    }];
//    [self.testView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.control).mas_offset(UIEdgeInsetsMake(10, 100, 10, 100));
//    }];
    
    
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = @"12323";
//    [titleLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.stackView addArrangedSubview:titleLab];
    
    UILabel *titleLab22 = [[UILabel alloc] init];
    titleLab22.text = @"ef华为佛欧文和佛微风为服务费违法wfewfwfesefwf哈哈哈佛欧文和佛微风为服务费违法wfewfwfesefwf佛欧文和佛微风为服务费违法wfewfwfesefwf";
    titleLab22.numberOfLines = 0;
    //处理横向stackview  label多行问题的
    UIView *view = [[UIView alloc] init];
    [view addSubview:titleLab22];
    [titleLab22 setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
//    [titleLab22 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.height.equalTo(view);
//    }];
    titleLab22.translatesAutoresizingMaskIntoConstraints = NO;
    [view addConstraint: [NSLayoutConstraint constraintWithItem:titleLab22 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [view addConstraint: [NSLayoutConstraint constraintWithItem:titleLab22 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [self.stackView addArrangedSubview:view];
    
    
//    [self.stackView addArrangedSubview:titleLab22];
//    [self.stackView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    
//    UILabel *titleLab33 = [[UILabel alloc] init];
//    titleLab33.text = @"12323efef";
////    titleLab33.numberOfLines = 0;
//    [titleLab33 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(30).priorityLow();
//    }];
//    [self.stackView addArrangedSubview:titleLab33];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"LBLog titlelabel %@",titleLab.mas_height);
//    });
}

- (void)controlClicked{
    NSLog(@"LBLog control -----");
}

- (UIButton *)control{
    if (!_control) {
        _control = [[UIButton alloc] init];
        _control.backgroundColor = [UIColor lightGrayColor];
        [_control addTarget:self action:@selector(controlClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _control;
}

- (UIStackView *)stackView{
    if (!_stackView) {
        _stackView = [[UIStackView alloc] init];
        _stackView.spacing = 10;
    }
    return _stackView;
}

- (UIView *)testView{
    if (!_testView) {
        _testView = [[UIView alloc] init];
    }
    return _testView;
}


@end
