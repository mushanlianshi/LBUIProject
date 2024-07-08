//
//  BLTImagePreviewNaviBar.m
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/27.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import "BLTImagePreviewNaviBar.h"
#import "BLTUICommonDefines.h"
@interface BLTImagePreviewNaviBar ()

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation BLTImagePreviewNaviBar

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLab];
        [self addSubview:self.backButton];
        [self addSubview:self.deleteBtn];
        CGFloat screenW = [[UIScreen mainScreen] bounds].size.width;
        CGFloat statusBarH = [[UIApplication sharedApplication] statusBarFrame].size.height;
        self.frame = CGRectMake(0, 0, screenW, statusBarH + 44);
        self.titleLab.frame = CGRectMake(0, statusBarH, screenW, 44);
        self.backButton.frame = CGRectMake(0, statusBarH, 44, 44);
        self.deleteBtn.frame = CGRectMake(screenW - 44, statusBarH, 44, 44);
    }
    return self;
}

- (void)refreshNaviBarUIConfig:(void(^)(UIButton *deleteButton, UILabel *titleLab, UIButton *backButton))config{
    if (config) {
        config(self.deleteBtn, self.titleLab, self.backButton);
    }
}

- (void)setBackImage:(UIImage *)backImage{
    _backImage = backImage;
    [self.backButton setImage:backImage forState:UIControlStateNormal];
}

- (void)backButtonClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(navibarDidClickBack:)]) {
        [self.delegate navibarDidClickBack:self];
    }else if (self.backBlock){
        self.backBlock();
    }
}

- (void)deleteButtonClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(navibarDidClickDelete:)]) {
        [self.delegate navibarDidClickDelete:self];
    }
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setImage:UIImageNamedFromBLTUIKItBundle(@"blt_upload_image_navi_back_white") forState:UIControlStateNormal];
    }
    return _backButton;
}

- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.font = UIFontPFBoldFontSize(17);
    }
    return _titleLab;
}

- (UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc] init];
        [_deleteBtn addTarget:self action:@selector(deleteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_deleteBtn setImage:UIImageNamedFromBLTUIKItBundle(@"blt_upload_image_navi_delete") forState:UIControlStateNormal];
    }
    return _deleteBtn;
}

@end
