//
//  LBAnimationViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/8/3.
//

#import "LBAnimationViewController.h"
#import <BLTUIKitProject/BLTUI.h>
#import "Masonry.h"
//#import <QMUIKit/QMUIKit.h>

//动画都是围绕锚点做的
@interface LBAnimationViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIStackView *stackView;

@property (nonatomic, copy) NSArray *actionControllerArray;

@property (nonatomic, strong) CALayer *yinshiAnimationLayer;

@property (nonatomic, strong) UIView *yinshiAnimationView;

@property (nonatomic, strong) UIButton *yinshiChangeBtn;

@end

@implementation LBAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.yinshiChangeBtn];
    [self.view addSubview:self.yinshiAnimationView];
    [self.yinshiAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(40);
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.yinshiChangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.yinshiAnimationView);
        make.top.mas_equalTo(self.yinshiAnimationView.mas_bottom).mas_offset(20);
    }];
    
    [self.view.layer addSublayer:self.yinshiAnimationLayer];
    self.yinshiAnimationLayer.frame = CGRectMake(30, 40, 60, 60);
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.stackView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view);
        make.left.mas_offset(20);
        make.right.mas_offset(-20);
        make.height.mas_equalTo(60);
    }];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.scrollView);
        make.centerY.mas_equalTo(self.scrollView);
        make.right.mas_equalTo(self.scrollView).priorityLow();
    }];
    [self addAnimationActions];
}


- (void)addAnimationActions{
    [self.actionControllerArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = obj;
        UIButton *button = [UIButton blt_buttonWithTitle:dic[@"title"] font:UIFontPFFontSize(14) titleColor:[UIColor blackColor] target:self selector:@selector(actionButtonClicked:)];
        button.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
        button.layer.cornerRadius = 15;
        button.contentEdgeInsets = UIEdgeInsetsMake(7, 15, 7, 15);
        button.tag = idx;
        [self.stackView addArrangedSubview:button];
    }];
}

- (void)actionButtonClicked:(UIButton *)button{
    NSInteger index = button.tag;
    NSDictionary *dic = self.actionControllerArray[index];
    UIViewController *vc = [NSClassFromString(dic[@"vc"]) new];
    [self.navigationController pushViewController:vc animated:YES];
}

//隐式动画：之所以叫隐式是因为我们并没有指定任何动画的类 型。我们仅仅改变了一个属性，然后Core Animation来决定如何并且何时去做动画
//layer的隐式动画默认开启的
//view的隐式动画默认是关闭的
- (void)changeColor{
    //开启一个新事务  以免影响别的
//    [CATransaction begin];
//    [CATransaction setAnimationDuration:0.25];
//    self.yinshiAnimationLayer.backgroundColor = [UIColor qmui_randomColor].CGColor;
//    self.yinshiAnimationLayer.frame = CGRectMake(260, 40, 60, 60);
//    [CATransaction commit];
//    [CATransaction setCompletionBlock:^{
//        NSLog(@"LBLog 隐式动画结束");
//        self.yinshiAnimationLayer.affineTransform = CGAffineTransformRotate(self.yinshiAnimationLayer.affineTransform, M_PI_4);
//    }];
    
    //这个时候背景色的action是没CAAction对象返回的  所以不会有动画
    NSLog(@"LBLog view的layer actionlayer是否存在111 %@",[self.yinshiAnimationView actionForLayer:self.yinshiAnimationView.layer forKey:@"backgroundColor"]);
    //对view动画的  开启view的隐式动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    
    //可以关闭所有动画
//    [CATransaction setDisableActions:YES];
    
    
//    self.yinshiAnimationView.backgroundColor = [UIColor qmui_randomColor];
    //当加入到动画中后  就有CAAction对象了  开启了隐式动画
    NSLog(@"LBLog view的layer actionlayer是否存在222 %@",[self.yinshiAnimationView actionForLayer:self.yinshiAnimationView.layer forKey:@"backgroundColor"]);
//    self.yinshiAnimationView.frame = CGRectMake(360, 40, 60, 60);
    [UIView commitAnimations];
}

- (UIButton *)yinshiChangeBtn{
    if (!_yinshiChangeBtn) {
        _yinshiChangeBtn = [UIButton blt_buttonWithTitle:@"改变颜色" font:UIFontPFFontSize(14) titleColor:[UIColor blackColor] target:self selector:@selector(changeColor)];
    }
    return _yinshiChangeBtn;
}

- (CALayer *)yinshiAnimationLayer{
    if (!_yinshiAnimationLayer) {
        _yinshiAnimationLayer = [[CALayer alloc] init];
        _yinshiAnimationLayer.backgroundColor = [UIColor blueColor].CGColor;
    }
    return _yinshiAnimationLayer;
}

- (UIView *)yinshiAnimationView{
    if (!_yinshiAnimationView) {
        _yinshiAnimationView = [[UIView alloc] init];
        _yinshiAnimationView.backgroundColor = [UIColor blueColor];
    }
    return _yinshiAnimationView;
}


- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIStackView *)stackView{
    if (!_stackView) {
        _stackView = [[UIStackView alloc] init];
        _stackView.spacing = 15;
        _stackView.alignment = UIStackViewAlignmentCenter;
    }
    return _stackView;
}


- (NSArray *)actionControllerArray{
    if (!_actionControllerArray) {
        _actionControllerArray = @[
            @{@"title":@"贝瑟尔曲线动画", @"vc" : @"LBBezierpathViewController"},
            @{@"title":@"过渡动画", @"vc" : @"LBTransitionAnimationController"},
            @{@"title":@"关门动画", @"vc" : @"LBCloseDoorAnimationViewController"},
        ];
    }
    return _actionControllerArray;
}

@end
