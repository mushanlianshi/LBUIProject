//
//  BLTAlertController.m
//  BLTUIKit 1.1.1
//
//  Created by liu bin on 2020/2/26.
//  Copyright © 2020 liu bin. All rights reserved.
//

#import "BLTAlertController.h"
#import "BLTUICommonDefines.h"
#import "UILabel+YBAttributeTextTapAction.h"
#import <BLTBasicUIKit/BLTBasicUIKit.h>

static NSTimeInterval const kAnimationDuration = 0.29;

static NSInteger alertControllerCount = 0;

//单例  appearance  统一设置外观用的
static BLTAlertController *  alertAppearanceInstance;
@implementation BLTAlertController (Appearance)

+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance];
    });
}

+ (instancetype)appearance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initAppearance];
    });
    return alertAppearanceInstance;
}

/** 初始化外观的一些设置 */
+ (void)initAppearance{
    if (!alertAppearanceInstance) {
        alertAppearanceInstance = [[BLTAlertController alloc] init];
        alertAppearanceInstance.alertContentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        alertAppearanceInstance.alertHeaderInsets = UIEdgeInsetsMake(20, 20, 15, 20);
        alertAppearanceInstance.alertContentMaxWidth = 270;
        alertAppearanceInstance.alertTitleAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                                         NSFontAttributeName:UIFontPFFontSize(17),
                                                         NSParagraphStyleAttributeName:[self defalutParagraphStyle]
                                                         };
        alertAppearanceInstance.alertContentAttributes = @{NSForegroundColorAttributeName:BLT_HEXCOLOR(0x666666),
                                                           NSFontAttributeName:UIFontPFFontSize(14),
                                                           NSParagraphStyleAttributeName:[self defalutParagraphStyle]
                                                           };
        alertAppearanceInstance.alertButtonHeight = 44;
        alertAppearanceInstance.alertContentRaduis = 4;
        alertAppearanceInstance.alertMaskViewBackgroundColor = [BLT_HEXCOLOR(0x777777) colorWithAlphaComponent:0.5];
        alertAppearanceInstance.alertHeaderBackgroundColor = BLT_HEXCOLOR(0xFFFFFF);
        alertAppearanceInstance.alertButtonBackgroundColor = [UIColor whiteColor];
        alertAppearanceInstance.alertActionDirection = BLTAlertControllerButtonDirectionAuto;
        alertAppearanceInstance.alertTitleContentSpacing = 8;
        alertAppearanceInstance.alertTextFieldFont = UIFontPFFontSize(14);
        alertAppearanceInstance.alertTextFieldTextColor = BLT_HEXCOLOR(0x333333);
        alertAppearanceInstance.alertTextFieldHeight = 44;
        alertAppearanceInstance.alertSeparatorColor = BLT_HEXCOLOR(0xC2C2C2);
        alertAppearanceInstance.alertButtonAttributes = @{NSForegroundColorAttributeName:BLT_HEXCOLOR(0x333333),
                                                          NSFontAttributeName:UIFontPFFontSize(16)
                                                          };
        alertAppearanceInstance.alertCancelButtonAttributes = @{NSForegroundColorAttributeName:BLT_HEXCOLOR(0x333333),
                                                                NSFontAttributeName:UIFontPFFontSize(16)
                                                                };
        alertAppearanceInstance.alertDestructiveButtonAttributes = @{NSForegroundColorAttributeName:BLT_HEXCOLOR(0xEE3943),
                                                                     NSFontAttributeName:UIFontPFFontSize(16)
                                                                     };
        alertAppearanceInstance.alertTitleImageSpacing = 15;
        
        alertAppearanceInstance.actionSheetContentMaxWidth = [[UIScreen mainScreen] bounds].size.width - 20;
        alertAppearanceInstance.actionSheetContentCornerRaduis = 5;
        alertAppearanceInstance.actionSheetCancelButtonSpacing = 10;
        alertAppearanceInstance.actionSheetButtonHeight = 55;
        
        alertAppearanceInstance.feedAlertButtonHoriSpacing = 15;
        alertAppearanceInstance.feedAlertButtonVerticalSpacing = 10;
        alertAppearanceInstance.feedAlertStartGradientColor = BLT_HEXCOLOR(0xFF2A5C);
        alertAppearanceInstance.feedAlertEndGradientColor = BLT_HEXCOLOR(0xFF656C);
        alertAppearanceInstance.feedAlertButtonAttributes = @{NSForegroundColorAttributeName:BLT_HEXCOLOR(0x333333),
                                                              NSFontAttributeName:UIFontPFFontSize(16)
                                                              };
        alertAppearanceInstance.feedAlertDestrutiveButtonAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                        NSFontAttributeName:UIFontPFFontSize(16)
                                                                        };
        alertAppearanceInstance.feedAlertButtonInsets = UIEdgeInsetsMake(0, 20, 20, 20);
        alertAppearanceInstance.autoActionClose = YES;
        alertAppearanceInstance.backgroundClickDismiss = false;
    }
    
}
+ (NSMutableParagraphStyle *)defalutParagraphStyle{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.maximumLineHeight = 0;
    paragraphStyle.minimumLineHeight = 0;
    paragraphStyle.lineSpacing = 5;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    return paragraphStyle;
}

@end


@interface BLTAlertController ()<BLTAlertActionDelegate, UITextViewDelegate, UITextFieldDelegate>{
    BOOL _needsUpdateTitleStyle;        //标记是否需要更新Title的外观
    BOOL _needsUpdateContentStyle;      //标记是否需要更新内容的外观
    BOOL _needsUpdateActionButtonStyle; //标记是否需要更新按钮的外观
    BOOL _needsUpdateTextFieldStyle;    //标记是否需要更新textField的外观
    BOOL _showing;
}

@property (nonatomic, assign) BLTAlertControllerStyle style;

/** 背景色的View */
@property (nonatomic, strong) UIControl *maskView;

@property (nonatomic, strong) UIView *containerView;

