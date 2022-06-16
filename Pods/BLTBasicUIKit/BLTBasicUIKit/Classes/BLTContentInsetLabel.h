//
//  BLTBaseLabel.h
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/25.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, BLTGradientLabelDirection){
    BLTGradientLabelDirectionLeftToRight = 1,   //左到右
    BLTGradientLabelDirectionTopToBottom = 2,   //上到下
    BLTGradientLabelDirectionLeftTopToRightBottom = 3,  //左上到右下
    BLTGradientLabelDirectionLeftBottomToRightTop = 4,  //左下到右上
};

@interface BLTContentInsetLabel : UILabel

- (instancetype)initWithContentInsets:(UIEdgeInsets)insets;

/** 内容的区域 */
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;

@end

/** 渐变色背景的label */
@interface BLTGradientLabel : BLTContentInsetLabel

@property (nonatomic, copy) NSArray <UIColor *>*gradientColors;

@property (nonatomic, assign) BLTGradientLabelDirection gradientDirection;

@end


