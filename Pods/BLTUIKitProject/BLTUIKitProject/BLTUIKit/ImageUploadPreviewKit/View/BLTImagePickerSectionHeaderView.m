//
//  BLTImagePickerSectionHeaderView.m
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/25.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import "BLTImagePickerSectionHeaderView.h"
#import "BLTBaseLabel.h"
#import "BLTUICommonDefines.h"

@interface BLTImagePickerSectionHeaderView ()

@property (nonatomic, strong) BLTBaseLabel *titleLab;

@end

@implementation BLTImagePickerSectionHeaderView

- (void)setTitle:(id)title{
    _title = title;
    if ([title isKindOfClass:[NSString class]]) {
        self.titleLab.text = title;
    }else if ([title isKindOfClass:[NSAttributedString class]]){
        self.titleLab.attributedText = title;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLab.frame = self.bounds;
}

- (BLTBaseLabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[BLTBaseLabel alloc] initWithContentInsets:UIEdgeInsetsMake(15, 0, 10, 0)];
        _titleLab.font = UIFontPFFontSize(14);
        _titleLab.textColor = BLT_HEXCOLOR(0x333333);
        [self addSubview:_titleLab];
    }
    return _titleLab;
}

@end