/** 最外层包裹的view */
@property (nonatomic, strong) UIView *wrapView;
/** 上面title  content  contentView等包裹的scrollView */
@property (nonatomic, strong) UIScrollView *headerScrollView;
/** 按钮的scrollView */
@property (nonatomic, strong) UIScrollView *buttonScrollView;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *contentLab;

/** 所有的action数组 */
@property (nonatomic, strong) NSMutableArray <BLTAlertAction *> *alertActions;

@property (nonatomic, strong) NSMutableArray <BLTTextFieldView *>*alertTextFields;

@property (nonatomic, copy) NSString *alertTitle;

@property (nonatomic, copy) NSString *alertMessage;

@property (nonatomic, strong) UIView *customView;

/** 取消按钮  放在最后的 */
@property (nonatomic, strong) BLTAlertAction *cancelAction;

@property (nonatomic, assign) CGFloat keyboardHeight;
/** 支持内容富文本点击 */
@property (nonatomic, assign) BOOL canTapContentAction;

@property (nonatomic, strong) UIImageView *headerImageView;

@property (nonatomic, strong) BLTUIResponseAreaButton *rightTopCloseButton;

@property (nonatomic, copy) dispatch_block_t rightTopCloseHandler;

@end

@implementation BLTAlertController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

+ (instancetype)alertControllerWithTitle:(NSString *)title mesage:(NSString *)message style:(BLTAlertControllerStyle)style{
    BLTAlertController *alertController = [[BLTAlertController alloc] initWithTitle:title message:message style:style];
    return alertController;
}

/** 快速初始化的 */
- (instancetype)initWithTitle:(NSString *)title mesage:(NSString *)message style:(BLTAlertControllerStyle)style sureTitle:(NSString *)sureTitle sureBlock:(void(^)(BLTAlertAction *cancelAction))sureBlock{
    return [self initWithTitle:title mesage:message style:style cancelTitle:nil cancelBlock:nil sureTitle:sureTitle sureBlock:sureBlock];
}
/** 快速初始化取消  确定按钮的 */
- (instancetype)initWithTitle:(NSString *)title mesage:(NSString *)message style:(BLTAlertControllerStyle)style cancelTitle:(NSString *)cancelTitle cancelBlock:(void(^)(BLTAlertAction *cancelAction))cancelBlock sureTitle:(NSString *)sureTitle sureBlock:(void(^)(BLTAlertAction *sureAction))sureBlock{
    self = [self initWithTitle:title message:message style:style];
    if (cancelTitle && cancelTitle.length > 0) {
        [self addAction:[BLTAlertAction actionWithTitle:cancelTitle style:BLTAlertActionStyleCancel handler:cancelBlock]];
    }
    if (sureTitle && sureTitle.length > 0) {
        [self addAction:[BLTAlertAction actionWithTitle:sureTitle style:BLTAlertActionStyleDestructive handler:sureBlock]];
    }
    return self;
}


- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message style:(BLTAlertControllerStyle)style{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.style = style;
        self.alertActions = [[NSMutableArray alloc] init];
        self.alertTextFields = [[NSMutableArray alloc] init];
        self.maskView = [[UIControl alloc] init];
        self.maskView.userInteractionEnabled = false;
        self.maskView.backgroundColor = [BLT_HEXCOLOR(0xF5F5F9) colorWithAlphaComponent:0.5];
        [self.maskView addTarget:self action:@selector(maskViewClicked) forControlEvents:UIControlEventTouchUpInside];
        self.containerView = [[UIView alloc] init];
        if (style == BLTAlertControllerStyleActionSheet) {
            self.containerView.backgroundColor = [UIColor clearColor];
        }else{
            self.containerView.backgroundColor = [UIColor whiteColor];
        }
        self.wrapView = [[UIView alloc] init];
        self.headerScrollView = [[UIScrollView alloc] init];
        self.buttonScrollView = [[UIScrollView alloc] init];
        if (@available(iOS 11, *)) {
            self.headerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            self.buttonScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        self.alertTitle = title;
        self.alertMessage = message;
        self.headerScrollView.backgroundColor = self.alertHeaderBackgroundColor;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.alertTitle) {
        self.titleLab.text = self.alertTitle;
    }
    [self startAlertStyle];
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.wrapView];
    [self.wrapView addSubview:self.headerScrollView];
    [self.wrapView addSubview:self.buttonScrollView];
    [self updateAlertContentRaduis];
    self.maskView.backgroundColor = self.alertMaskViewBackgroundColor;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSAssert(_showing, @"LBLog please use showWithAnimated selector instead");
    if (self.customSensorDataBlock) {
        self.customSensorDataBlock(self, self.maskView);
    }
}

