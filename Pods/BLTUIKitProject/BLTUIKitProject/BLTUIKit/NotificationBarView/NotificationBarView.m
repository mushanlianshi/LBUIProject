//
//  NotificationBarView.m
//  Baletu
//
//  Created by wangwenbo on 2020/2/19.
//  Copyright © 2020 朱 亮亮. All rights reserved.
//

#import "NotificationBarView.h"
#import "ZScrollLabel.h"
@interface NotificationBarView()
@property(nonatomic,strong)NotifcationBarStyle * barStyle;

@property(nonatomic,strong)UIView * contentView;
@property(nonatomic,strong)CAGradientLayer *gradientLayer;
@property(nonatomic,strong)UIImageView * barBackGroundImageView;
@property(nonatomic,strong)UIView * touchView;
// 右侧 处理事件的按钮
@property(nonatomic,strong)UIButton * handleButton;
// 按钮渐变色图层
@property(nonatomic,strong)CAGradientLayer *handleBtnGradientLayer;
// 点击 移除通知栏的按钮
@property(nonatomic,strong)UIButton * removeButton;
// icon
@property(nonatomic,strong)UIImageView * iconImageView;
// 内容 label
@property(nonatomic,strong)ZScrollLabel * contentLabel;
//icon width
@property(nonatomic,assign)CGFloat iconWidth;
//icon  height
@property(nonatomic,assign)CGFloat iconHeight;
// 内容框 左边距
@property(nonatomic,assign)CGFloat contentLeftEdge;
// touchview 的总宽度
@property(nonatomic,assign)CGFloat touchViewWidth;
// handleBtn 的宽度
@property(nonatomic,assign)CGFloat handleBtnWidth;

//@property(nonatomic,assign)id  showContent;
@end
@implementation NotificationBarView

// 处理事件按钮的 大小
static const CGFloat handleBtnHeight = 25;
// 移除事件按钮的 大小
static const CGFloat removeBtnWidth = 30;
static const CGFloat removeBtnHeight = 30;
// icon 的左边距
static const CGFloat iconLeftEdge = 15;
// 控件右边距 的左边距
static const CGFloat iconRightEdge = 5;
//各个元素直接的距离(icon - label - btn -btn )
static const CGFloat childUIEdge = 10;
// 计算高度的时候 计算出的高度 额外添加的高度
static const CGFloat calculteEdgHeight = 10;

#define MYBUNDLE_NAME @ "BLTUIKitBundle.bundle"

#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]

#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]


-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        // 默认的 barstyle
        self.barStyle = [[NotifcationBarStyle alloc] init];
    }
    return self;
}
-(instancetype)initWithBarStyle:(NotifcationBarStyle *)barStyle{
    if (self == [super init]) {
        self.barStyle = barStyle;
    }
    return self;
}

-(instancetype)initWithShowContent:(NSString *)showContent barType:(NotificationBarViewType)barType {
    if (self == [super init]) {
        if (showContent) {
            [self setDefaultBarWithShowContent:showContent barType:barType];
        }
    }
    return self;
}

-(instancetype)initWithAttributeShowContent:(NSMutableAttributedString *)attributeShowContent barType:(NotificationBarViewType)barType {
    if (self == [super init]) {
        if (attributeShowContent) {
            [self setDefaultBarWithShowContent:attributeShowContent barType:barType];
        }
    }
    return self;
}

