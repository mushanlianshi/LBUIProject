//
//  BLTHorizontalRankView.m
//  BLTBasicUIKit
//
//  Created by liu bin on 2020/7/6.
//

#import "BLTHorizontalRankView.h"
#import "BLTUIKitFrameHeader.h"
#import "Masonry.h"

@interface BLTHorizontalRankView ()

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSMutableArray <UIView *>*rankSubViewArray;
@property (nonatomic, strong) UIView *contentBackgroundView;
@property (nonatomic, copy) dispatch_block_t clickBlock;
@end

static BLTHorizontalRankView *rankViewAppearance ;
@implementation BLTHorizontalRankView

+ (void)load{
    [BLTHorizontalRankView appearance];
}


+ (instancetype)rankViewWithSubViews:(NSArray<UIView *> *)subViews spacing:(CGFloat)spacing{
    return [self rankViewWithSubViews:subViews spacing:spacing contentInsets:rankViewAppearance.contentInsets];
}

+ (instancetype)rankViewWithSubViews:(NSArray <UIView *>*)subViews spacing:(CGFloat)spacing contentInsets:(UIEdgeInsets)contentInsets{
    BLTHorizontalRankView *rankView = [[self alloc] init];
    rankView.rankSubViews = subViews;
    rankView.spacing = spacing;
    return rankView;
}

+ (instancetype)rankButtonWithTitle:(NSString *)title clickBlock:(dispatch_block_t)clickBlock{
    return [BLTHorizontalRankView rankButtonWithTitle:title clickBlock:clickBlock buttonConfig:nil];
}

+ (instancetype)rankButtonWithTitle:(NSString *)title clickBlock:(dispatch_block_t)clickBlock buttonConfig:(void (^)(UIButton *))buttonConfig{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:rankViewAppearance.rankButtonTitleColor forState:UIControlStateNormal];
    button.backgroundColor = rankViewAppearance.rankButtonBackgroundColor;
    button.titleLabel.font = rankViewAppearance.rankButtonTitleFont;
    button.layer.cornerRadius = rankViewAppearance.rankButtonLayerCornerRaduis;
    BLTHorizontalRankView *rankView = [BLTHorizontalRankView rankViewWithSubViews:@[button] spacing:rankViewAppearance.spacing];
    rankView.clickBlock = clickBlock;
    [button addTarget:rankView action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (buttonConfig) {
        buttonConfig(button);
    }
    return rankView;
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.contentBackgroundView];
        [self addSubview:self.stackView];
        self.contentInsets = rankViewAppearance.contentInsets;
        [self.contentBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.stackView);
        }];
    }
    return self;
}

- (void)buttonClicked:(UIButton *)button{
    if (self.clickBlock) {
        self.clickBlock();
    }
}

#pragma mark - setter method
- (void)setSpacing:(CGFloat)spacing{
    _spacing = spacing;
    self.stackView.spacing = spacing;
}

- (void)setRankSubViews:(NSArray *)rankSubViews{
    _rankSubViews = rankSubViews;
    [self p_removeAllRankSubviews];
    [self.rankSubViewArray addObjectsFromArray:rankSubViews];
    [self p_addAllRankSubviews];
}

- (void)setSubViewWidthScale:(NSArray<NSNumber *> *)subViewWidthScale{
    if (_subViewWidthScale == subViewWidthScale || self.stackView.arrangedSubviews.count == 0 || subViewWidthScale.count != self.stackView.arrangedSubviews.count) {
        return;
    }
    _subViewWidthScale = subViewWidthScale;
    self.stackView.distribution = UIStackViewDistributionFillProportionally;
    UIView *firstView = self.stackView.arrangedSubviews.firstObject;
    [subViewWidthScale enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 0) {
            UIView *otherView = self.stackView.arrangedSubviews[idx];
            [otherView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(firstView).multipliedBy([obj floatValue]);
            }];
        }
    }];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets{
    _contentInsets = contentInsets;
    [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(contentInsets);
    }];
}


#pragma mark - private method
- (void)p_removeAllRankSubviews{
    [self.rankSubViewArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.stackView removeArrangedSubview:obj];
    }];
}

- (void)p_addAllRankSubviews{
    [self.rankSubViewArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.stackView addArrangedSubview:obj];
    }];
}

- (void)willMoveToWindow:(UIWindow *)newWindow{
    [super willMoveToWindow:newWindow];
    if (self.stackViewConfigUI) {
        self.stackViewConfigUI(self.stackView, self.contentBackgroundView);
    }
}



#pragma mark - appearance delegate
+ (instancetype)appearance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rankViewAppearance = [[BLTHorizontalRankView alloc] init];
        rankViewAppearance.rankButtonBackgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.9];
        rankViewAppearance.rankButtonTitleFont = [UIFont systemFontOfSize:16];
        rankViewAppearance.rankButtonTitleColor = [UIColor whiteColor];
        rankViewAppearance.rankButtonLayerCornerRaduis = 5;
        rankViewAppearance.contentInsets = UIEdgeInsetsMake(10, 15, 10, 15);
        rankViewAppearance.spacing = 10;
    });
    return rankViewAppearance;
}



- (UIStackView *)stackView{
    if (!_stackView) {
        _stackView = [[UIStackView alloc] init];
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.distribution = UIStackViewDistributionFillEqually;
        _stackView.alignment = UIStackViewAlignmentFill;
    }
    return _stackView;
}

- (UIView *)contentBackgroundView{
    if (!_contentBackgroundView) {
        _contentBackgroundView = [[UIView alloc] init];
        _contentBackgroundView.backgroundColor = [UIColor whiteColor];
    }
    return _contentBackgroundView;
}

- (NSMutableArray *)rankSubViewArray{
    if (!_rankSubViewArray ) {
        _rankSubViewArray = @[].mutableCopy;
    }
    return _rankSubViewArray;
}

@end
