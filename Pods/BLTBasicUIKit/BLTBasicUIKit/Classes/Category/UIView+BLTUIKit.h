//
//  UIView+UITool.h
//  BLTUIKit
//
//  Created by liu bin on 2020/2/26.
//  Copyright © 2020 liu bin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, UIRectLineSide){
    UIRectLineSideLeft = 1 << 0,
    UIRectLineSideTop = 1 << 1,
    UIRectLineSideRight = 1 << 2,
    UIRectLineSideBottom = 1 << 3,
    UIRectLineSideAllSide = ~0UL
};

typedef NS_ENUM(NSInteger, BLTGrandientLayerDirection){
    BLTGrandientLayerDirectionLeftToRight = 0,
    BLTGrandientLayerDirectionLeftToRightBotton,
    BLTGrandientLayerDirectionTopToBottom,
};

extern const CGFloat BLTUIViewSelfSizingHeight;

@interface UIView (BLTUIKit)

@property (nonatomic, assign) CGFloat blt_layerCornerRaduis;

/** 显示圆角的 */
- (void)blt_showLayerCorner:(UIRectCorner)rectCorner size:(CGSize)size lineWidth:(CGFloat)lineWidth;
/** 显示边框的 */
- (void)blt_showBorderColor:(UIColor *)color;
- (void)blt_showBorderColor:(UIColor *)color cornerRaduis:(CGFloat)cornerRaduis borderWidth:(CGFloat)borderWidth;

/** 给view添加线 */
- (void)blt_addLineRectCorner:(UIRectLineSide)rectCorner lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor;

/** 添加渐变色 */
- (void)blt_addGrandientLayerStartColor:(UIColor *)startColor endColor:(UIColor *)endColor direction:(BLTGrandientLayerDirection)direction;

//添加渐变色  针对不知道frame的  layoutsubviews后添加渐变色的
- (void)blt_addGrandientLayerStartColor:(UIColor *)startColor endColor:(UIColor *)endColor direction:(BLTGrandientLayerDirection)direction needAfterLayout:(BOOL)needAfterLayout;

- (UIViewController *)blt_getCurrentControllerFromSelf;

- (void)blt_removeAllSubviews;

- (void)blt_addTapBlock:(dispatch_block_t)tapBlock;

- (void)blt_addLongPressBlock:(dispatch_block_t)longpressBlock;
/** 是否可以一直响应    针对addTapBlock方法的 */
@property (nonatomic, assign) BOOL blt_allTimeResponse;

#pragma mark - 添加阴影
//只是添加阴影的
- (void)blt_addShadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset shadowOpacity:(CGFloat)shadowOpacity shadowRaduis:(CGFloat)shadowRadius;
//添加阴影和边框的
- (void)blt_addShadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset shadowOpacity:(CGFloat)shadowOpacity shadowRaduis:(CGFloat)shadowRadius cornerRaduis:(CGFloat)cornerRaduis borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

@end




@interface UIView (BLTFrame)

/** 宽度 */
@property (nonatomic, assign) CGFloat blt_width;

/** 高度 */
@property (nonatomic, assign) CGFloat blt_height;

/** 起始值X */
@property (nonatomic, assign) CGFloat blt_x;

/** 起始值Y */
@property (nonatomic, assign) CGFloat blt_y;

/** 中心点X */
@property (nonatomic, assign) CGFloat blt_centerX;

/** 中心点Y */
@property (nonatomic, assign) CGFloat blt_centerY;

/** top */
@property (nonatomic, assign) CGFloat blt_top;

/** bottom */
@property (nonatomic, assign) CGFloat blt_bottom;

@property (nonatomic, assign) CGFloat blt_right;

@end





@interface UIView (BLTInit)

+ (instancetype)blt_lineView;

+ (instancetype)blt_viewWithBackgroundColor:(UIColor *)color;

@property (nonatomic, strong) UIColor *blt_lineColor UI_APPEARANCE_SELECTOR;

@end
