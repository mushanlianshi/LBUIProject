//
//  LBTestAutoLayoutView.m
//  LBUIProject
//
//  Created by liu bin on 2021/5/27.
//

#import "LBTestAutoLayoutView.h"
#import "Masonry.h"
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
        make.bottom.equalTo(self);
    }];
    [self.titleLab layoutIfNeeded];
    [self layoutIfNeeded];
    NSLog(@"LBLog layoutifneeded %@ %@",@(self.frame),@(self.titleLab.frame));
}


- (void)setTestString:(NSString *)testString{
    self.titleLab.text = testString;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    NSLog(@"LBLog layoutSubviews %@",@(self.frame));
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


@end