#pragma mark 设置默认的几种 bar
-(void)setDefaultBarWithShowContent:(id)showContent barType:(NotificationBarViewType)barType{
    NotifcationBarStyle * barStyle= [[NotifcationBarStyle alloc] init];
    switch (barType) {
        case NotificationBarViewTipNoticeType:
        {
            // 公告类型
            barStyle.contentFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
            barStyle.contentColor = [UIColor colorWithRed:239/255.0 green:122/255.0 blue:37/255.0 alpha:1.0];
            barStyle.barBackGroundColor = [UIColor colorWithRed:255/255.0 green:251/255.0 blue:232/255.0 alpha:1.0];
            barStyle.notificationContentStyle = NotificationContentScrollStyle;
            self.barStyle = barStyle;
            UIImage *image=[self fillImageWithImageResourcePath:@"notification_bar_notice"];
            [self showWithIconImage:image showContent:showContent handleBtnTitle:nil removeButtonImage:[self fillImageWithImageResourcePath:@"notification_bar_close"]];
            
        }
            break;
        case NotificationBarViewTipNoticeHandleType:
        {
            //可操作公告类型
            barStyle.contentFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
            barStyle.contentColor = [UIColor colorWithRed:239/255.0 green:122/255.0 blue:37/255.0 alpha:1.0];
            barStyle.barBackGroundColor = [UIColor colorWithRed:255/255.0 green:251/255.0 blue:232/255.0 alpha:1.0];
            self.barStyle = barStyle;
            
            UIImage *image=[self fillImageWithImageResourcePath:@"notification_bar_close"];
            [self showWithIconImage:nil showContent:showContent handleBtnTitle:@"开启" removeButtonImage:image];
        }
            break;
        case NotificationBarViewTipNoticeNewsType:
        {
            //提示消息 类型 (点击可查看)
            barStyle.contentFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
            barStyle.contentColor = [UIColor colorWithRed:239/255.0 green:122/255.0 blue:37/255.0 alpha:1.0];
            barStyle.barBackGroundColor = [UIColor colorWithRed:255/255.0 green:251/255.0 blue:232/255.0 alpha:1.0];
            barStyle.rightIsRemove = NO;
            self.barStyle = barStyle;
            NSString *iconImg_path = @"notification_bar_news";
            NSString *rightImg_path =@"notification_bar_enter";
            
            
            [self showWithIconImage:[self fillImageWithImageResourcePath:iconImg_path] showContent:showContent handleBtnTitle:nil removeButtonImage:[self fillImageWithImageResourcePath:rightImg_path]];
        }
            break;
        case NotificationBarViewWarningSingleType:
        {
            //普通警告类型
            barStyle.contentFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
            barStyle.contentColor = [UIColor colorWithRed:238/255.0 green:57/255.0 blue:67/255.0 alpha:1.0];
            barStyle.barBackGroundColor = [UIColor colorWithRed:254/255.0 green:238/255.0 blue:237/255.0 alpha:1.0];
            self.barStyle = barStyle;
            NSString *iconImg_path =@"notification_bar_warning";
            [self showWithIconImage:[self fillImageWithImageResourcePath:iconImg_path] showContent:showContent handleBtnTitle:nil removeButtonImage:nil];
        }
            break;
        case NotificationBarViewWarningIllegalType:
        {
            //违规警告
            barStyle.contentFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
            barStyle.contentColor = [UIColor colorWithRed:238/255.0 green:57/255.0 blue:67/255.0 alpha:1.0];
            barStyle.barBackGroundColor = [UIColor colorWithRed:254/255.0 green:238/255.0 blue:237/255.0 alpha:1.0];
            self.barStyle = barStyle;
            
            NSString *img_path =@"notification_bar_illegal";
            UIImage *image=[self fillImageWithImageResourcePath:img_path];
            [self showWithIconImage:image showContent:showContent handleBtnTitle:nil removeButtonImage:nil];
        }
            break;
        case NotificationBarViewActivityContentType:
        {
            // 仅展示 活动内容 的类型
            barStyle.contentFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
            barStyle.contentColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
            barStyle.barBackGroundColor = [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1.0];
            barStyle.textAlignment = NSTextAlignmentCenter;
            self.barStyle = barStyle;
            [self showWithIconImage:nil showContent:showContent handleBtnTitle:nil removeButtonImage:nil];
        }
            break;
            
        default:
            break;
    }
    
}
#pragma mark 根据设备 返回 二倍图/三倍图
-(UIImage *)fillImageWithImageResourcePath:(NSString *)imageResourceName{
    return [UIImage imageNamed:imageResourceName inBundle:MYBUNDLE compatibleWithTraitCollection:nil];
}
#pragma mark 普通文本
//  icon  showContent handleBtn  removeBtn
-(void)showWithIconImage:(UIImage * __nullable)iconImage showContent:(NSString *)showContent handleBtnTitle:(NSString *__nullable)handleBtnTitle removeButtonImage:(UIImage * __nullable)rightImage{
    
    [self calculteUIWithIconImage:iconImage showContent:showContent handleBtnTitleOrImage:handleBtnTitle removeButtonImage:rightImage];
    
}