/** 根据全局的样式初始化外观设置 */
- (void)didInitialize{
    if (alertAppearanceInstance) {
        self.alertContentInsets = alertAppearanceInstance.alertContentInsets;
        self.alertContentMaxWidth = alertAppearanceInstance.alertContentMaxWidth;
        self.alertHeaderInsets = alertAppearanceInstance.alertHeaderInsets;
        self.alertTitleAttributes = alertAppearanceInstance.alertTitleAttributes;
        self.alertContentAttributes = alertAppearanceInstance.alertContentAttributes;
        self.alertButtonAttributes = alertAppearanceInstance.alertButtonAttributes;
        self.alertCancelButtonAttributes = alertAppearanceInstance.alertCancelButtonAttributes;
        self.alertDestructiveButtonAttributes = alertAppearanceInstance.alertDestructiveButtonAttributes;
        self.alertButtonHeight = alertAppearanceInstance.alertButtonHeight;
        self.alertContentRaduis = alertAppearanceInstance.alertContentRaduis;
        self.alertMaskViewBackgroundColor = alertAppearanceInstance.alertMaskViewBackgroundColor;
        self.alertHeaderBackgroundColor = alertAppearanceInstance.alertHeaderBackgroundColor;
        self.alertButtonBackgroundColor = alertAppearanceInstance.alertButtonBackgroundColor;
        self.alertActionDirection = alertAppearanceInstance.alertActionDirection;
        self.alertTitleContentSpacing = alertAppearanceInstance.alertTitleContentSpacing;
        self.alertSeparatorColor = alertAppearanceInstance.alertSeparatorColor;
        self.alertTextFieldFont = alertAppearanceInstance.alertTextFieldFont;
        self.alertTextFieldTextColor = alertAppearanceInstance.alertTextFieldTextColor;
        self.alertTextFieldHeight = alertAppearanceInstance.alertTextFieldHeight;
        self.alertTitleImageSpacing = alertAppearanceInstance.alertTitleImageSpacing;
        self.actionSheetContentMaxWidth = alertAppearanceInstance.actionSheetContentMaxWidth;
        self.actionSheetCancelButtonSpacing = alertAppearanceInstance.actionSheetCancelButtonSpacing;
        self.actionSheetContentCornerRaduis = alertAppearanceInstance.actionSheetContentCornerRaduis;
        self.actionSheetButtonHeight = alertAppearanceInstance.actionSheetButtonHeight;
        
        self.feedAlertButtonHoriSpacing = alertAppearanceInstance.feedAlertButtonHoriSpacing;
        self.feedAlertButtonVerticalSpacing = alertAppearanceInstance.feedAlertButtonVerticalSpacing;
        self.feedAlertStartGradientColor = alertAppearanceInstance.feedAlertStartGradientColor;
        self.feedAlertEndGradientColor = alertAppearanceInstance.feedAlertEndGradientColor;
        self.feedAlertButtonAttributes = alertAppearanceInstance.feedAlertButtonAttributes;
        self.feedAlertDestrutiveButtonAttributes = alertAppearanceInstance.feedAlertDestrutiveButtonAttributes;
        self.feedAlertButtonInsets = alertAppearanceInstance.feedAlertButtonInsets;
        self.autoActionClose = alertAppearanceInstance.autoActionClose;
        self.backgroundClickDismiss = alertAppearanceInstance.backgroundClickDismiss;
        self.customSensorDataBlock = alertAppearanceInstance.customSensorDataBlock;
        self.customSensorCloseBtnBlock = alertAppearanceInstance.customSensorCloseBtnBlock;
        self.transitioningDelegate = self.transitioningAnimator;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    }
    
}

#pragma mark - 暴露出去属性用的
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.alertControllerConfigUI) {
        self.alertControllerConfigUI(self.titleLab, self.contentLab, self.maskView, self.containerView, self.wrapView, self.headerScrollView, self.buttonScrollView);
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.didAppearBlock) {
        self.didAppearBlock();
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.didDisappearBlock) {
        self.didAppearBlock();
    }
}

