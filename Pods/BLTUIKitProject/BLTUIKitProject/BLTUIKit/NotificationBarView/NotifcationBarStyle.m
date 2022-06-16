//
//  NotifcationBarStyle.m
//  Baletu
//
//  Created by wangwenbo on 2020/2/20.
//  Copyright © 2020 朱 亮亮. All rights reserved.
//

#import "NotifcationBarStyle.h"

@implementation NotifcationBarStyle

-(instancetype)init{
    if (self == [super init]) {
        [self setDefaultStyle];
    }
    return self;
}
-(void)setDefaultStyle{
    self.barBackGroundColor =[UIColor colorWithRed:255/255.0 green:251/255.0 blue:232/255.0 alpha:1.0];//0xFFFBE8
    
    self.contentFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
    self.contentColor = [UIColor colorWithRed:239/255.0 green:122/255.0 blue:37/255.0 alpha:1.0];//(0xEF7A25);
    self.notificationContentStyle = NotificationContentSingleLineStyle;
    self.textAlignment = NSTextAlignmentLeft;
    
    self.handleBtnFont = [UIFont fontWithName:@"PingFangSC-Medium" size:13];
    self.handleBtnTitleColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];//(0xffffff);
    self.handleBtnBackGroundColor = [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1.0];//(0xF5A623);
    self.handleBtnCornerRadius = 12.5;
    self.handleBtnEdgeInsets = UIEdgeInsetsZero;
    // 默认 透明边框
    self.handleBtnBorderColor = UIColor.clearColor;
    self.rightIsRemove = YES;
    self.defaultShowTime = 5.0;
    self.autoDismiss = NO;
    self.barCornerRadius = 0.0;
    self.handleBtnBorderWidth = 1;
}
//ios 8 不能展示 平方字体因此 对于不能展示的字体 设置了默认13号的系统字体
-(void)setContentFont:(UIFont *)contentFont{
    if (contentFont) {
        _contentFont = contentFont;
    }else{
        _contentFont = [UIFont systemFontOfSize:13];
    }
}
-(void)setHandleBtnFont:(UIFont *)handleBtnFont{
    if (handleBtnFont) {
        _handleBtnFont = handleBtnFont;
    }else{
        _handleBtnFont = [UIFont systemFontOfSize:13];
    }
}

- (void)setGradientDirection:(GradientLayerDirection)gradientDirection
{
    _gradientDirection = gradientDirection;
    switch (_gradientDirection) {
        case GradientLayerDirectionLeftToRight:
        {
            self.contentBackgroundGradient.startPoint = CGPointMake(0, 0);
            self.contentBackgroundGradient.endPoint = CGPointMake(1, 0);
        }
            break;
        case GradientLayerDirectionTopToBottom:
        {
            self.contentBackgroundGradient.startPoint = CGPointMake(0, 0);
            self.contentBackgroundGradient.endPoint = CGPointMake(0, 1);
        }
            break;
        case GradientLayerDirectionInclined:
        {
            self.contentBackgroundGradient.startPoint = CGPointMake(0, 0);
            self.contentBackgroundGradient.endPoint = CGPointMake(1, 1);
        }
            break;
    }
}

- (BLTGradientLayerConfig *)contentBackgroundGradient
{
    if (!_contentBackgroundGradient) {
        _contentBackgroundGradient = [[BLTGradientLayerConfig alloc] init];
    }
    return _contentBackgroundGradient;
}

@end

@implementation BLTGradientLayerConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _locations = @[@(0.0), @(1.0)];
        _startPoint = CGPointMake(0.0, 0.0);
        _endPoint = CGPointMake(1.0, 0.0);
    }
    return self;
}

@end