-(CGFloat)showWithIconImage:(UIImage * __nullable)iconImage showContent:(NSString *)showContent handleBtnTitle:(NSString *__nullable)handleBtnTitle removeButtonImage:(UIImage * __nullable)rightImage withTotalWidth:(CGFloat)totalWidth{
    
   CGFloat width = [self calculteUIWithIconImage:iconImage showContent:showContent handleBtnTitleOrImage:handleBtnTitle removeButtonImage:rightImage];
    // 计算 自适应的高度 如果传0 进来  默认使用m屏幕宽度 计算
  return  [self calculteHeigtOfContentLabelWithContent:showContent totalWidth:totalWidth == 0 ? [UIScreen mainScreen].bounds.size.width : totalWidth otherUIWidth:width];
    
    
    
}



#pragma mark 富文本
//  icon  showContent handleBtn  removeBtn
-(void)showWithIconImage:(UIImage * __nullable)iconImage ShowAttributeContent:(NSMutableAttributedString *)attributeContent handleBtnTitle:(NSString *__nullable)handleBtnTitle removeButtonImage:(UIImage * __nullable)rightImage{
    [self calculteUIWithIconImage:iconImage showContent:attributeContent handleBtnTitleOrImage:handleBtnTitle removeButtonImage:rightImage];
}

-(CGFloat)showWithIconImage:(UIImage * __nullable)iconImage attributeShowContent:(NSMutableAttributedString *)attributeShowContent handleBtnTitle:(NSString *__nullable)handleBtnTitle removeButtonImage:(UIImage * __nullable)rightImage withTotalWidth:(CGFloat)totalWidth{
    
    CGFloat width = [self calculteUIWithIconImage:iconImage showContent:attributeShowContent handleBtnTitleOrImage:handleBtnTitle removeButtonImage:rightImage];
    // 计算 自适应的高度 如果传0 进来  默认使用m屏幕宽度 计算
    return [self calculteHeigtOfContentLabelWithContent:attributeShowContent totalWidth:totalWidth == 0 ? [UIScreen mainScreen].bounds.size.width : totalWidth otherUIWidth:width];
    
}

#pragma mark privateMethod
// 计算自适应高度
-(CGFloat)calculteHeigtOfContentLabelWithContent:(id)showContent totalWidth:(CGFloat)totalWidth otherUIWidth:(CGFloat)otherUIWidth{
    UILabel * sizeLabel = [[UILabel alloc] init];
    
// 影响 高度 的几个因素 1  是否多行 2 字体大小 3 行间距 字间距 4 attribute
    if (self.barStyle.notificationContentStyle == NotificationContentMutilLineStyle) {
        sizeLabel.numberOfLines = 0;
    }
    sizeLabel.font = self.barStyle.contentFont;
    sizeLabel.attributedText = self.contentLabel.attributeText;
    sizeLabel.frame = CGRectMake(_contentLeftEdge, 0, totalWidth - otherUIWidth, self.frame.size.height);
    [sizeLabel sizeToFit];
    
    CGFloat calculteContentHeight = sizeLabel.frame.size.height + calculteEdgHeight;
    
    return calculteContentHeight;
}