#pragma mark - 调整位置
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    //校验按钮的个数
    if (self.rightTopCloseButton == nil && self.style == BLTAlertControllerStyleAlert && self.alertActions.count < 1) {
        NSAssert(NO, @"LBLog BLTAlertController actionbutton count is not correct");
        return;
    }
    else if (self.customView == nil && self.style == BLTAlertControllerStyleActionSheet && self.alertActions.count < 2) {
        NSAssert(NO, @"LBLog BLTAlertController actionbutton count is not correct");
        return;
    }
    BOOL hasTitle = self.alertTitle && (self.alertTitle.length > 0);
    BOOL hasMessage = (self.alertMessage && (self.alertMessage.length > 0)) || NSArrayIsExist(self.alertTextFields) || self.customView;
    BOOL hasTextField = self.alertTextFields.count > 0;
    BOOL hasCustomView = !!self.customView;
    
    CGFloat verticalY = 0;
    self.maskView.frame = self.view.bounds;
    
    
    CGFloat contentOffsetLeft = self.alertHeaderInsets.left;
    CGFloat contentOffsetRight = self.alertHeaderInsets.right;
    CGFloat contentOffsetTop = (hasTitle || hasMessage) ? self.alertHeaderInsets.top : 0;
    CGFloat contentOffsetBottom = (hasTitle || hasMessage) ? self.alertHeaderInsets.bottom : 0;
    //内容最大的宽度不得超过alertContentMaxWidth
    CGFloat contentMaxWidth = (self.style == BLTAlertControllerStyleAlert || self.style == BLTAlertControllerStyleFeedAlert) ?
    fmin(self.alertContentMaxWidth, CGRectGetWidth(self.view.frame) - UIEdgeInsetsGetHorizontalValue(self.alertContentInsets)) :
    fmin(self.actionSheetContentMaxWidth, CGRectGetWidth(self.view.frame) - UIEdgeInsetsGetHorizontalValue(self.alertContentInsets));
    
    self.containerView.frame = CGRectSetWidth(self.containerView.frame, contentMaxWidth);
    self.wrapView.frame = CGRectSetWidth(self.wrapView.frame, CGRectGetWidth(self.containerView.frame));
    
    verticalY = contentOffsetTop;
    
    CGFloat contentWidth = CGRectGetWidth(self.wrapView.frame) - contentOffsetLeft - contentOffsetRight;
    
    //有图片 图片不用内容间距的左右
    if (self.headerImageView) {
        UIImage *image = self.headerImageView.image;
        //图片尺寸和内容宽度差b小于50 默认是背景图  不用topMargin
        if (fabs(contentMaxWidth - image.size.width) < 50) {
            verticalY = 0;
        }
        self.headerImageView.frame = CGRectMake(0, verticalY, image.size.width, image.size.height);
        self.headerImageView.frame = CGRectSetX(self.headerImageView.frame, CGRectGetWidth(self.containerView.bounds) / 2 - image.size.width / 2);
        verticalY += CGRectGetHeight(self.headerImageView.frame);
        verticalY += self.alertTitleImageSpacing;
    }
    
    //标题
    if (hasTitle) {
        CGSize size = [self.titleLab sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
        self.titleLab.frame = CGRectMake(contentOffsetLeft, verticalY, contentWidth, size.height);
        [self.headerScrollView addSubview:self.titleLab];
        verticalY += CGRectGetHeight(self.titleLab.bounds);
        verticalY += hasMessage ? self.alertTitleContentSpacing : 0;
    }
    
    //内容
    if (hasMessage) {
        CGSize size = [self.contentLab sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
        self.contentLab.frame = CGRectMake(contentOffsetLeft, verticalY, contentWidth, size.height);
        //调整间距
        verticalY += CGRectGetHeight(self.contentLab.frame) + self.alertTitleContentSpacing;
        [self p_updateMessageAlignment];
    }
    
    //有没有输入框 输入框和customView是互斥的
    if (hasTextField) {
        for (BLTTextFieldView *textField in self.alertTextFields) {
            textField.frame = CGRectMake(contentOffsetLeft, verticalY, contentWidth, self.alertTextFieldHeight);
            verticalY += CGRectGetHeight(textField.frame);
            verticalY += 15;
        }
    }
    
    //有没有自定义的view
    if (hasCustomView){
        //调整自定义view的大小  如果有frame  就用  没有计算frame
        CGSize customViewSize = CGSizeZero;
        if (CGRectGetHeight(self.customView.frame) > 0 && CGRectGetWidth(self.customView.frame) > 0) {
            customViewSize = self.customView.frame.size;
        }else{
            customViewSize = [self.customView sizeThatFits:CGSizeMake(CGRectGetWidth(self.wrapView.frame), CGFLOAT_MAX)];
        }
        _customView.frame = CGRectMake(CGRectGetWidth(self.wrapView.frame) / 2 - customViewSize.width / 2, verticalY, customViewSize.width, customViewSize.height);
        verticalY += CGRectGetHeight(self.customView.frame);
    }
    
    verticalY += contentOffsetBottom;
    //调整headerScrollView的位置
    self.headerScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.wrapView.frame), verticalY);
    self.headerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.frame), verticalY);
    //处理按钮的布局 两个按钮左右布局   剩下的都是竖直方向布局
    self.buttonScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.headerScrollView.frame), CGRectGetWidth(self.headerScrollView.frame), 0);
        CGFloat buttonVerticalY = 0;
        if (self.alertActions.count > 0) {
            if (self.style == BLTAlertControllerStyleAlert) {
                [self updateActionButtonPositionHoriSpacing:0 verticalSpacing:0];
            }
            //ActionSheet的布局
            else if(self.style == BLTAlertControllerStyleActionSheet){
                for (int i = 0; i < self.alertActions.count; i ++) {
                    BLTAlertAction *alertAction = self.alertActions[i];
                    if (alertAction.style == BLTAlertActionStyleCancel) break;
                    alertAction.actionButton.frame = CGRectMake(0, buttonVerticalY, CGRectGetWidth(self.buttonScrollView.frame), self.actionSheetButtonHeight);
                    buttonVerticalY += self.actionSheetButtonHeight;
                }
                [self p_updateActionButtonAppreance];
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, buttonVerticalY);
                self.buttonScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.frame), buttonVerticalY);
                if (self.cancelAction) {
                    buttonVerticalY += self.actionSheetCancelButtonSpacing;
                    self.cancelAction.actionButton.frame = CGRectMake(0, buttonVerticalY + verticalY, CGRectGetWidth(self.buttonScrollView.frame), self.actionSheetButtonHeight);
                    buttonVerticalY += CGRectGetHeight(self.cancelAction.actionButton.frame);
                }
                
            }
            
            else if (self.style == BLTAlertControllerStyleFeedAlert){
                [self updateActionButtonPositionHoriSpacing:self.feedAlertButtonHoriSpacing verticalSpacing:self.feedAlertButtonVerticalSpacing];
            }
        }
    
    //最外面的view的布局
    CGFloat contentTotalHeight = 0;
    if (self.style == BLTAlertControllerStyleAlert  || self.style == BLTAlertControllerStyleFeedAlert) {
        contentTotalHeight = CGRectGetHeight(self.headerScrollView.frame) + CGRectGetHeight(self.buttonScrollView.frame);
    }else{
        contentTotalHeight = CGRectGetHeight(self.headerScrollView.frame) + buttonVerticalY;
    }
    CGFloat screenHeight = CGRectGetHeight(self.view.bounds);
    
    //如果内容的高度大于屏幕2*3  调整
    CGFloat maxContentH = screenHeight * 2 / 3;
    if (contentTotalHeight > maxContentH) {
        screenHeight = maxContentH;
        //内容的高度不能超过弹框的一半  简单以一半处理
        CGFloat contentH = fmin(CGRectGetHeight(self.headerScrollView.frame), screenHeight / 2);
        CGFloat buttonH = fmin(CGRectGetHeight(self.buttonScrollView.frame), screenHeight / 2);
        
        if (contentH >= screenHeight / 2 && buttonH >= screenHeight / 2) {
            self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenHeight / 2);
            self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenHeight - contentH);
            self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
        }else if (contentH < screenHeight / 2){
            self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentH);
            self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenHeight - contentH);
            self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
        }else if (buttonH < screenHeight / 2){
            self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenHeight - buttonH);
            self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, buttonH);
            self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
        }
        
        contentTotalHeight = CGRectGetHeight(self.headerScrollView.frame) + CGRectGetHeight(self.buttonScrollView.frame);
        //如果是actionSheet
        if (self.style == BLTAlertControllerStyleActionSheet && self.cancelAction.actionButton) {
            self.cancelAction.actionButton.frame = CGRectSetY(self.cancelAction.actionButton.frame, CGRectGetMaxY(self.buttonScrollView.frame) + self.actionSheetCancelButtonSpacing);
            contentTotalHeight = CGRectGetMaxY(self.cancelAction.actionButton.frame);
        }
        
        
    }
    
    self.wrapView.frame = CGRectSetHeight(self.wrapView.frame, contentTotalHeight);
    if (self.style == BLTAlertControllerStyleAlert || self.style == BLTAlertControllerStyleFeedAlert) {
        self.containerView.frame = CGRectMake(CGRectGetWidth(self.view.frame) / 2 - CGRectGetWidth(self.containerView.frame) / 2, CGRectGetHeight(self.view.frame) / 2 - contentTotalHeight / 2, CGRectGetWidth(self.containerView.frame), contentTotalHeight);
    }else{
        CGFloat actionContainerViewY = CGRectGetHeight(self.view.bounds) - self.alertContentInsets.bottom - contentTotalHeight - BLT_SCREEN_BOTTOM_OFFSET;
        self.containerView.frame = CGRectMake(CGRectGetWidth(self.view.frame) / 2 - CGRectGetWidth(self.containerView.frame) / 2, actionContainerViewY, CGRectGetWidth(self.containerView.frame), contentTotalHeight);
    }
    
    if (self.rightTopCloseButton) {
        UIImage *closeImg = self.rightTopCloseButton.currentImage;
        self.rightTopCloseButton.frame = CGRectMake(CGRectGetWidth(self.headerScrollView.frame) - closeImg.size.width - 15, 15, closeImg.size.width, closeImg.size.height);
    }
    if (self.didLayoutSubviewsBlock) {
        self.didLayoutSubviewsBlock();
    }
}


