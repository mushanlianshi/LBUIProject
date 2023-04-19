//
//  BLTNormalTableViewCell.m
//  BLTUIKitProject_Example
//
//  Created by Baletoo on 2020/10/15.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import "BLTNormalTableViewCell.h"
#import <Masonry/Masonry.h>

static NSString * const kBLTRightArrowImageName = @"blt_right_arrow";

@interface BLTNormalTableViewCell ()

@property (nonatomic, strong, readwrite) UILabel *titleLabel;

@property (nonatomic, strong, readwrite) UILabel *detailLabel;

@property (nonatomic, strong, readwrite) UILabel *subTitleLabel;

@property (nonatomic, strong, readwrite) UIImageView *mainImageView;

@property (nonatomic, strong) UIView *separatorLine;

@property (nonatomic, strong) UIStackView *horizontalStackView;

@property (nonatomic, strong) UIStackView *verticalStackView;

@property (nonatomic, strong) UIStackView *subTitleStackView;

@end

@implementation BLTNormalTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, 15.0f, 0, 0);
        _contentInset = UIEdgeInsetsMake(15.0f, 15.0f, 15.0f, 15.0f);
        _customSeparatorInset = UIEdgeInsetsMake(0, 15.0f, 0, 0);
        _customSeparatorColor = [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1];
        _horizontalSpacing = 10.0f;
        _verticalSpacing = 5.0f;
        _cellType = BLTTableViewCellTypeDefault;
        [self.detailLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
        [self.detailLabel addObserver:self forKeyPath:@"attributedText" options:NSKeyValueObservingOptionNew context:nil];
        [self.subTitleLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
        [self.subTitleLabel addObserver:self forKeyPath:@"attributedText" options:NSKeyValueObservingOptionNew context:nil];
        [self initSubViews];
    }
    return self;
}

- (void)dealloc
{
    [self.detailLabel removeObserver:self forKeyPath:@"text"];
    [self.detailLabel removeObserver:self forKeyPath:@"attributedText"];
    [self.subTitleLabel removeObserver:self forKeyPath:@"text"];
    [self.subTitleLabel removeObserver:self forKeyPath:@"attributedText"];
}

- (void)initSubViews
{
    [self.contentView addSubview:self.horizontalStackView];
    [self.contentView addSubview:self.separatorLine];
    [self.horizontalStackView addArrangedSubview:self.verticalStackView];
    [self.verticalStackView addArrangedSubview:self.titleLabel];
    [self.subTitleStackView addArrangedSubview:self.subTitleLabel];
    
    [self.horizontalStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentInset);
    }];
    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(self.customSeparatorInset.left);
        make.right.offset(-self.customSeparatorInset.right);
        make.bottom.offset(-self.customSeparatorInset.bottom);
        make.height.mas_equalTo(0.5f);
    }];
    [self subTitleDefaultStyle];
    
    [self.titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.subTitleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.subTitleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)subTitleDefaultStyle
{
    switch (_cellType) {
        case BLTTableViewCellTypeSubTitleCenter:
        {
            self.subTitleStackView.alignment = UIStackViewAlignmentCenter;
            _subTitleLabel.textColor = [UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1];
            _subTitleLabel.font = [UIFont systemFontOfSize:16.0f];
        }
            break;
            
        default:
        {
            self.subTitleStackView.alignment = UIStackViewAlignmentTop;
            _subTitleLabel.textColor = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1];
            _subTitleLabel.font = [UIFont systemFontOfSize:12.0f];
        }
            break;
    }
}

- (void)prepareLayout
{
    
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.detailLabel && ([keyPath isEqualToString:@"text"] || [keyPath isEqualToString:@"attributedText"])) {
        NSString *newText = change[NSKeyValueChangeNewKey];
        if (([newText isKindOfClass:[NSString class]] || [newText isKindOfClass:[NSAttributedString class]]) && newText.length > 0) {
            if (![self.verticalStackView.arrangedSubviews containsObject:self.detailLabel]) {
                [self.verticalStackView addArrangedSubview:self.detailLabel];
            }
        }
        else {
            [self.verticalStackView removeArrangedSubview:self.detailLabel];
            [self.detailLabel removeFromSuperview];
        }
    }
    else if (object == self.subTitleLabel && ([keyPath isEqualToString:@"text"] || [keyPath isEqualToString:@"attributedText"])) {
        NSString *newText = change[NSKeyValueChangeNewKey];
        if (([newText isKindOfClass:[NSString class]] || [newText isKindOfClass:[NSAttributedString class]]) && newText.length > 0) {
            if (![self.horizontalStackView.arrangedSubviews containsObject:self.subTitleStackView]) {
                if (self.customAccessoryView) {
                    [self.horizontalStackView insertArrangedSubview:self.subTitleStackView atIndex:self.horizontalStackView.arrangedSubviews.count - 1];
                }
                else {
                    [self.horizontalStackView addArrangedSubview:self.subTitleStackView];
                }
                [self.subTitleStackView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.bottom.offset(0);
                }];
            }
        }
        else {
            [self.horizontalStackView removeArrangedSubview:self.subTitleStackView];
            [self.subTitleStackView removeFromSuperview];
        }
    }
}

