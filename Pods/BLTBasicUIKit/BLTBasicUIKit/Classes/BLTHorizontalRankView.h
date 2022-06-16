//
//  BLTHorizontalRankView.h
//  BLTBasicUIKit
//
//  Created by liu bin on 2020/7/6.
//

#import <UIKit/UIKit.h>

/** 水平方向排列subviews的 */
@interface BLTHorizontalRankView : UIView<UIAppearance>



/// 创建地步view的多子view的
/// @param subViews 子view
/// @param spacing 间距
+ (instancetype)rankViewWithSubViews:(NSArray <UIView *>*)subViews spacing:(CGFloat)spacing;
+ (instancetype)rankViewWithSubViews:(NSArray <UIView *>*)subViews spacing:(CGFloat)spacing contentInsets:(UIEdgeInsets)contentInsets;


/// 创建一个只有一个按钮的地步view
/// @param title 按钮的文案  默认字体和颜色  背景色
/// @param clickBlock 点击的回调
+ (instancetype)rankButtonWithTitle:(NSString *)title clickBlock:(dispatch_block_t)clickBlock;

/// 创建一个只有一个按钮的地步view
/// @param title 按钮的文案  默认字体和颜色  背景色
/// @param clickBlock 点击的回调
/// @param buttonConfig 设置的button样式的
+ (instancetype)rankButtonWithTitle:(NSString *)title  clickBlock:(dispatch_block_t)clickBlock buttonConfig:(void(^)(UIButton *button))buttonConfig;

/** UIStackView 只负责布局  不负责渲染   所以设置背景色 边框等展示无效   如果要设置 对contentBackgroundView设置*/
@property (nonatomic, copy) void(^stackViewConfigUI)(UIStackView *stackView,UIView *contentBackgroundView);
@property (nonatomic, copy) NSArray *rankSubViews;
/** 子view的宽度比 */
@property (nonatomic, copy) NSArray <NSNumber *>*subViewWidthScale;


/** 一个按钮样式外观设置的 */
+ (instancetype)appearance;
@property (nonatomic, strong) UIColor *rankButtonBackgroundColor;
@property (nonatomic, strong) UIFont *rankButtonTitleFont;
@property (nonatomic, strong) UIColor *rankButtonTitleColor;
@property (nonatomic, assign) CGFloat rankButtonLayerCornerRaduis;
/** 默认10 */
@property (nonatomic, assign) CGFloat spacing;
/** 默认(10, 15, 10, 15)*/
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@end