// 添加 元素 并设置 style  显示元素内容
-(CGFloat)calculteUIWithIconImage:(UIImage * __nullable)iconImage showContent:(id)showContent handleBtnTitleOrImage:(id __nullable)handleBtnTitleOrImage removeButtonImage:(UIImage * __nullable)rightImage
{
    // 把视图全部添加
    [self setOriginValue];
    [self setContentViewStyle];
    // 计算 空间的left 边距  width 用来设置约束条件  并展示元素内容
    [self calculateIconSizeWithIconImage:iconImage];
    [self calculatecontentLabelSizeWithShowContent:showContent];
    [self calculateHandleBtnSizeWithTitleOrImage:handleBtnTitleOrImage];
    [self calculateRemoveBtnSizeWithImage:rightImage];
 // 返回的是除了 文字内容之外 其他区域所占用的 宽度
    [self layoutSubviews];
    return _contentLeftEdge + _touchViewWidth + iconRightEdge + childUIEdge;
}

-(void)setOriginValue{
    _iconWidth = 0;
    _iconHeight = 0;
    _contentLeftEdge = iconLeftEdge;
    _touchViewWidth = 0;
    _handleBtnWidth = 0;
}
// 计算 icon 的 width  height  leftEdge
-(void)calculateIconSizeWithIconImage:( UIImage * _Nullable )iconImage{
    if ([iconImage isKindOfClass:[UIImage class]]) {
        _iconWidth = iconImage.size.width > 30 ? 30 : iconImage.size.width;
        _iconHeight = iconImage.size.height > 30 ? 30 : iconImage.size.height;
        _contentLeftEdge = iconLeftEdge;
        _contentLeftEdge += _iconWidth;// icon 的width
        _contentLeftEdge += childUIEdge;// label 和 icon 直接的距离
        self.iconImageView.hidden = NO;
        self.iconImageView.image = iconImage;
    }else{
        _contentLeftEdge = iconLeftEdge;
        _iconWidth = 0;
        _iconHeight = 0;
        self.iconImageView.hidden = YES;
    }
}
// 计算 contentLabel 的 width  height  leftEdge  展示 内容
-(void)calculatecontentLabelSizeWithShowContent:(id)showContent{
    // 设置风格
    [self setContentLabelStyle];
// 添加 行间距 字间距 然后 赋值 attributeText
    [self setTextSpaceAndLineSpace:showContent];

}
#pragma mark 设置 行间距 字间距 并 展示内容  不管传入 NSString 还是 NSMutableAttributeString 都会执行该方法 (最终以 富文本的形式展示)
-(void)setTextSpaceAndLineSpace:(id)showContent{
    //把传入的 文本内容 转换成 富文本
    NSMutableAttributedString *attributedString ;
    if ([showContent isKindOfClass:[NSString class]]) {
        NSString * text = (NSString *) showContent;
        attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    }else if ([showContent isKindOfClass:[NSMutableAttributedString class]]){
        attributedString = (NSMutableAttributedString *)showContent;
    }
    //设置行间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:self.barStyle.textAlignment];
    [paragraphStyle setLineSpacing:self.barStyle.contentLineSpace];
    NSRange range = [attributedString.string rangeOfString:attributedString.string];
    [attributedString addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:range];
    // 设置字间距
    [attributedString addAttributes:@{NSKernAttributeName : @(self.barStyle.contentTextSpace)} range:range];
    // 设置换行mode
    self.contentLabel.attributeText = attributedString;
    // 富文本显示的时候 breakModel 会被改变 所以在设置完富文本之后 重新设置 breakMode
    self.contentLabel.lineBreakMode = self.barStyle.lineBreakMode;
    
    
}
#pragma mark  计算 handleBtn 的 width  height  leftEdge
-(void)calculateHandleBtnSizeWithTitleOrImage:(id __nullable)titleOrImage{
    
    if ([titleOrImage isKindOfClass:[UIImage class]]) {
        UIImage * image = (UIImage *)titleOrImage;
        if (image) {
            self.handleButton.hidden = NO;
            _handleBtnWidth = 50;
            _touchViewWidth+=_handleBtnWidth;
            [self.handleButton setImage:image forState:UIControlStateNormal];
        }
    }else if ([titleOrImage isKindOfClass:[NSString class]]){
        NSString * title = (NSString *)titleOrImage;
        if (title && ![[title stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            self.handleButton.hidden = NO;
            CGSize size = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 25) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :self.barStyle.handleBtnFont} context:nil].size;
            _handleBtnWidth = size.width + 25;
            _touchViewWidth += _handleBtnWidth;
            [self.handleButton setTitle:title forState:UIControlStateNormal];
        }
    }else{
        self.handleButton.hidden = YES;
    }
    // 设置 handleBtn 的style
    [self setHandleBtnStyle];
}