/** 处理alert状态下按钮的位置 */
- (void)updateActionButtonPositionHoriSpacing:(CGFloat)horiSpacing verticalSpacing:(CGFloat)verticalSpacing{
    CGFloat buttonVerticalY = 0;
    //是不是竖直方向
    BOOL verticalDirection = YES;
    CGFloat halfWidth = (CGRectGetWidth(self.buttonScrollView.frame) - horiSpacing) / 2;
    CGFloat buttonW = CGRectGetWidth(self.buttonScrollView.frame);
    //如果是feedAlert样式  按钮位置和内容距离边框距离一样
    if (self.style == BLTAlertControllerStyleFeedAlert) {
        buttonVerticalY = self.feedAlertButtonInsets.top;
        halfWidth = (CGRectGetWidth(self.buttonScrollView.frame) - UIEdgeInsetsGetHorizontalValue(self.feedAlertButtonInsets) - horiSpacing) / 2;
        buttonW -= UIEdgeInsetsGetHorizontalValue(self.feedAlertButtonInsets);
    }
    
    if (self.alertActions.count == 2 && self.alertActionDirection == BLTAlertControllerButtonDirectionAuto) {
        BLTAlertAction *firstAction = self.alertActions.firstObject;
        BLTAlertAction *secondAction = self.alertActions.lastObject;
        CGSize firstSize = [firstAction.actionButton sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        CGSize secondSize = [secondAction.actionButton sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        //如果 两个按钮的宽度都满足就横向排列
        if (firstSize.width < halfWidth && secondSize.width < halfWidth) {
            verticalDirection = NO;
        }
    }
    
    CGFloat startX = self.style == BLTAlertControllerStyleFeedAlert ? self.feedAlertButtonInsets.left : 0;
    if (!verticalDirection) {
        BLTAlertAction *firstAction = self.alertActions.firstObject;
        BLTAlertAction *secondAction = self.alertActions.lastObject;
        firstAction.actionButton.frame = CGRectMake(startX, buttonVerticalY, halfWidth, self.alertButtonHeight);
        secondAction.actionButton.frame = CGRectMake(startX + halfWidth + horiSpacing, buttonVerticalY, halfWidth, self.alertButtonHeight);
        buttonVerticalY += self.alertButtonHeight;
    }else{
        for (int i = 0; i < self.alertActions.count; i++) {
            BLTAlertAction *alertAction = self.alertActions[i];
            alertAction.actionButton.frame = CGRectMake(startX, buttonVerticalY, buttonW, self.alertButtonHeight);
            buttonVerticalY += self.alertButtonHeight + ((i == self.alertActions.count - 1) ? 0 : verticalSpacing);
        }
    }
    if (self.style == BLTAlertControllerStyleFeedAlert) {
        buttonVerticalY += self.feedAlertButtonInsets.bottom;
    }
    [self p_updateActionButtonAppreance];
    self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, buttonVerticalY);
    self.buttonScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.frame), buttonVerticalY);
}


#pragma mark - click event
- (void)maskViewClicked{
    [self.view endEditing:YES];
    if (self.backgroundClickDismiss) {
        [self dismissWithAnimated:nil];
    }
}

- (void)alertActionDidClicked:(BLTAlertAction *)alertAction{
    if (self.autoActionClose) {
        BLT_WEAkOBJECT(weakAlertAction, alertAction)
        [self dismissWithAnimated:^{
            if (weakAlertAction.handler) {
                weakAlertAction.handler(weakAlertAction);
            }
        }];
        return;
    }
    if (alertAction.handler) {
        alertAction.handler(alertAction);
    }
}

- (void)rightTopCloseButtonClicked{
    if (self.autoActionClose) {
        BLT_WEAkOBJECT(weakSelf, self)
        [self dismissWithAnimated:^{
            if (weakSelf.rightTopCloseHandler) {
                weakSelf.rightTopCloseHandler();
            }
        }];
        return;
    }
    if (self.rightTopCloseHandler) {
        self.rightTopCloseHandler();
    }
}

