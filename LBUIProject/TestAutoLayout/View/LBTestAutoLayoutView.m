//
//  LBTestAutoLayoutView.m
//  LBUIProject
//
//  Created by liu bin on 2021/5/27.
//

#import "LBTestAutoLayoutView.h"
#import "Masonry.h"
#import <BLTBasicUIKit/BLTBasicUIKit.h>
#import "LBUIProject-Swift.h"

@interface LBTestAutoLayoutView ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIControl *control;

@property (nonatomic, strong) UIView *stackView;

@property (nonatomic, strong) UIButton *stackBtn;

@property (nonatomic, strong) UIButton *actionBtn;



@end

@implementation LBTestAutoLayoutView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLab];
        [self addSubview:self.control];
        [self.control addSubview:self.stackBtn];
        [self addSubview:self.actionBtn];
        [self addSubview:self.subView];
        [self setConstraints];
    }
    return self;
}

- (void)setConstraints{
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_offset(UIEdgeInsetsMake(20, 15, 0, 15));
    }];
    
    [self.control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.titleLab.mas_bottom);
    }];
    
    
    [self.stackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.control);
    }];
    
    [self.actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(60);
        make.top.equalTo(self.control.mas_bottom);
    }];
    
    [self.subView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.actionBtn.mas_bottom);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(80);
    }];
    
//    [self.titleLab layoutIfNeeded];
//    [self layoutIfNeeded];
    NSLog(@"LBLog layoutifneeded %@ %@",@(self.frame),@(self.titleLab.frame));
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.actionBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.equalTo(self);
//            make.height.mas_equalTo(80);
//            make.top.equalTo(self.control.mas_bottom);
//        }];
//        [self.subView refreshTitle:@"好恶化和我和\n红色耦合和我为服务费威锋网访问"];
//    });
}


- (void)setTestString:(NSString *)testString{
    self.titleLab.text = testString;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    NSLog(@"LBLog layoutSubviews %@ %@", NSStringFromClass([self class]),@(self.frame));
//    self.actionBtn.frame = CGRectMake(self.actionBtn.frame.origin.x, self.actionBtn.frame.origin.y, 100, 40);
}

- (void)controlClicked{
    NSLog(@"LBLog control clicked ========");
}

- (void)stackButtonClicked{
    NSLog(@"LBLog stackButtonClicked ======= 22222");
}


- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.numberOfLines = 0;
        _titleLab.text = @"我发和我方宏伟我和佛hi我佛我和我佛我和万佛湖枉费我佛hi我和佛为划分为我的号发我份宏伟欧文哈佛";
        _titleLab.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
    }
    return _titleLab;
}

- (UIControl *)control{
    if (!_control) {
        _control = [[UIControl alloc] init];
        _control.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5];
        [_control addTarget:self action:@selector(controlClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _control;
}

- (UIView *)stackView{
    if (!_stackView) {
        _stackView = [[UIView alloc] init];
//        _stackView.axis = UILayoutConstraintAxisVertical;
//        _stackView.alignment = UIStackViewAlignmentCenter;
    }
    return _stackView;
}

- (UIButton *)stackBtn{
    if (!_stackBtn) {
        _stackBtn = [[UIButton alloc] init];
        [_stackBtn setTitle:@"stack button" forState:UIControlStateNormal];
        [_stackBtn addTarget:self action:@selector(stackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _stackBtn.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.4];
    }
    return _stackBtn;
}

- (UIButton *)actionBtn{
    if (!_actionBtn) {
        _actionBtn = [[UIButton alloc] init];
        [_actionBtn setTitle:@"哈哈" forState:UIControlStateNormal];
        _actionBtn.backgroundColor = [UIColor lightGrayColor];
    }
    return _actionBtn;
}

- (LBTestAutoLayoutSubView *)subView{
    if (!_subView) {
        _subView = [[LBTestAutoLayoutSubView alloc] init];
    }
    
    return _subView;
}

@end





@interface LBTestAutoLayoutSubView()

@property (nonatomic, strong) LBTestAutoLayoutGrandientButton *subButton;

@end

@implementation LBTestAutoLayoutSubView

- (void)refreshTitle:(NSString *)title{
    [self.subButton setTitle:title forState:UIControlStateNormal];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.subButton];
        [self.subButton blt_addGrandientLayerStartColor:[[UIColor greenColor] colorWithAlphaComponent:0.4] endColor:[[UIColor redColor] colorWithAlphaComponent:0.5] direction:BLTGrandientLayerDirectionLeftToRight needAfterLayout:true];
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
//    self.blt_height = self.subButton.blt_height;
    NSLog(@"LBLog layout subviews %@ %@", NSStringFromClass([self class]), @(self.frame));
//    self.frame.size.height = self.subButton.frame.size.height;
//    NSLog(@"LBLog layout subButton %@", @(self.subButton.frame));
//    self.subButton.layer.cornerRadius = self.subButton.bounds.size.height / 2;
//    [self.subButton blt_addGrandientLayerStartColor:[[UIColor greenColor] colorWithAlphaComponent:0.4] endColor:[[UIColor redColor] colorWithAlphaComponent:0.5] direction:BLTGrandientLayerDirectionLeftToRight needAfterLayout:true];
}

- (LBTestAutoLayoutGrandientButton *)subButton{
    if (!_subButton) {
        _subButton = [[LBTestAutoLayoutGrandientButton alloc] init];
        _subButton.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
        [_subButton setTitle:@"test auto layout" forState:UIControlStateNormal];
        [_subButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _subButton.clipsToBounds = true;
        _subButton.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
        _subButton.titleLabel.numberOfLines = 0;
    }
    return _subButton;
}

@end



@interface LBTestAutoLayoutGrandientButton()

@property (nonatomic, strong) UIView *yellowView;

@end



@implementation LBTestAutoLayoutGrandientButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.yellowView];
    }
    return self;
}



- (void)layoutSubviews{
    [super layoutSubviews];
    NSLog(@"LBLog layout LBTestAutoLayoutGrandientButton %@", @(self.frame));
    self.yellowView.frame = CGRectMake(0, 0, 150, 80);
    self.frame = CGRectMake(0, 0, 150, 80);
}

- (void)willMoveToWindow:(UIWindow *)newWindow{
    [super willMoveToWindow:newWindow];
    NSLog(@"LBLog willMoveToWindow %@",newWindow);
}

- (UIView *)yellowView{
    if (!_yellowView) {
        _yellowView = [[UIView alloc] init];
        _yellowView.backgroundColor = [UIColor systemPinkColor];
    }
    return _yellowView;
}

@end