#pragma mark - setter
- (void)setCustomAccessoryView:(UIView *)customAccessoryView
{
    [self.horizontalStackView removeArrangedSubview:_customAccessoryView];
    [_customAccessoryView removeFromSuperview];
    _customAccessoryView = customAccessoryView;
    if (_customAccessoryView) {
        [self.horizontalStackView addArrangedSubview:_customAccessoryView];
        if (![_customAccessoryView isKindOfClass:[UITextField class]] && ![_customAccessoryView isKindOfClass:[UITextView class]]) {
            [_customAccessoryView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(_customAccessoryView.intrinsicContentSize);
            }];
        }
        
        [_customAccessoryView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [_customAccessoryView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    }
}

- (void)setCustomAccessoryViewType:(BLTTableViewCellAccessoryViewType)customAccessoryViewType
{
    switch (customAccessoryViewType) {
        case BLTTableViewCellAccessoryViewTypeNone:
            _customAccessoryViewType = customAccessoryViewType;
            self.customAccessoryView = nil;
            break;
            
        case BLTTableViewCellAccessoryViewTypeRightArrow:
            if (_customAccessoryViewType != customAccessoryViewType) {
                _customAccessoryViewType = customAccessoryViewType;
                self.customAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kBLTRightArrowImageName inBundle:kBLTTableViewCellSourceBundle compatibleWithTraitCollection:nil]];
            }
            break;
    }
}

- (void)setAdditionalAccessoryView:(UIView *)additionalAccessoryView
{
    if (_additionalAccessoryView != additionalAccessoryView) {
        [self.horizontalStackView removeArrangedSubview:_additionalAccessoryView];
        [_additionalAccessoryView removeFromSuperview];
        _additionalAccessoryView = additionalAccessoryView;
        if (_additionalAccessoryView) {
            [self.horizontalStackView insertArrangedSubview:_additionalAccessoryView atIndex:[self.horizontalStackView.arrangedSubviews indexOfObject:self.verticalStackView] + 1];
            [_additionalAccessoryView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.offset(_additionalAccessoryViewInset.top);
                make.bottom.offset(_additionalAccessoryViewInset.bottom);
            }];
        }
    }
}

- (void)setAdditionalAccessoryViewInset:(UIEdgeInsets)additionalAccessoryViewInset
{
    _additionalAccessoryViewInset = additionalAccessoryViewInset;
    [self.additionalAccessoryView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.offset(_additionalAccessoryViewInset.top);
        make.bottom.offset(_additionalAccessoryViewInset.bottom);
    }];
}

- (void)setCustomSeparatorColor:(UIColor *)customSeparatorColor
{
    _customSeparatorColor = customSeparatorColor;
    self.separatorLine.backgroundColor = _customSeparatorColor;
}

- (void)setImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    if (CGSizeEqualToSize(_imageSize, CGSizeZero)) {
        [self.horizontalStackView removeArrangedSubview:self.mainImageView];
        [self.mainImageView removeFromSuperview];
    }
    else {
        if (![self.horizontalStackView.arrangedSubviews containsObject:self.mainImageView]) {
            [self.horizontalStackView insertArrangedSubview:self.mainImageView atIndex:0];
            [self.mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(self.imageSize);
            }];
        }
        else {
            [self.mainImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(self.imageSize);
            }];
        }
    }
}

- (void)setCustomSeparatorInset:(UIEdgeInsets)customSeparatorInset
{
    _customSeparatorInset = customSeparatorInset;
    [_separatorLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.offset(self.customSeparatorInset.left);
        make.right.offset(-self.customSeparatorInset.right);
        make.bottom.offset(-self.customSeparatorInset.bottom);
    }];
}

- (void)setCellType:(BLTTableViewCellType)cellType
{
    _cellType = cellType;
    [self subTitleDefaultStyle];
}

- (void)setHorizontalSpacing:(CGFloat)horizontalSpacing
{
    _horizontalSpacing = horizontalSpacing;
    self.horizontalStackView.spacing = _horizontalSpacing;
}

- (void)setVerticalSpacing:(CGFloat)verticalSpacing
{
    _verticalSpacing = verticalSpacing;
    self.verticalStackView.spacing = _verticalSpacing;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    _contentInset = contentInset;
    [self.horizontalStackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(contentInset);
    }];
}

#pragma mark - getter
- (UILabel *)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _subTitleLabel;
}

- (UIImageView *)mainImageView
{
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc] init];
        _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _mainImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _titleLabel.textColor = BLTDefaultNormalTitleColor;
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:12.0f];
        _detailLabel.textColor = BLTDefaultNormalDetailColor;
    }
    return _detailLabel;
}

- (UIView *)separatorLine
{
    if (!_separatorLine) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = self.customSeparatorColor;
        [self.contentView addSubview:_separatorLine];
    }
    return _separatorLine;
}

- (UIStackView *)horizontalStackView
{
    if (!_horizontalStackView) {
        _horizontalStackView = [[UIStackView alloc] init];
        _horizontalStackView.spacing = self.horizontalSpacing;
        _horizontalStackView.alignment = UIStackViewAlignmentCenter;
    }
    return _horizontalStackView;
}

- (UIStackView *)verticalStackView
{
    if (!_verticalStackView) {
        _verticalStackView = [[UIStackView alloc] init];
        _verticalStackView.axis = UILayoutConstraintAxisVertical;
        _verticalStackView.spacing = self.verticalSpacing;
    }
    return _verticalStackView;
}

- (UIStackView *)subTitleStackView
{
    if (!_subTitleStackView) {
        _subTitleStackView = [[UIStackView alloc] init];
        _subTitleStackView.alignment = UIStackViewAlignmentTop;
    }
    return _subTitleStackView;
}

@end