#pragma mark - 添加action  customView textField
- (void)addAction:(BLTAlertAction *)action{
    if (self.cancelAction && action.style == BLTAlertActionStyleCancel) {
        NSAssert(NO, @"LBLog BLTAlertController can only have one action with a style of BLTAlertActionStyleCancel");
        return;
    }
    
    if (action.style == BLTAlertActionStyleCancel) {
        self.cancelAction = action;
        if (self.style == BLTAlertControllerStyleActionSheet) {
            [self p_updateActionSheetCancelButtonRaduis];
        }
    }
    action.delegate = self;
    [self.alertActions addObject:action];
    //actionSheet的取消按钮不滚动
    if(self.style == BLTAlertControllerStyleActionSheet && action.style == BLTAlertActionStyleCancel){
        [self.wrapView addSubview:action.actionButton];
    }else{
        [self.buttonScrollView addSubview:action.actionButton];
    }
    
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(BLTTextFieldView * _Nonnull))configurationHandler{
    if (_customView) {
        NSAssert(NO, @"LBLog has add custom view  can not add textField");
        return;
    }
    
    BLTTextFieldView *textView = [[BLTTextFieldView alloc] init];
    textView.backgroundColor = [UIColor whiteColor];
    [self.headerScrollView addSubview:textView];
    [self.alertTextFields addObject:textView];
    if (configurationHandler) {
        configurationHandler(textView);
    }
}

- (void)addCustomView:(UIView *)customView{
    if (_customView) {
        NSAssert(NO, @"LBLog has add customView, can not add another one");
        return;
    }
    if (self.alertTextFields.count > 0) {
        NSAssert(NO, @"LBLog has add textField, can not add custom View");
        return;
    }
    _customView = customView;
    [self.headerScrollView addSubview:_customView];
}

/** 给内容添加富文本的点击事件 配合alertContentAttributeString 使用*/
- (void)addContentAttributeTapActionWithStrings:(NSArray <NSString *>*)strings tapHandler:(void(^)(NSString *string, NSRange range, NSInteger index))tapHandler{
    _canTapContentAction = YES;
    self.contentLab.enabledTapEffect = NO;
    if (self.alertContentAttributeString && strings.count > 0 && tapHandler) {
        [self.contentLab yb_addAttributeTapActionWithStrings:strings tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
            tapHandler(string,range,index);
        }];
    }
}

- (void)addTitleImage:(UIImage *)titleImage{
    if (titleImage && !self.headerImageView) {
        self.headerImageView = [[UIImageView alloc] init];
        self.headerImageView.image = titleImage;
        self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.headerScrollView addSubview:self.headerImageView];
    }
}

- (void)addRightTopCloseButtonHandler:(dispatch_block_t)handler closeButtonConfig:(void (^)(UIButton *))closeButtonConfig{
    if (!self.rightTopCloseButton) {
        self.rightTopCloseButton = [[BLTUIResponseAreaButton alloc] init];
        [self.rightTopCloseButton setImage:UIImageNamedFromBLTUIKItBundle(@"right_top_close_image") forState:UIControlStateNormal];
        [self.rightTopCloseButton addTarget:self action:@selector(rightTopCloseButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        self.rightTopCloseButton.responseAreaInsets = UIEdgeInsetsMake(-15, -15, -15, -15);
        [self.headerScrollView addSubview:self.rightTopCloseButton];
        _rightTopCloseHandler = handler;
        if (self.customSensorCloseBtnBlock) {
            self.customSensorCloseBtnBlock(_rightTopCloseButton);
        }
        if (closeButtonConfig) {
            closeButtonConfig(self.rightTopCloseButton);
        }
    }else{
        NSAssert(NO, @"LBLog alertController you can not add another right close button");
    }
}

#pragma mark - 按钮排序的
//按钮排序的  防系统
- (NSArray <BLTAlertAction *>*)orderedAlertAction{
    if (self.style == BLTAlertControllerStyleAlert) {
        return self.alertActions.copy;
    }
    NSMutableArray *orderedArray = self.alertActions.mutableCopy;
    for (BLTAlertAction *alertAction in self.alertActions) {
        if (alertAction.style != BLTAlertActionStyleCancel) {
            [orderedArray addObject:alertAction];
        }
    }
    [orderedArray addObject:self.cancelAction];
    return nil;
}

#pragma mark - show  hidden
- (void)startAlertStyle{
    if (_showing) {
        return;
    }
    _showing = YES;

    if (_needsUpdateTitleStyle) {
        [self p_updateTitleStyle];
    }
    
    if (_needsUpdateContentStyle) {
        [self p_updateMessageStyle];
    }
    
    if (_needsUpdateActionButtonStyle) {
        [self p_updateActionStyle];
    }
    
    if (_needsUpdateTextFieldStyle) {
        [self p_updateTextFieldStyle];
    }

    alertControllerCount ++;
}

- (void)dismissWithAnimated:(dispatch_block_t)completion{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:completion];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    alertControllerCount --;
    _showing = NO;
}



#pragma mark - 需要更新外观 updateStyle的
- (void)p_updateTitleStyle{
    if (self.titleLab) {
        if (self.alertTitleAttributeString) {
            self.titleLab.attributedText = self.alertTitleAttributeString;
            return;
        }
        
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.alertTitle attributes:self.alertTitleAttributes];
        self.titleLab.attributedText = attributeString;
    }
}

- (void)p_updateMessageStyle{
    if (self.alertContentAttributeString) {
        self.contentLab.attributedText = self.alertContentAttributeString;
        return;
    }
    if (self.contentLab) {
//        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.alertMessage attributes:self.alertContentAttributes];
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.alertMessage];
        [attributeString addAttributes:self.alertContentAttributes range:NSMakeRange(0, self.alertMessage.length)];
        self.contentLab.attributedText = attributeString.copy;
    }
}

/** 更新内容显示的防线  两行及以下居中显示 两行以上居左显示 */
- (void)p_updateMessageAlignment{
    CGFloat messageH = CGRectGetHeight(self.contentLab.frame);
    NSInteger count = messageH / self.contentLab.font.lineHeight;
    if (self.canTapContentAction) {
        if (count > 2) {
            NSMutableParagraphStyle *style = [BLTAlertController defalutParagraphStyle];
            style.alignment = NSTextAlignmentLeft;
            NSMutableDictionary *attributes = self.alertContentAttributes.mutableCopy;
            [attributes setValue:style forKey:NSParagraphStyleAttributeName];
            self.alertContentAttributes = attributes;
            [self p_updateMessageStyle];
        }
    }else{
        if (count > 2) {
            self.contentLab.textAlignment = NSTextAlignmentLeft;
        }
    }
}

