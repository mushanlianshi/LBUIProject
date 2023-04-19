//
//  BLTTextView.m
//  BLTUIKit
//
//  Created by liu bin on 2020/3/2.
//  Copyright © 2020 liu bin. All rights reserved.
//

#import "BLTTextFieldView.h"
#import "BLTUICommonDefines.h"
#import <BLTBasicUIKit/BLTBasicUIKit.h>


static BLTTextFieldView * textViewInstance;

@implementation BLTTextFieldView (Appearance)

+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initAppreance];
    });
}

+ (instancetype)appearance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initAppreance];
    });
    return textViewInstance;
}

+ (void)initAppreance{
    if (!textViewInstance) {
        textViewInstance = [[BLTTextFieldView alloc] init];
        textViewInstance.unitStringAttributes = @{NSForegroundColorAttributeName:BLT_HEXCOLOR(0x333333),
                                                 NSFontAttributeName:UIFontPFFontSize(14)
                                                 };
        textViewInstance.tipTitleAttributes = @{NSForegroundColorAttributeName:BLT_HEXCOLOR(0x333333),
                                                NSFontAttributeName:UIFontPFFontSize(14)
                                                };
        textViewInstance.placeHolderAttributes = @{NSForegroundColorAttributeName:BLT_HEXCOLOR(0x999999),
                                                   NSFontAttributeName:UIFontPFFontSize(14)
                                                   };;
        textViewInstance.textViewAttributes = @{NSForegroundColorAttributeName:BLT_HEXCOLOR(0x333333),
                                                   NSFontAttributeName:UIFontPFFontSize(14)
                                                   };;
        textViewInstance.contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        textViewInstance.textFieldContentInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        textViewInstance.tipTitleSpacing = 15;
    }
}

@end



@interface BLTTextFieldView ()

@property (nonatomic, strong) UILabel *unitLab;

@property (nonatomic, strong) UILabel *tipTitleLab;

@property (nonatomic, strong) UILabel *placeHolderLab;

@end

@implementation BLTTextFieldView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize{
    self.placeHolderAttributes = textViewInstance.placeHolderAttributes;
    self.tipTitleAttributes = textViewInstance.tipTitleAttributes;
    self.unitStringAttributes = textViewInstance.unitStringAttributes;
    self.textViewAttributes = textViewInstance.textViewAttributes;
    self.contentInsets = textViewInstance.contentInsets;
    self.tipTitleSpacing = textViewInstance.tipTitleSpacing;
    self.textFieldContentInsets = textViewInstance.textFieldContentInsets;
    [self addSubview:self.textField];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat totalContentH = CGRectGetHeight(self.bounds);
    CGFloat totalContentW = CGRectGetWidth(self.bounds);
    
    CGFloat contentX = self.contentInsets.left;
    if (self.tipTitle.length > 0) {
        CGSize fitSize = [self.tipTitleLab sizeThatFits:CGSizeMake(CGFLOAT_MAX, totalContentH)];
        self.tipTitleLab.frame = CGRectMake(self.contentInsets.left, self.contentInsets.top, fitSize.width, totalContentH - UIEdgeInsetsGetVerticalValue(self.contentInsets));
        contentX += fitSize.width + self.tipTitleSpacing;
    }
    
    self.textField.frame = CGRectMake(contentX, self.contentInsets.top, totalContentW - self.contentInsets.right - contentX, totalContentH - UIEdgeInsetsGetVerticalValue(self.contentInsets));
    
    CGFloat textFieldContentH = totalContentH - UIEdgeInsetsGetVerticalValue(self.contentInsets) - UIEdgeInsetsGetVerticalValue(self.textFieldContentInsets);
    if (self.unitString.length > 0) {
        CGSize fitSize = [self.unitLab sizeThatFits:CGSizeMake(CGFLOAT_MAX, textFieldContentH)];
        self.unitLab.frame = CGRectMake(0, 0, fitSize.width, fitSize.height);
    }
    
}

#pragma mark - set method
- (void)setTipTitle:(NSString *)tipTitle{
    _tipTitle = tipTitle;
    if (!self.tipTitleLab) {
        self.tipTitleLab = [[UILabel alloc] init];
        self.tipTitleLab.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.tipTitleLab];
    }
    if (!_tipTitle || _tipTitle.length == 0 ) {
        self.tipTitleLab.hidden = YES;
    }else{
        self.tipTitleLab.hidden = NO;
        [self p_updateTipTitleLabStyle];
    }
    [self setNeedsLayout];
}

