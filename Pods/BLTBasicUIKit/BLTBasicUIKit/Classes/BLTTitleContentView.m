//
//  BLTTitleContentView.m
//  Baletu
//
//  Created by liu bin on 2021/2/19.
//  Copyright © 2021 Baletu. All rights reserved.
//

#import "BLTTitleContentView.h"
#import "UILabel+BLTUIKit.h"
#import "UIView+BLTUIKit.h"

@interface BLTTitleContentView ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *contentLab;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIStackView *stackView;

@end

static BLTTitleContentView *appearnceInstance;

@implementation BLTTitleContentView

+ (void)load{
    [BLTTitleContentView appearance];
}

+ (instancetype)appearance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appearnceInstance = [[BLTTitleContentView alloc] init];
        appearnceInstance.titleColor = [UIColor colorWithRed:51/ 255.0 green:51/255.0 blue:51/255.0 alpha:1];
        appearnceInstance.titleFont = [UIFont systemFontOfSize:15];
        
        appearnceInstance.contentColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
        appearnceInstance.contentFont = [UIFont systemFontOfSize:15];
        appearnceInstance.contentInsets = UIEdgeInsetsMake(0, 15, 0, 15);
    });
    return appearnceInstance;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleColor = appearnceInstance.titleColor;
        self.titleFont = appearnceInstance.titleFont;
        self.contentColor = appearnceInstance.contentColor;
        self.contentFont = appearnceInstance.contentFont;
        self.contentInsets = appearnceInstance.contentInsets;
        self.showBottomLine = NO;
        [self addSubview:self.stackView];
        [self.stackView addArrangedSubview:self.titleLab];
        [self.stackView addArrangedSubview:self.contentLab];
        [self.titleLab setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.titleLab setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.contentLab setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentLab setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.stackView.frame = CGRectMake(CGRectGetMinX(self.bounds) + self.contentInsets.left,
    CGRectGetMinY(self.bounds) + self.contentInsets.top,
    CGRectGetWidth(self.bounds) - self.contentInsets.left - self.contentInsets.right,
                                      CGRectGetHeight(self.bounds) - self.contentInsets.top - self.contentInsets.bottom);
    if (_lineView.hidden == NO) {
        self.lineView.frame = CGRectMake(self.lineInsets.left, self.bounds.size.height - 0.5, self.bounds.size.width - self.contentInsets.left - self.contentInsets.right, 0.5);
    }
}

- (void)refreshTitle:(NSString *)title content:(NSString *)content{
    self.titleLab.text = title;
    self.contentLab.text = content;
    if (_lineView) {
        _lineView.frame = CGRectMake(self.lineInsets.left, self.bounds.size.height - self.lineView.bounds.size.height, self.bounds.size.width - self.lineInsets.left - self.lineInsets.right, self.lineView.bounds.size.height);
    }
}


#pragma mark - setter method
- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLab.text = title;
}

- (void)setContent:(NSString *)content{
    _content = content;
    self.contentLab.text = content;
}

- (void)setTitleColor:(UIColor *)titleColor{
    _titleColor = titleColor;
    self.titleLab.textColor = titleColor;
}

- (void)setTitleFont:(UIFont *)titleFont{
    _titleFont = titleFont;
    self.titleLab.font = titleFont;
}

- (void)setContentFont:(UIFont *)contentFont{
    _contentFont = contentFont;
    self.contentLab.font = contentFont;
}

- (void)setContentColor:(UIColor *)contentColor{
    _contentColor = contentColor;
    self.contentLab.textColor = contentColor;
}


- (void)setCustomTitleView:(UIView *)customTitleView{
    if (_customTitleView == customTitleView || customTitleView == nil) {
        return;
    }
    if (_titleLab && [self.stackView.arrangedSubviews containsObject:_titleLab]) {
        [self.stackView removeArrangedSubview:_titleLab];
        [_titleLab removeFromSuperview];
        _titleLab = nil;
    }
    if (_customTitleView && [self.stackView.arrangedSubviews containsObject:_customTitleView]) {
        [self.stackView removeArrangedSubview:_customTitleView];
        [_customTitleView removeFromSuperview];
        _customTitleView = nil;
    }
    _customTitleView = customTitleView;
    [self.stackView addArrangedSubview:self.customTitleView];
}

- (void)setCustomContentView:(UIView *)customContentView{
    if (_customContentView == customContentView || customContentView == nil) {
        return;
    }
    if (_contentLab && [self.stackView.arrangedSubviews containsObject:_contentLab]) {
        [self.stackView removeArrangedSubview:_contentLab];
        [_contentLab removeFromSuperview];
        _contentLab = nil;
    }
    if (_customContentView && [self.stackView.arrangedSubviews containsObject:_customTitleView]) {
        [self.stackView removeArrangedSubview:_customContentView];
        [_customContentView removeFromSuperview];
        _customContentView = nil;
    }
    _customContentView = customContentView;
    [self.stackView addArrangedSubview:self.customContentView];
}

- (void)setShowBottomLine:(BOOL)showBottomLine{
    _showBottomLine = showBottomLine;
    if (showBottomLine) {
        [self addSubview:self.lineView];
    }else{
        [_lineView removeFromSuperview];
        _lineView = nil;
    }
}

- (void)setDistribution:(UIStackViewDistribution)distribution{
    _distribution = distribution;
    self.stackView.distribution = distribution;
}


- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview && self.customTitleContentViewUIConfig) {
        self.customTitleContentViewUIConfig(_stackView ,_titleLab, _contentLab);
    }
}

- (UIStackView *)stackView{
    if (!_stackView) {
        _stackView = [[UIStackView alloc] init];
        _stackView.distribution = UIStackViewDistributionEqualSpacing;
    }
    return _stackView;
}

- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [UILabel blt_labelWithFont:self.titleFont textColor:self.titleColor];
    }
    return _titleLab;
}

- (UILabel *)contentLab{
    if (!_contentLab) {
        _contentLab = [UILabel blt_labelWithFont:self.contentFont textColor:self.contentColor];
        _contentLab.textAlignment = NSTextAlignmentRight;
    }
    return _contentLab;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.5)];
        _lineView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    }
    return _lineView;
}


@end
