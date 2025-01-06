//
//  UIView+Common.h
//  BlueMobiProject
//
//  Created by 朱 亮亮 on 14-4-28.
//  Copyright (c) 2014年 朱 亮亮. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 *  UIView 通用Category
 */
@interface UIView (Common)

/**
 *  获取左上角横坐标
 *
 *  @return 坐标值
 */
- (CGFloat)cm_left;

/**
 *  获取左上角纵坐标
 *
 *  @return 坐标值
 */
- (CGFloat)cm_top;

/**
 *  获取视图右下角横坐标
 *
 *  @return 坐标值
 */
- (CGFloat)cm_right;

/**
 *  获取视图右下角纵坐标
 *
 *  @return 坐标值
 */
- (CGFloat)cm_bottom;

/**
 *  获取视图宽度
 *
 *  @return 宽度值（像素）
 */
- (CGFloat)cm_width;

/**
 *  获取视图高度
 *
 *  @return 高度值（像素）
 */
- (CGFloat)cm_height;


/**
 * 设置layer拐角的
 */
@property (nonatomic,assign) CGFloat layerCornerRaduis;

/** 宽度 */
@property (nonatomic, assign) CGFloat lb_width;

/** 高度 */
@property (nonatomic, assign) CGFloat lb_height;

/** 起始值X */
@property (nonatomic, assign) CGFloat lb_x;

/** 起始值Y */
@property (nonatomic, assign) CGFloat lb_y;

/** 中心点X */
@property (nonatomic, assign) CGFloat lb_centerX;

/** 中心点Y */
@property (nonatomic, assign) CGFloat lb_centerY;

/** top */
@property (nonatomic, assign) CGFloat lb_top;

/** bottom */
@property (nonatomic, assign) CGFloat lb_bottom;

@property (nonatomic, assign) CGFloat lb_right;

-(void)showRedBorder;

-(void)showBlueBorder;


- (void)addTapBlock:(dispatch_block_t)tapBlock;

- (void)addLongPressBlock:(dispatch_block_t)longpressBlock;

- (void)roundedRectWithView:(UIView *)view rectCorner:(UIRectCorner)rectCorner size:(CGSize)size num:(NSInteger)num;

- (void)roundedRectWithView:(UIView *)view rectCorner:(UIRectCorner)rectCorner size:(CGSize)size;

/** 是否可以一直响应 */
@property (nonatomic, assign, getter=isAllTimeResponse) BOOL allTimeResponse;

/**
 *	@brief	删除所有子对象
 */
- (void)removeAllSubviews;


/**
 *  设置部分圆角(绝对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii;


@end
