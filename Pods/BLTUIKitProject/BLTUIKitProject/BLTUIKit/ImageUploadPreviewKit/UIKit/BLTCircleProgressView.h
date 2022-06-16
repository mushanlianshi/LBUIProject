//
//  BLTCircleProgressView.h
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/25.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BLTCircleProgressView : UIView

@property (nonatomic, strong) UIColor *backgroundCircleColor;

@property (nonatomic, strong) UIColor *progressCircleColor;

//宽度
@property (nonatomic, assign) CGFloat circleWidth;
//半径
@property (nonatomic, assign) CGFloat circleRaduis;

@property (nonatomic, assign) CGFloat progress;

//刷新底部圆环的位置的  初始化的时候view frame为0时处理的
- (void)refreshBackgroundCircle;
@end

