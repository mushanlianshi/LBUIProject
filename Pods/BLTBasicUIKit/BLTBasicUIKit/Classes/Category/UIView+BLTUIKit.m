//
//  UIView+UITool.m
//  BLTUIKit
//
//  Created by liu bin on 2020/2/26.
//  Copyright © 2020 liu bin. All rights reserved.
//

#import "UIView+BLTUIKit.h"
#import <objc/runtime.h>
static const char *kAllTimeResponseKey;
static const char *ActionHandlerTapGestureKey ;

@implementation UIView (BLTUIKit)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originSelector = @selector(layoutSubviews);
        SEL newSelector = @selector(blt_grandientLayoutSubviews);
        Method oriMethod = class_getInstanceMethod(class, originSelector);
        Method newMethod = class_getInstanceMethod(class, newSelector);
        if (newMethod) {
            BOOL isAddedMethod = class_addMethod(class, originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
            if (isAddedMethod) {
                IMP oriMethodIMP = method_getImplementation(oriMethod) ?: imp_implementationWithBlock(^(id selfObject) {});
                const char *oriMethodTypeEncoding = method_getTypeEncoding(oriMethod) ?: "v@:";
                class_replaceMethod(class, newSelector, oriMethodIMP, oriMethodTypeEncoding);
            } else {
                method_exchangeImplementations(oriMethod, newMethod);
            }
        }
    });
}

//渐变hook的方法
- (void)blt_grandientLayoutSubviews{
    [self blt_grandientLayoutSubviews];
    CAGradientLayer *grandientLayer = objc_getAssociatedObject(self, @selector(blt_addGrandientLayerStartColor:endColor:direction:needAfterLayout:));
    if (grandientLayer) {
        grandientLayer.frame = self.bounds;
    }
}

