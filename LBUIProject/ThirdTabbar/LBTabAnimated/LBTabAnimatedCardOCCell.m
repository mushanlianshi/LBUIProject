//
//  LBTabAnimatedCardOCCell.m
//  LBUIProject
//
//  Created by liu bin on 2025/3/21.
//

#import "LBTabAnimatedCardOCCell.h"
#import <Masonry/Masonry.h>
#import <BLTUIKitProject/BLTUI.h>

@interface LBTabAnimatedCardOCCell()

/// 底部卡片样式的view
@property(nonatomic, strong) UIView *cardView;

@property(nonatomic, strong) UIView *containerView;

@property(nonatomic, strong) UIImageView *hotelIV;

@property (nonatomic,strong) UILabel *titleLab;

@property (nonatomic,strong) UILabel *timeLab;

@property (nonatomic,strong) UILabel *descLab;

@property (nonatomic,strong) UILabel *rightBottomLab;

@end

@implementation LBTabAnimatedCardOCCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 5, BLT_DEF_SCREEN_WIDTH - 10*2, 140)];
        view.layer.cornerRadius = 10;
        view.backgroundColor = [UIColor lightTextColor];
        // 给bgView边框设置阴影
        view.layer.shadowOpacity = 0.1;
        view.layer.shadowColor = UIColor.redColor.CGColor;
        view.layer.shadowRadius = 5;
        view.layer.shadowOffset = CGSizeMake(1,1);
        self.containerView = view;
        // card样式 只能记载cell上，不是contentView上
        [self addSubview:view];
        [self setupUI];
    }
    return self;
}


- (void)setupUI {
    [self.containerView addSubview:self.hotelIV];
    [self.containerView addSubview:self.titleLab];
    [self.containerView addSubview:self.timeLab];
    [self.containerView addSubview:self.descLab];
    [self.containerView addSubview:self.rightBottomLab];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    
    [self.hotelIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(10);
        make.top.mas_offset(10);
        make.width.mas_equalTo(100);
        make.bottom.equalTo(self.containerView).mas_offset(-10);
    }];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(self.hotelIV.mas_right).mas_offset(10);
        make.right.mas_equalTo(self.contentView.mas_rightMargin);
    }];
    
    [_timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(8);
        make.left.right.mas_equalTo(self.titleLab);
    }];
    
    [_descLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLab.mas_bottom).offset(8);
        make.left.mas_equalTo(self.titleLab);
        make.bottom.mas_equalTo(-10);
    }];
    
    [_rightBottomLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-10);
        make.top.equalTo(_descLab.mas_bottom);
        make.bottom.mas_equalTo(-10);
    }];
    
}


- (UIImageView *)hotelIV{
    if (!_hotelIV) {
        _hotelIV = [UIImageView new];
        _hotelIV.contentMode = UIViewContentModeScaleAspectFill;
        _hotelIV.layer.cornerRadius = 5;
        _hotelIV.layer.masksToBounds = true;
        _hotelIV.layer.borderWidth = 1;
        _hotelIV.layer.borderColor = [UIColor redColor].CGColor;
//        _hotelIV.backgroundColor = [UIColor redColor];
    }
    return  _hotelIV;
}

- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        [_descLab setFont:UIFontPFFontSize(15)];
        [_descLab setTextColor:[UIColor blackColor]];
        
        _descLab.numberOfLines = 0;
    }
    return _descLab;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        [_titleLab setFont:UIFontPFFontSize(15)];
        [_titleLab setTextColor:[UIColor blackColor]];
        
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
}

- (UILabel *)timeLab {
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] init];
        [_timeLab setFont:UIFontPFFontSize(12)];
    }
    return _timeLab;
}

- (UILabel *)rightBottomLab {
    if (!_rightBottomLab) {
        _rightBottomLab = [[UILabel alloc] init];
        [_rightBottomLab setFont:UIFontPFFontSize(12)];
    }
    return _rightBottomLab;
}

@end
