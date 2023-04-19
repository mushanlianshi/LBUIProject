//
//  BLTAlertController.h
//  BLTUIKit
//
//  Created by liu bin on 2020/2/26.
//  Copyright © 2020 liu bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLTAlertAction.h"
#import "BLTTextFieldView.h"
#import "BLTAlertTransitioningAnimator.h"

typedef NS_ENUM(NSInteger, BLTAlertControllerStyle){
    BLTAlertControllerStyleAlert = 0,   //文案类的展示
    BLTAlertControllerStyleActionSheet, //actionSheet样式的
    BLTAlertControllerStyleFeedAlert,   //反馈类弹框
};

//按钮方向  默认2个左右排列 多余2个上下排列
typedef NS_ENUM(NSInteger, BLTAlertControllerButtonDirection){
    BLTAlertControllerButtonDirectionAuto = 0,
    BLTAlertControllerButtonDirectionVertical,  //不管几个都竖直方向排列
};


@interface BLTAlertController : UIViewController


/**
 @param title alert的title  系统API方式创建的方法
 @param message message 小于两行居中显示  大于两行靠左显示
 @param style 是alert 还是 actionSheet
 */
+ (instancetype)alertControllerWithTitle:(NSString *)title mesage:(NSString *)message style:(BLTAlertControllerStyle)style;

/** 快速初始化的 */
- (instancetype)initWithTitle:(NSString *)title mesage:(NSString *)message style:(BLTAlertControllerStyle)style sureTitle:(NSString *)sureTitle sureBlock:(void(^)(BLTAlertAction *cancelAction))sureBlock;
/** 快速初始化取消  确定按钮的 */
- (instancetype)initWithTitle:(NSString *)title mesage:(NSString *)message style:(BLTAlertControllerStyle)style cancelTitle:(NSString *)cancelTitle cancelBlock:(void(^)(BLTAlertAction *cancelAction))cancelBlock sureTitle:(NSString *)sureTitle sureBlock:(void(^)(BLTAlertAction *sureAction))sureBlock;

- (void)addAction:(BLTAlertAction *)action;

/** 添加textField */
- (void)addTextFieldWithConfigurationHandler:(void(^)(BLTTextFieldView *textView))configurationHandler;

/** alert的内容view自定义 */
- (void)addCustomView:(UIView *)customView;

@property (nonatomic, copy, readonly) NSArray<BLTAlertAction *> *actions;

/** 圆角的大小 */
@property (nonatomic, assign) CGFloat alertContentRaduis;

/** 按钮的高度 */
@property (nonatomic, assign) CGFloat alertButtonHeight;

/** alert距屏幕的间距 */
@property (nonatomic, assign) UIEdgeInsets alertContentInsets;

/** 最大的内容的宽度 */
@property (nonatomic, assign) CGFloat alertContentMaxWidth;

/** title 文字的样式  间距 字体  颜色 等 */
@property (nonatomic, copy) NSDictionary <NSString *, id>*alertTitleAttributes;

@property (nonatomic, copy) NSDictionary <NSString *, id>*alertContentAttributes;

/** title的富文本 */
@property (nonatomic, copy) NSAttributedString *alertTitleAttributeString;

/** 内容设置富文本 设置了富文本一些默认设置的就无效了 需要自己设置富文本的样式 */
@property (nonatomic, copy) NSAttributedString *alertContentAttributeString;

/** 给内容添加富文本的点击事件 配合alertContentAttributeString 使用*/
- (void)addContentAttributeTapActionWithStrings:(NSArray <NSString *>*)strings tapHandler:(void(^)(NSString *string, NSRange range, NSInteger index))tapHandler;

@property (nonatomic, strong) UIColor *alertSeparatorColor;

/** 设置正常按钮的attributes */
@property (nonatomic, copy) NSDictionary <NSString *, id>*alertButtonAttributes;
/** 设置取消按钮的attibutes */
@property (nonatomic, copy) NSDictionary <NSString *, id>*alertCancelButtonAttributes;
/** 设置destructive的样式 */
@property (nonatomic, copy) NSDictionary <NSString *, id>*alertDestructiveButtonAttributes;