- (void)setBlt_layerCornerRaduis:(CGFloat)blt_layerCornerRaduis{
    self.layer.cornerRadius = blt_layerCornerRaduis;
    self.layer.masksToBounds = YES;
    objc_setAssociatedObject(self, @selector(blt_layerCornerRaduis), [NSNumber numberWithFloat:blt_layerCornerRaduis], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)blt_layerCornerRaduis{
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

/** 显示圆角的 */
- (void)blt_showLayerCorner:(UIRectCorner)rectCorner size:(CGSize)size lineWidth:(CGFloat)lineWidth{
    CAShapeLayer *maskLayer = objc_getAssociatedObject(self, @selector(blt_showLayerCorner:size:lineWidth:));
    if (maskLayer) {
        return;
    }
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:size];
    maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = bezierPath.CGPath;
    self.layer.mask = maskLayer;
    objc_setAssociatedObject(self, @selector(blt_showLayerCorner:size:lineWidth:), maskLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)blt_showBorderColor:(UIColor *)color{
    [self blt_showBorderColor:color cornerRaduis:0 borderWidth:1];
}

- (void)blt_showBorderColor:(UIColor *)color cornerRaduis:(CGFloat)cornerRaduis borderWidth:(CGFloat)borderWidth{
    self.layer.borderColor = color.CGColor;
    self.layer.cornerRadius = cornerRaduis;
    self.layer.borderWidth = borderWidth;
}

/** 给view添加线 */
- (void)blt_addLineRectCorner:(UIRectLineSide)rectCorner lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor{
    BOOL hasAddLine = [objc_getAssociatedObject(self, @selector(blt_addLineRectCorner:lineWidth:lineColor:)) boolValue];
    if (hasAddLine) {
        return;
    }
    CAShapeLayer *lineLayer = [[CAShapeLayer alloc] init];
    lineLayer.strokeColor = lineColor.CGColor;
    lineLayer.lineWidth = lineWidth;
    [self.layer addSublayer:lineLayer];
    
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    if (rectCorner & UIRectLineSideLeft) {
        [bezierPath moveToPoint:CGPointMake(0, 0)];
        [bezierPath addLineToPoint:CGPointMake(0, CGRectGetHeight(self.frame))];
    }
    
    if (rectCorner & UIRectLineSideTop) {
        [bezierPath moveToPoint:CGPointMake(0, 0)];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), 0)];
    }
    
    if (rectCorner & UIRectLineSideRight) {
        [bezierPath moveToPoint:CGPointMake(CGRectGetWidth(self.frame), 0)];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    }
    
    if (rectCorner & UIRectLineSideBottom) {
        [bezierPath moveToPoint:CGPointMake(0, CGRectGetHeight(self.frame))];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    }
    
    lineLayer.path = bezierPath.CGPath;
    objc_setAssociatedObject(self, @selector(blt_addLineRectCorner:lineWidth:lineColor:), @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/** 添加渐变色 */
- (void)blt_addGrandientLayerStartColor:(UIColor *)startColor endColor:(UIColor *)endColor direction:(BLTGrandientLayerDirection)direction{
    [self blt_addGrandientLayerStartColor:startColor endColor:endColor direction:direction needAfterLayout:NO];
}

- (void)blt_addGrandientLayerStartColor:(UIColor *)startColor endColor:(UIColor *)endColor direction:(BLTGrandientLayerDirection)direction needAfterLayout:(BOOL)needAfterLayout{
    CAGradientLayer *gradientLayer = nil;
    if (needAfterLayout) {
        gradientLayer = objc_getAssociatedObject(self, @selector(blt_addGrandientLayerStartColor:endColor:direction:needAfterLayout:));
    }else{
        gradientLayer = objc_getAssociatedObject(self, @selector(blt_addGrandientLayerStartColor:endColor:direction:));
    }
    
    if (gradientLayer) {
        [gradientLayer removeFromSuperlayer];
    }
    gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.frame = self.bounds;
    [gradientLayer setColors:@[(id)startColor.CGColor,(id)endColor.CGColor]];
    CGPoint endPoint = CGPointZero;
    switch (direction) {
        case BLTGrandientLayerDirectionLeftToRight:
            endPoint = CGPointMake(1.0, 0);
            break;
        case BLTGrandientLayerDirectionLeftToRightBotton:
            endPoint = CGPointMake(1.0, 1.0);
            break;
        case BLTGrandientLayerDirectionTopToBottom:
            endPoint = CGPointMake(0, 1.0);
            break;
        default:
            break;
    }
    [gradientLayer setStartPoint:CGPointZero];
    [gradientLayer setEndPoint:endPoint];
    if ([self isKindOfClass:[UILabel class]]) {
        gradientLayer.frame = self.frame;
        gradientLayer.mask = self.layer;
        [self.superview.layer addSublayer:gradientLayer];
        NSAssert(self.superview, @"LBLog label superview  connot be nil ,please add it to superview first or user BLTGradientLayer inset ");
    }else{
        [self.layer addSublayer:gradientLayer];
        [self.layer insertSublayer:gradientLayer atIndex:0];
    }
    
    if (needAfterLayout) {
        objc_setAssociatedObject(self, @selector(blt_addGrandientLayerStartColor:endColor:direction:needAfterLayout:), gradientLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }else{
        objc_setAssociatedObject(self, @selector(blt_addGrandientLayerStartColor:endColor:direction:), gradientLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (UIViewController *)blt_getCurrentControllerFromSelf{
    // 遍历响应者链。返回第一个找到视图控制器
    UIResponder *responder = self;
    while ((responder = [responder nextResponder])){
        if ([responder isKindOfClass: [UIViewController class]]){
            return (UIViewController *)responder;
        }
    }
    // 如果没有找到则返回nil
    return nil;
}

- (void)blt_removeAllSubviews
{
    while (self.subviews.count)
    {
        UIView *child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

-(void)blt_addTapBlock:(dispatch_block_t)tapBlock{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_handleActionForTapGesture:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
    if (tapBlock) {
        objc_setAssociatedObject(self, &ActionHandlerTapGestureKey, tapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
}

-(void)p_handleActionForTapGesture:(UITapGestureRecognizer *)tapGesture{
    if (tapGesture.state == UIGestureRecognizerStateRecognized) {
        dispatch_block_t block = objc_getAssociatedObject(self, &ActionHandlerTapGestureKey);
        if (block) {
            block();
        }
    }
    if ([self blt_allTimeResponse]) {
        self.userInteractionEnabled = YES;
        return;
    }
    
    self.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.userInteractionEnabled = YES;
    });
}

- (void)blt_addLongPressBlock:(dispatch_block_t)longpressBlock{
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(p_handleActionForLongPressGesture:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:longPressGesture];
    if (longpressBlock) {
        objc_setAssociatedObject(self, &ActionHandlerTapGestureKey, longpressBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

-(void)p_handleActionForLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture{
    if (longPressGesture.state == UIGestureRecognizerStateRecognized) {
        dispatch_block_t block = objc_getAssociatedObject(self, &ActionHandlerTapGestureKey);
        if (block) {
            block();
        }
    }
}

- (void)setBlt_allTimeResponse:(BOOL)blt_allTimeResponse{
    objc_setAssociatedObject(self, &kAllTimeResponseKey, @(blt_allTimeResponse), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)blt_allTimeResponse{
    id result = objc_getAssociatedObject(self, &kAllTimeResponseKey);
    return [result boolValue];
}

#pragma mark - 阴影
- (void)blt_addShadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset shadowOpacity:(CGFloat)shadowOpacity shadowRaduis:(CGFloat)shadowRadius{
    [self blt_addShadowColor:shadowColor shadowOffset:shadowOffset shadowOpacity:shadowOpacity shadowRaduis:shadowRadius cornerRaduis:0 borderWidth:0 borderColor:nil];
}

- (void)blt_addShadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset shadowOpacity:(CGFloat)shadowOpacity shadowRaduis:(CGFloat)shadowRadius cornerRaduis:(CGFloat)cornerRaduis borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor{
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowOffset = shadowOffset;
    self.layer.shadowOpacity = shadowOpacity;
    self.layer.shadowRadius = shadowRadius;
    self.layer.cornerRadius = cornerRaduis;
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = borderWidth;
}

@end



@implementation UIView (BLTFrame)

-(CGFloat)blt_width{
    return  self.bounds.size.width;
}

-(void)setBlt_width:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame =frame;
}

-(CGFloat)blt_height{
    return self.bounds.size.height;
}

-(void)setBlt_height:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}


-(CGFloat)blt_x{
    return self.frame.origin.x;
}

-(void)setBlt_x:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

-(CGFloat)blt_y{
    return self.frame.origin.y;
}

-(void)setBlt_y:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

-(CGFloat)blt_centerX{
    return self.center.x;
}

-(void)setBlt_centerX:(CGFloat)centerX{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

-(CGFloat)blt_centerY{
    return self.center.y;
}

-(void)setBlt_centerY:(CGFloat)centerY{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (void)setBlt_top:(CGFloat)lb_top{
    CGRect frame = self.frame;
    frame.origin.y = lb_top;
    self.frame = frame;
}

- (CGFloat)blt_top{
    return self.frame.origin.y;
}

- (void)setBlt_bottom:(CGFloat)lb_bottom{
    CGRect frame = self.frame;
    frame.origin.y = lb_bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)blt_bottom{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBlt_right:(CGFloat)lb_right{
    CGRect frame = self.frame;
    frame.origin.x = lb_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)blt_right{
    return self.frame.origin.x + self.frame.size.width;
}

@end







@implementation UIView (BLTInit)



+ (instancetype)blt_lineView{
    return [self blt_viewWithBackgroundColor:[UIView appearance].blt_lineColor];
}

+ (instancetype)blt_viewWithBackgroundColor:(UIColor *)color{
    UIView *view = [[self alloc] init];
    view.backgroundColor = color;
    return view;;
}

- (void)setBlt_lineColor:(UIColor *)blt_lineColor{
    objc_setAssociatedObject(self, @selector(blt_lineColor), blt_lineColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)blt_lineColor{
    return objc_getAssociatedObject(self, _cmd);
}


@end
