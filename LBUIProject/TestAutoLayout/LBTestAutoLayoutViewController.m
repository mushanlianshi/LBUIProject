//
//  LBTestAutoLayoutViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/5/27.
//

#import "LBTestAutoLayoutViewController.h"
#import "LBTestAutoLayoutView.h"
#import "Masonry.h"
#import <BLTBasicUIKit/BLTBasicUIKit.h>
//#import <QMUIKit/QMUIKit.h>
#import "AppDelegate.h"


@interface LBTestAutoLayoutViewController ()

@property (nonatomic, strong) LBTestAutoLayoutView *layoutView;

@property (nonatomic, strong) UIImageView *proView;

@property (nonatomic, strong) UIImageView *renderIV;

@property (nonatomic, strong) BLTCustomImageTitleButton *button1;

//@property (nonatomic, strong) QMUIButton *button2;

@end

@implementation LBTestAutoLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //    [self testAmbiguousLayout];
    [self testAutoLayout];
    [self testAutoLayout2];
}

- (void)testAutoLayout{
    [self.view addSubview:self.layoutView];
    [self.layoutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.view);
        //        make.top.equalTo(self.view.mas_top).multipliedBy(1.5);
    }];
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        self.layoutView.testString = @"123";
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            [self.layoutView.subView mas_updateConstraints:^(MASConstraintMaker *make) {
    //                make.height.mas_equalTo(50);
    //            }];
    //        });
    //    });
    
    //    [self.layoutView layoutIfNeeded];
    NSLog(@"LBLog ----layoutifneed %@ %@",self.layoutView, self.layoutView.subviews);
    [self.layoutView layoutIfNeeded];
    NSLog(@"LBLog ---222222-layoutifneed %@ %@",self.layoutView, self.layoutView.subviews);
    //    self.extendedLayoutIncludesOpaqueBars = YES;
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        self.layoutView.testString = @"哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号";
    //    });
    //    [self.proView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.right.equalTo(self.layoutView.mas_centerX).priorityHigh();
    //        make.left.equalTo(self.layoutView.mas_left).mas_offset(20).priorityMedium();
    //        make.width.mas_lessThanOrEqualTo(100).priorityHigh();
    //        make.height.mas_equalTo(self.proView.mas_width).multipliedBy(32.0/104.0);
    //        make.top.mas_equalTo(self.layoutView.mas_bottom).mas_offset(20);
    //    }];
    //
    //    [self.renderIV mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(self.proView.mas_bottom).mas_offset(30);
    //        make.centerX.equalTo(self.proView);
    //    }];
    //
    //    [self.button1 mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(self.renderIV.mas_bottom).mas_offset(30);
    //        make.left.mas_offset(40);
    //    }];
    
    //    [self.button2 mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(self.button1);
    //        make.left.equalTo(self.button1.mas_right).mas_offset(50);
    //    }];
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [self.button1 setTitle:@"1234大红花会" forState:UIControlStateNormal];
    ////        [self.button2 setTitle:@"1234大欧委会" forState:UIControlStateNormal];
    //    });
}

- (void)testAutoLayout2{
    UILabel *label = [UILabel blt_labelWithTitle:@"label1" font:[UIFont systemFontOfSize:16] textColor:[UIColor blackColor]];
    label.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
    [self.view addSubview:label];
    
    UILabel *label2 = [UILabel blt_labelWithTitle:@"label2 \n label2" font:[UIFont systemFontOfSize:16] textColor:[UIColor blackColor]];
    label2.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
    label2.numberOfLines = 0;
    [self.view addSubview:label2];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_centerY);
        make.left.equalTo(self.view.mas_centerX).offset(-40);
    }];
    
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_centerY);
        make.left.equalTo(label.mas_right).offset(20);
    }];
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.greaterThanOrEqualTo(label.mas_bottom).mas_offset(20);
        make.top.greaterThanOrEqualTo(label2.mas_bottom).mas_offset(20);
        make.width.height.mas_equalTo(60);
    }];
}

- (void)testAmbiguousLayout{
    UIView *ambiguousView1 = [[UIView alloc] init];
    ambiguousView1.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.4];
    ambiguousView1.accessibilityIdentifier = @"ambiguousView1";
    [self.view addSubview:ambiguousView1];
    
    UIView *ambiguousView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    ambiguousView2.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
    ambiguousView2.accessibilityIdentifier = @"ambiguousView2";
    [self.view addSubview:ambiguousView2];
    
    
    [ambiguousView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).mas_offset(-40);
        make.left.mas_offset(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(40);
    }];
//    使用约束的时候 translatesAutoresizingMaskIntoConstraints要设置为false  第三方库都会默认设置的  如果是自己使用autolayout需要自己手动设置  不然会出现约束冲突 代码创建的view translatesAutoresizingMaskIntoConstraints默认为yes  会把frame转换成约束
//    ambiguousView1.translatesAutoresizingMaskIntoConstraints = true;
//    [ambiguousView2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(ambiguousView1);
//        make.width.mas_equalTo(200);
//        make.top.equalTo(ambiguousView1.mas_bottom).mas_offset(30);
//        make.height.mas_equalTo(40);
//    }];
    [self.view layoutIfNeeded];
//    ambiguousView1.hasAmbiguousLayout
    NSLog(@"LBLog ---------------------------------------------");
}

- (void)injected{
    NSLog(@"LBLog ---------------------------------------------");
    self.layoutView.testString = @"哈哈为服务费微服务卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号哈儿of后卫和佛号";
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    NSLog(@"LBLog viewdidlayoutsuviews %@",@(self.layoutView.frame));
}


- (LBTestAutoLayoutView *)layoutView{
    if (!_layoutView) {
        _layoutView = [[LBTestAutoLayoutView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
    }
    return _layoutView;
}


- (UIImageView *)proView{
    if (!_proView) {
        _proView = [[UIImageView alloc] init];
        _proView.image = [UIImage imageNamed:@"limit_discount_tag"];
    }
    return _proView;
}


- (UIImageView *)renderIV{
    if (!_renderIV) {
        _renderIV = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"arrow_up"];
//        改变箭头的颜色
        _renderIV.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _renderIV.tintColor = [UIColor redColor];
    }
    return _renderIV;
}

- (BLTCustomImageTitleButton *)button1{
    if (!_button1) {
        _button1 = [[BLTCustomImageTitleButton alloc] init];
        [_button1 setTitle:@"button1" forState:UIControlStateNormal];
        [_button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _button1.backgroundColor = [UIColor lightGrayColor];
        UIImage *image = [UIImage imageNamed:@"arrow_up"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_button1 setImage:image forState:UIControlStateNormal];
        _button1.tintColor = [UIColor blueColor];
        _button1.imagePosition = BLTCustomButtonImagePositionTop;
        _button1.imageTitleInnerMargin = 5;
    }
    return _button1;
}


//- (QMUIButton *)button2{
//    if (!_button2) {
//        _button2 = [[QMUIButton alloc] init];
//        [_button2 setTitle:@"button2" forState:UIControlStateNormal];
//        [_button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        _button2.backgroundColor = [UIColor lightGrayColor];
//        UIImage *image = [UIImage imageNamed:@"arrow_up"];
//        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        [_button2 setImage:image forState:UIControlStateNormal];
//        _button2.tintColor = [UIColor greenColor];
//        _button2.imagePosition = QMUIButtonImagePositionTop;
//        _button2.spacingBetweenImageAndTitle = 5;
//    }
//    return _button2;
//}

- (void)dealloc
{
    NSLog(@"LBLog %@ dealloc =================",NSStringFromClass([self class]));
}

@end