- (void)p_updateActionStyle{
    self.buttonScrollView.backgroundColor = self.alertButtonBackgroundColor;
    for (BLTAlertAction *alertAction in self.alertActions) {
        alertAction.actionButton.backgroundColor = self.alertButtonBackgroundColor;
//        alertAction.actionButton setBackgroundImage:<#(nullable UIImage *)#> forState:<#(UIControlState)#>
        NSDictionary *attributeDic = nil;
        if (alertAction.style == BLTAlertActionStyleCancel) {
            attributeDic = self.alertCancelButtonAttributes;
        }else if (alertAction.style == BLTAlertActionStyleDestructive){
            if (self.style == BLTAlertControllerStyleFeedAlert) {
                attributeDic = self.feedAlertDestrutiveButtonAttributes;
            }else{
                attributeDic = self.alertDestructiveButtonAttributes;
            }
        }else{
            if (self.style == BLTAlertControllerStyleFeedAlert) {
                attributeDic = self.feedAlertButtonAttributes;
            }else{
                attributeDic = self.alertButtonAttributes;
            }
        }
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributeDic];
        [alertAction.actionButton setAttributedTitle:attributeString forState:UIControlStateNormal];
    }
}

/** 更新action按钮的分割线位置 */
- (void)p_updateActionButtonAppreance{
    //处理feedAlert的样式
    if (self.style == BLTAlertControllerStyleFeedAlert) {
        for (BLTAlertAction *alertAction in self.alertActions) {
            if (alertAction.style == BLTAlertActionStyleDestructive) {
                [alertAction.actionButton blt_addGrandientLayerStartColor:self.feedAlertStartGradientColor endColor:self.feedAlertEndGradientColor direction:BLTGrandientLayerDirectionLeftToRight];
                alertAction.actionButton.blt_layerCornerRaduis = 3;
            }else{
                [alertAction.actionButton blt_showBorderColor:self.alertSeparatorColor cornerRaduis:3 borderWidth:0.5];
            }
        }
        return;
    }
    
    if (self.alertActions.count == 2) {
        [self.alertActions.firstObject.actionButton blt_addLineRectCorner:UIRectLineSideTop|UIRectLineSideRight lineWidth:0.5 lineColor:self.alertSeparatorColor];
        [self.alertActions.lastObject.actionButton blt_addLineRectCorner:UIRectLineSideTop lineWidth:0.5 lineColor:self.alertSeparatorColor];
    }else{
        //少了一根线
        if (self.style == BLTAlertControllerStyleAlert) {
            [self.alertActions.firstObject.actionButton blt_addLineRectCorner:UIRectLineSideTop lineWidth:0.5 lineColor:self.alertSeparatorColor];
        }
        for (BLTAlertAction *alertAction in self.alertActions) {
            if (alertAction == self.alertActions.lastObject) {
                break;
            }
            [alertAction.actionButton blt_addLineRectCorner:UIRectLineSideBottom lineWidth
                                                       :0.5 lineColor:self.alertSeparatorColor];
        }
    }
}

- (void)p_updateTextFieldStyle{
    [self.alertTextFields enumerateObjectsUsingBlock:^(BLTTextFieldView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = @{NSForegroundColorAttributeName : self.alertTextFieldTextColor, NSFontAttributeName : self.alertTextFieldFont};
        obj.textViewAttributes = dic;
    }];
}

- (void)p_updateActionSheetCancelButtonRaduis{
    if (self.cancelAction) {
        self.cancelAction.actionButton.layer.cornerRadius = self.actionSheetContentCornerRaduis;
        self.cancelAction.actionButton.clipsToBounds = YES;
    }
}

/** 主动更新按钮的样式 */
- (void)updateAlertActionStyle{
    [self p_updateActionStyle];
    [self p_updateActionButtonAppreance];
}