// 计算 removeBtn 的 width  height  leftEdge
-(void)calculateRemoveBtnSizeWithImage:(UIImage * _Nullable )image{
   
    if ([image isKindOfClass:[UIImage class]]) {
        
        self.removeButton.hidden = NO;
        _touchViewWidth += removeBtnWidth;
        [self.removeButton setImage:image forState:UIControlStateNormal];
        
        if (self.barStyle.autoDismiss) {
            
            [self performSelector:@selector(autoDismiss) withObject:nil afterDelay:self.barStyle.defaultShowTime];
        }
        
    }else{
        self.removeButton.hidden = YES;
    }
    
    
}
#pragma mark  设置 contentView 的style
-(void)setContentViewStyle{
    
    // 添加渐变色()
    if ((self.barStyle.gradientLayerOriginColor && self.barStyle.gradientLayerEndColor) || self.barStyle.contentBackgroundGradient.colors) {
        [self addGradientLayer];
    }else{
        self.contentView.backgroundColor = self.barStyle.barBackGroundColor;
    }
    self.contentView.layer.cornerRadius = self.barStyle.barCornerRadius;
    self.contentView.layer.masksToBounds = YES;
    if (self.barStyle.barBackGroundImage && [self.barStyle.barBackGroundImage isKindOfClass:[UIImage class]]) {
        self.barBackGroundImageView.image = self.barStyle.barBackGroundImage;
    }
    UITapGestureRecognizer * barTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(barTapClick)];
    [self.contentView addGestureRecognizer:barTapGesture];
}
#pragma mark  设置 contentLabel 的style
-(void)setContentLabelStyle{
    self.contentLabel.font = self.barStyle.contentFont;
    self.contentLabel.textColor = self.barStyle.contentColor;
    switch (self.barStyle.notificationContentStyle) {
        case NotificationContentSingleLineStyle:
        {
            // 单行显示
            self.contentLabel.numberOfLines = 1;
            self.contentLabel.autoBeginScroll = NO;
            self.barStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        }
            break;
        case NotificationContentMutilLineStyle:
        {
            //多行显示
            self.contentLabel.numberOfLines = 0;
            self.contentLabel.autoBeginScroll = NO;
        }
            break;
        case NotificationContentScrollStyle:
        {
            // 滚动显示
            self.contentLabel.numberOfLines = 1;
            self.contentLabel.autoBeginScroll = YES;
        }
            break;
            
        default:
            break;
    }
    
    self.contentLabel.labelAlignment = self.barStyle.textAlignment;
}