- (void)setUnitString:(NSString *)unitString{
    _unitString = unitString;
    if (!self.unitLab) {
        self.unitLab = [[UILabel alloc] init];
        self.unitLab.textAlignment = NSTextAlignmentRight;
        self.textField.rightView = self.unitLab;
        self.textField.rightViewMode = UITextFieldViewModeAlways;
    }
    if (!_unitString || _unitString.length == 0) {
        self.unitLab.hidden = YES;
    }else{
        self.unitLab.hidden = NO;
        [self p_updateUnitLabStyle];
    }
    [self setNeedsLayout];
}

- (void)setPlaceHolder:(NSString *)placeHolder{
    _placeHolder = placeHolder;
    self.textField.placeholder = placeHolder;
    [self p_updatePlaceHolderLabStyle];
}

- (void)setUnitStringAttributes:(NSDictionary<NSString *,id> *)unitStringAttributes{
    _unitStringAttributes = unitStringAttributes;
    [self p_updateUnitLabStyle];
}

- (void)setTipTitleAttributes:(NSDictionary<NSString *,id> *)tipTitleAttributes{
    _tipTitleAttributes = tipTitleAttributes;
    [self p_updateTipTitleLabStyle];
}

- (void)setPlaceHolderAttributes:(NSDictionary<NSString *,id> *)placeHolderAttributes{
    _placeHolderAttributes = placeHolderAttributes;
    [self p_updatePlaceHolderLabStyle];
}

- (void)setTextViewAttributes:(NSDictionary<NSString *,id> *)textViewAttributes{
    _textViewAttributes = textViewAttributes;
    [self p_updateTextViewStyle];
}

- (void)setTipTitleAttributeString:(NSAttributedString *)tipTitleAttributeString{
    _tipTitleAttributeString = tipTitleAttributeString;
    self.tipTitleLab.attributedText = tipTitleAttributeString;
}

- (void)setPlaceHolderAttributeString:(NSAttributedString *)placeHolderAttributeString{
    _placeHolderAttributeString = placeHolderAttributeString;
    self.placeHolderLab.attributedText = placeHolderAttributeString;
}

- (void)setUnitAttributeString:(NSAttributedString *)unitAttributeString{
    _unitAttributeString = unitAttributeString;
    self.unitLab.attributedText = unitAttributeString;
}

- (void)setTextFieldContentInsets:(UIEdgeInsets)textFieldContentInsets{
    _textFieldContentInsets = textFieldContentInsets;
    self.textField.contentInsets = textFieldContentInsets;
}

#pragma mark - update style
- (void)p_updateUnitLabStyle{
    if (self.unitLab && self.unitLab.hidden == NO) {
        self.unitLab.attributedText = [[NSAttributedString alloc] initWithString:self.unitString attributes:self.unitStringAttributes];
    }
}

- (void)p_updatePlaceHolderLabStyle{
    if (self.placeHolder) {
        self.placeHolderAttributeString = [[NSAttributedString alloc] initWithString:self.placeHolder attributes:self.placeHolderAttributes];
    }
    
}

- (void)p_updateTipTitleLabStyle{
    if (self.tipTitleLab && self.tipTitleLab.hidden == NO) {
        self.tipTitleLab.attributedText = [[NSAttributedString alloc] initWithString:self.tipTitle attributes:self.tipTitleAttributes];
    }
}

- (void)p_updateTextViewStyle{
    if (self.textViewAttributes[NSForegroundColorAttributeName]) {
        self.textField.textColor = self.textViewAttributes[NSForegroundColorAttributeName];
    }
    if (self.textViewAttributes[NSFontAttributeName]) {
        self.textField.font = self.textViewAttributes[NSFontAttributeName];
    }
}

- (BLTTextField *)textField{
    if (!_textField) {
        _textField = [[BLTTextField alloc] init];
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.backgroundColor = BLT_HEXCOLOR(0xF8F8F8);
    }
    return _textField;
}


@end


@implementation BLTTextField

- (CGRect)textRectForBounds:(CGRect)bounds{
    bounds = CGRectFromUIEdgeInsets(bounds, self.contentInsets);
    if ([self rightViewShowing]) {
        bounds = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetWidth(bounds) -  - 5, CGRectGetHeight(bounds));
    }
    return [super textRectForBounds:bounds];
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds{
    bounds = [super rightViewRectForBounds:bounds];
    if (UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.contentInsets)) {
        return bounds;
    }else{
        bounds.origin.x -= self.contentInsets.right;
        return bounds;
    }
}

/** 编辑状态下的rect */
- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds = CGRectFromUIEdgeInsets(bounds, self.contentInsets);
    return [super editingRectForBounds:bounds];
}

- (BOOL)rightViewShowing{
    if (self.rightView && self.rightView.hidden == NO) {
        return YES;
    }
    return NO;
}




@end