#pragma mark - 处理键盘的
- (void)keyboardWillShow:(NSNotification *)notification{
    if (self.style == BLTAlertControllerStyleActionSheet || self.customView) return;
    NSDictionary *info = notification.userInfo;
    NSValue *afterValue = info[UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardHeight = afterValue.CGRectValue.size.height;
    UIButton *lastBtn = self.alertActions.lastObject.actionButton;
    CGRect lastBtnToViewFrame = [lastBtn.superview convertRect:lastBtn.frame toView:self.view];
    CGFloat offsetH = BLT_DEF_SCREEN_HEIGHT - CGRectGetMaxY(lastBtnToViewFrame) - BLT_SCREEN_BOTTOM_OFFSET - keyBoardHeight;
    if (offsetH < 0) {
        offsetH += self.alertContentInsets.bottom + 10;
        [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.containerView.frame = CGRectMake(CGRectGetWidth(self.view.frame) / 2 - CGRectGetWidth(self.containerView.frame) / 2, CGRectGetHeight(self.view.frame) / 2 - CGRectGetHeight(self.containerView.frame) / 2 + offsetH, CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame));
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification{
    if (self.style == BLTAlertControllerStyleActionSheet || self.customView) return;
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.containerView.frame = CGRectMake(CGRectGetWidth(self.view.frame) / 2 - CGRectGetWidth(self.containerView.frame) / 2, CGRectGetHeight(self.view.frame) / 2 - CGRectGetHeight(self.containerView.frame) / 2, CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame));
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - textField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - set property

- (void)setBackgroundClickDismiss:(BOOL)backgroundClickDismiss{
    _backgroundClickDismiss = backgroundClickDismiss;
    self.maskView.userInteractionEnabled = backgroundClickDismiss;
}

- (void)setAlertTitle:(NSString *)alertTitle{
    _alertTitle = alertTitle;
    if (!alertTitle || alertTitle.length == 0) {
        return;
    }
    if (!self.titleLab) {
        self.titleLab = [[UILabel alloc] init];
        self.titleLab.textAlignment = NSTextAlignmentCenter;
        self.titleLab.numberOfLines = 0;
        [self.headerScrollView addSubview:self.titleLab];
        [self p_updateTitleStyle];
    }
}

- (void)setAlertMessage:(NSString *)alertMessage{
    _alertMessage = alertMessage;
    if (!alertMessage || alertMessage.length == 0) {
        return;
    }
    if (!self.contentLab) {
        self.contentLab = [[UILabel alloc] init];
        self.contentLab.numberOfLines = 0;
//        self.contentLab.textAlignment = NSTextAlignmentCenter;
        [self.headerScrollView addSubview:self.contentLab];
        [self p_updateMessageStyle];
    }
}

- (void)setAlertContentRaduis:(CGFloat)alertContentRaduis{
    _alertContentRaduis = alertContentRaduis;
    [self updateAlertContentRaduis];
}

- (void)updateAlertContentRaduis{
    self.containerView.layer.cornerRadius = self.alertContentRaduis;
    self.containerView.clipsToBounds = YES;
}

- (void)setAlertContentInsets:(UIEdgeInsets)alertContentInsets{
    _alertContentInsets = alertContentInsets;
}

- (void)setAlertContentMaxWidth:(CGFloat)alertContentMaxWidth{
    _alertContentMaxWidth = alertContentMaxWidth;
}

- (void)setAlertTitleContentSpacing:(CGFloat)alertTitleContentSpacing{
    _alertTitleContentSpacing = alertTitleContentSpacing;
}

- (void)setAlertHeaderInsets:(UIEdgeInsets)alertHeaderInsets{
    _alertHeaderInsets = alertHeaderInsets;
}

- (void)setAlertButtonAttributes:(NSDictionary<NSString *,id> *)alertButtonAttributes{
    _alertButtonAttributes = alertButtonAttributes;
    _needsUpdateActionButtonStyle = YES;
}

- (void)setAlertCancelButtonAttributes:(NSDictionary<NSString *,id> *)alertCancelButtonAttributes{
    _alertCancelButtonAttributes = alertCancelButtonAttributes;
    _needsUpdateActionButtonStyle = YES;
}

- (void)setAlertDestructiveButtonAttributes:(NSDictionary<NSString *,id> *)alertDestructiveButtonAttributes{
    _alertDestructiveButtonAttributes = alertDestructiveButtonAttributes;
    _needsUpdateActionButtonStyle = YES;
}

- (void)setAlertButtonBackgroundColor:(UIColor *)alertButtonBackgroundColor{
    _alertButtonBackgroundColor = alertButtonBackgroundColor;
    //设置按下的颜色
    _needsUpdateActionButtonStyle = YES;
}

- (void)setAlertTitleAttributes:(NSDictionary<NSString *,id> *)alertTitleAttributes{
    _alertTitleAttributes = alertTitleAttributes;
    _needsUpdateTitleStyle = YES;
}

- (void)setAlertContentAttributes:(NSDictionary<NSString *,id> *)alertContentAttributes{
    _alertContentAttributes = alertContentAttributes;
    _needsUpdateContentStyle = YES;
}

- (void)setAlertTitleAttributeString:(NSAttributedString *)alertTitleAttributeString{
    _alertTitleAttributeString = alertTitleAttributeString;
    self.titleLab.attributedText = alertTitleAttributeString;
    _needsUpdateTitleStyle = YES;
}

- (void)setAlertContentAttributeString:(NSAttributedString *)alertContentAttributeString{
    _alertContentAttributeString = alertContentAttributeString;
    self.contentLab.attributedText = alertContentAttributeString.copy;
    _needsUpdateContentStyle = YES;
}

- (void)setAlertMaskViewBackgroundColor:(UIColor *)alertMaskViewBackgroundColor{
    _alertMaskViewBackgroundColor = alertMaskViewBackgroundColor;
}

- (void)setAlertHeaderBackgroundColor:(UIColor *)alertHeaderBackgroundColor{
    _alertHeaderBackgroundColor = alertHeaderBackgroundColor;
    self.headerScrollView.backgroundColor = alertHeaderBackgroundColor;
}

- (void)setAlertSeparatorColor:(UIColor *)alertSeparatorColor{
    _alertSeparatorColor = alertSeparatorColor;
    _needsUpdateActionButtonStyle = YES;
}

#pragma mark - 设置textField样式
- (void)setAlertTextFieldFont:(UIFont *)alertTextFieldFont{
    _alertTextFieldFont = alertTextFieldFont;
    _needsUpdateTextFieldStyle = YES;
}

- (void)setAlertTextFieldTextColor:(UIColor *)alertTextFieldTextColor{
    _alertTextFieldTextColor = alertTextFieldTextColor;
    _needsUpdateTextFieldStyle = YES;
}

#pragma mark - 设置actionSheet的样式
- (void)setActionSheetContentCornerRaduis:(CGFloat)actionSheetContentCornerRaduis{
    _actionSheetContentCornerRaduis = actionSheetContentCornerRaduis;
    self.containerView.layer.cornerRadius = actionSheetContentCornerRaduis;
    self.containerView.clipsToBounds = YES;
    [self p_updateActionSheetCancelButtonRaduis];
}

- (NSArray<BLTAlertAction *> *)actions{
    return self.alertActions.copy;
}

- (BLTAlertTransitioningAnimator *)transitioningAnimator{
    if (!_transitioningAnimator) {
        _transitioningAnimator = [[BLTAlertTransitioningAnimator alloc] init];
        _transitioningAnimator.transitionDuration = [NSNumber numberWithFloat:0.3];
        _transitioningAnimator.animateStyle = BLTAlertTransitioningAnimateStylePopUp;
    }
    return _transitioningAnimator;
}

- (void)dealloc
{
    NSLog(@"LBLog %@ dealloc =================",NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (BOOL)isAnyAlertControllerExist{
    return alertControllerCount > 0;
}

@end