#pragma mark 设置 handleBtn 的style
-(void)setHandleBtnStyle{
    [self.handleButton setTitleColor:self.barStyle.handleBtnTitleColor forState:UIControlStateNormal];
    self.handleButton.titleLabel.font = self.barStyle.handleBtnFont;
    self.handleButton.layer.cornerRadius = self.barStyle.handleBtnCornerRadius;
    self.handleButton.backgroundColor = self.barStyle.handleBtnBackGroundColor;
    self.handleButton.layer.borderColor = self.barStyle.handleBtnBorderColor.CGColor;
    self.handleButton.layer.borderWidth = self.barStyle.handleBtnBorderWidth;
}
#pragma mark 约束条件
-(void)layoutSubviews{
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (self.barStyle.barBackGroundImage) {
        self.barBackGroundImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    
    self.iconImageView.frame = CGRectMake(iconLeftEdge, self.frame.size.height/2.0 - _iconHeight/2, _iconWidth, _iconHeight);
    self.contentLabel.frame = CGRectMake(_contentLeftEdge, 0, self.frame.size.width - childUIEdge - _touchViewWidth - _contentLeftEdge - iconRightEdge, self.frame.size.height);
    self.touchView.frame = CGRectMake(self.frame.size.width - _touchViewWidth - childUIEdge, 0, _touchViewWidth + childUIEdge, self.frame.size.height);
    
    if (UIEdgeInsetsEqualToEdgeInsets(self.barStyle.handleBtnEdgeInsets, UIEdgeInsetsZero)) {
        self.handleButton.frame = CGRectMake(0, self.touchView.frame.size.height/2 - handleBtnHeight/2, _handleBtnWidth, handleBtnHeight);
    }else {
        self.handleButton.frame = CGRectMake(self.touchView.frame.size.width - _handleBtnWidth - self.barStyle.handleBtnEdgeInsets.right, self.barStyle.handleBtnEdgeInsets.top, _handleBtnWidth, self.touchView.frame.size.height - self.barStyle.handleBtnEdgeInsets.top - self.barStyle.handleBtnEdgeInsets.bottom);
    }
    self.removeButton.frame = CGRectMake(self.touchView.frame.size.width - removeBtnWidth, self.touchView.frame.size.height/2 - removeBtnHeight/2, removeBtnWidth, removeBtnHeight);
    self.gradientLayer.frame = self.contentView.bounds;
    if (self.handleButton.frame.size.width > 0) {
        if (!_handleBtnGradientLayer) {
            [self addHandleBtnGradientLayer];
        }else {
            self.handleBtnGradientLayer.frame = self.handleButton.bounds;
        }
    }
}

#pragma mark  点击事件
-(void)barTapClick{
    if (self.barTouchBlock) {
        self.barTouchBlock();
    }
}

-(void)handleClick{
    if (self.handleBlock) {
        self.handleBlock();
    }
}

// 移除视图
-(void)removeClick{
    if (self.barStyle.rightIsRemove) {
        // 如果 最右侧的按钮 是移除功能
        [self removeFromSuperview];
    }
    if (self.rightBlock) {
        self.rightBlock();
    }
}
#pragma mark 自动移除
-(void)autoDismiss{
    [self removeFromSuperview];
    if (self.autoDismissBlock) {
        self.autoDismissBlock();
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    if (self.customUIAppearanceBlock) {
        self.customUIAppearanceBlock(self.contentView, self.touchView, self.handleButton, self.removeButton, self.iconImageView);
    }
}

#pragma mark 添加背景渐变色
-(void)addGradientLayer{
//    CAGradientLayer *gradientLayer =  [CAGradientLayer layer];
    self.gradientLayer.frame = self.bounds;
    if (self.barStyle.contentBackgroundGradient.colors && self.barStyle.contentBackgroundGradient.colors.count) {
        NSMutableArray *colors = [[NSMutableArray alloc] init];
        for (UIColor *color in self.barStyle.contentBackgroundGradient.colors) {
            [colors addObject:(id)color.CGColor];
        }
        [self.gradientLayer setColors:colors.copy];
    }
    else {
        UIColor *color1 = self.barStyle.gradientLayerOriginColor;
        UIColor *color2 = self.barStyle.gradientLayerEndColor;
        
        [self.gradientLayer setColors:[NSArray arrayWithObjects:
                                  (id)color1.CGColor,
                                  (id)color2.CGColor,nil]];
    }
    [self.gradientLayer setStartPoint:self.barStyle.contentBackgroundGradient.startPoint];
    [self.gradientLayer setEndPoint:self.barStyle.contentBackgroundGradient.endPoint];
    [self.gradientLayer setLocations:self.barStyle.contentBackgroundGradient.locations];
    
    [self.contentView.layer insertSublayer:self.gradientLayer atIndex:0];
    
}

#pragma mark - 添加按钮渐变色
- (void)addHandleBtnGradientLayer
{
    if (self.barStyle.handleBtnBackgroundGradient.colors && self.barStyle.handleBtnBackgroundGradient.colors.count) {
        self.handleBtnGradientLayer.frame = self.handleButton.bounds;
        NSMutableArray *colors = [[NSMutableArray alloc] init];
        for (UIColor *color in self.barStyle.handleBtnBackgroundGradient.colors) {
            [colors addObject:(id)color.CGColor];
        }
        [self.handleBtnGradientLayer setColors:colors.copy];
        [self.handleBtnGradientLayer setStartPoint:self.barStyle.handleBtnBackgroundGradient.startPoint];
        [self.handleBtnGradientLayer setEndPoint:self.barStyle.handleBtnBackgroundGradient.endPoint];
        [self.handleBtnGradientLayer setLocations:self.barStyle.handleBtnBackgroundGradient.locations];
        if (self.barStyle.handleBtnCornerRadius > 0) {
            self.handleBtnGradientLayer.cornerRadius = self.barStyle.handleBtnCornerRadius;
            self.handleBtnGradientLayer.masksToBounds = YES;
        }
        self.handleBtnGradientLayer.borderColor = self.barStyle.handleBtnBorderColor.CGColor;
        self.handleBtnGradientLayer.borderWidth = self.barStyle.handleBtnBorderWidth;
        
        [self.handleButton.layer insertSublayer:self.handleBtnGradientLayer atIndex:0];
    }
}

#pragma mark 懒加载
-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
    }
    return _contentView;
}
-(UIImageView *)barBackGroundImageView{
    if (!_barBackGroundImageView) {
        _barBackGroundImageView = [[UIImageView alloc] init];
        _barBackGroundImageView.userInteractionEnabled = YES;
        [self.contentView insertSubview:_barBackGroundImageView atIndex:0];
    }
    return _barBackGroundImageView;
}
-(UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImageView];
    }
    return _iconImageView;
}
-(ZScrollLabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[ZScrollLabel alloc] init];
        _contentLabel.textColor = [UIColor colorWithRed:239/255.0 green:122/255.0 blue:37/255.0 alpha:1.0];//(0xEF7A25);
        _contentLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        [self.contentView addSubview:_contentLabel];
    }
    
    return _contentLabel;
}
-(UIView *)touchView{
    if (!_touchView) {
        _touchView = [[UIView alloc] init];
        [self.contentView addSubview:_touchView];
    }
    return _touchView;
}
-(UIButton *)handleButton{
    if (!_handleButton) {
        _handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_handleButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_handleButton addTarget:self action:@selector(handleClick) forControlEvents:UIControlEventTouchUpInside];
        [self.touchView addSubview:_handleButton];
    }
    return _handleButton;
}

-(UIButton *)removeButton{
    if (!_removeButton) {
        _removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_removeButton addTarget:self action:@selector(removeClick) forControlEvents:UIControlEventTouchUpInside];
        [self.touchView addSubview:_removeButton];
    }
    return _removeButton;
}

-(CAGradientLayer *)gradientLayer{
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
    }
    return _gradientLayer;
}

- (CAGradientLayer *)handleBtnGradientLayer
{
    if (!_handleBtnGradientLayer) {
        _handleBtnGradientLayer = [CAGradientLayer layer];
    }
    return _handleBtnGradientLayer;
}

@end