/** 弹框北京遮罩的颜色 */
@property (nonatomic, strong) UIColor *alertMaskViewBackgroundColor;
/** 非按钮部分的背景色 */
@property (nonatomic, strong) UIColor *alertHeaderBackgroundColor;
/** 按钮的背景色  默认和alertHeaderBackgroundColor一致 */
@property (nonatomic, strong) UIColor *alertButtonBackgroundColor;
/** 按钮的方向   */
@property (nonatomic, assign) BLTAlertControllerButtonDirection alertActionDirection;
/** 非按钮部分的内间距 */
@property (nonatomic, assign) UIEdgeInsets alertHeaderInsets;
/** title和content的间距 */
@property (nonatomic, assign) CGFloat alertTitleContentSpacing;

/** textField的font */
@property (nonatomic, strong) UIFont *alertTextFieldFont;
@property (nonatomic, strong) UIColor *alertTextFieldTextColor;
@property (nonatomic, assign) CGFloat alertTextFieldHeight;

/** 按钮的排序是否遵守添加的  默认为NO  和系统保持一致 */
@property (nonatomic, assign) BOOL orderAlertActionsByAddOrdered;

/** 在title上面加一个图片 */
- (void)addTitleImage:(UIImage *)titleImage;
/** 和上面的配对使用 默认15*/
@property (nonatomic, assign) CGFloat alertTitleImageSpacing;

#pragma mark - actionSheet的属性设置
@property (nonatomic, assign) CGFloat actionSheetContentMaxWidth;

@property (nonatomic, assign) CGFloat actionSheetContentCornerRaduis;
/** 取消按钮的间距 */
@property (nonatomic, assign) CGFloat actionSheetCancelButtonSpacing;
/** 按钮的高度 默认55 */
@property (nonatomic, assign) CGFloat actionSheetButtonHeight;

#pragma mark - feedAlert
/** 右上角关闭按钮的 回调出去设置神策采集元素内容的 */
- (void)addRightTopCloseButtonHandler:(dispatch_block_t)handler closeButtonConfig:(void(^)(UIButton *closeButton))closeButtonConfig;

@property (nonatomic, assign) CGFloat feedAlertButtonHoriSpacing;

@property (nonatomic, assign) CGFloat feedAlertButtonVerticalSpacing;

@property (nonatomic, strong) UIColor *feedAlertStartGradientColor;

@property (nonatomic, strong) UIColor *feedAlertEndGradientColor;

/** 按钮距离弹框的内间距 */
@property (nonatomic, assign) UIEdgeInsets feedAlertButtonInsets;

/** feedAlert按钮样式的属性 */
@property (nonatomic, copy) NSDictionary <NSString *, id>*feedAlertButtonAttributes;
/** feedAlert按钮的样式 */
@property (nonatomic, copy) NSDictionary <NSString *, id> *feedAlertDestrutiveButtonAttributes;

/** 有点击按钮的动作是否关闭controller 默认YES */
@property (nonatomic, assign) BOOL autoActionClose;

//背景色点击是否自动关闭的  默认NO
@property (nonatomic, assign) BOOL backgroundClickDismiss;

/** 主动更新按钮的样式 */
- (void)updateAlertActionStyle;

+ (BOOL)isAnyAlertControllerExist;

@property (nonatomic, strong) BLTAlertTransitioningAnimator       *transitioningAnimator;

//修改控件样式的回调  不建议用
@property (nonatomic, copy) void(^alertControllerConfigUI) (UILabel *titleLab, UILabel *contentLab,UIView *maskView, UIView *containerView,UIView *wrapView, UIScrollView *headerScrollView, UIScrollView *buttonScrollView);

//处理神策采集的
@property (nonatomic, copy) void(^customSensorDataBlock) (UIViewController *alertVC, UIControl *backgroundControl) UI_APPEARANCE_SELECTOR;
//处理神策事件的  addRightTopCloseButtonHandler会覆盖这里面设置的元素内容
@property (nonatomic, copy) void(^customSensorCloseBtnBlock)(UIButton *button) UI_APPEARANCE_SELECTOR;

@property (nonatomic, copy) dispatch_block_t didDisappearBlock;

@property (nonatomic, copy) dispatch_block_t didAppearBlock;

@property (nonatomic, copy) dispatch_block_t didLayoutSubviewsBlock;

@end


/** 全局样式统一设置的 */
@interface BLTAlertController (Appearance)

+ (instancetype)appearance;

@end


