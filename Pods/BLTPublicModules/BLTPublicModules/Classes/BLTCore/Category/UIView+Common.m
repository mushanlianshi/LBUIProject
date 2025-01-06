//
//  UIView+Common.m
//  BlueMobiProject
//
//  Created by 朱 亮亮 on 14-4-28.
//  Copyright (c) 2014年 朱 亮亮. All rights reserved.
//

#import "UIView+Common.h"
#import <objc/runtime.h>

/** 添加点击的block属性 */
static const char *ActionHandlerTapGestureKey ;
static const char *ActionHandlerLongPressGestureKey;
static const char kAllTimeResponseKey;

@implementation UIView (Common)

- (CGFloat)cm_left
{
    return self.frame.origin.x;
}

- (CGFloat)cm_top
{
    return self.frame.origin.y;
}

- (CGFloat)cm_right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)cm_bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)cm_width
{
    return self.frame.size.width;
}

- (CGFloat)cm_height
{
    return self.frame.size.height;
}


-(CGFloat)layerCornerRaduis{
    return  self.layer.cornerRadius;
}


-(CGFloat)lb_width{
    return  self.bounds.size.width;
}

-(void)setLb_width:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame =frame;
}

-(CGFloat)lb_height{
    return self.bounds.size.height;
}

-(void)setLb_height:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}


-(CGFloat)lb_x{
    return self.frame.origin.x;
}

-(void)setLb_x:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

-(CGFloat)lb_y{
    return self.frame.origin.y;
}

-(void)setLb_y:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

-(CGFloat)lb_centerX{
    return self.center.x;
}

-(void)setLb_centerX:(CGFloat)centerX{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

-(CGFloat)lb_centerY{
    return self.center.y;
}

-(void)setLb_centerY:(CGFloat)centerY{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (void)setLb_top:(CGFloat)lb_top{
    CGRect frame = self.frame;
    frame.origin.y = lb_top;
    self.frame = frame;
}

- (CGFloat)lb_top{
    return self.frame.origin.y;
}

- (void)setLb_bottom:(CGFloat)lb_bottom{
    CGRect frame = self.frame;
    frame.origin.y = lb_bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)lb_bottom{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setLb_right:(CGFloat)lb_right{
    CGRect frame = self.frame;
    frame.origin.x = lb_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)lb_right{
    return self.frame.origin.x + self.frame.size.width;
}


-(void)setLayerCornerRaduis:(CGFloat)layerCornerRaduis{
    self.layer.cornerRadius = layerCornerRaduis;
    self.layer.masksToBounds = YES;
//    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
//    self.layer.shouldRasterize = YES;
}

-(void)showRedBorder{
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 1;
}

-(void)showBlueBorder{
    self.layer.borderColor = [UIColor blueColor].CGColor;
    self.layer.borderWidth = 1;
}


-(void)addTapBlock:(dispatch_block_t)tapBlock{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionFroTapGesture:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
    if (tapBlock) {
        objc_setAssociatedObject(self, &ActionHandlerTapGestureKey, tapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
}

-(void)handleActionFroTapGesture:(UITapGestureRecognizer *)tapGesture{
    if (tapGesture.state == UIGestureRecognizerStateRecognized) {
        dispatch_block_t block = objc_getAssociatedObject(self, &ActionHandlerTapGestureKey);
        if (block) {
            block();
        }
    }
    if ([self isAllTimeResponse]) {
        self.userInteractionEnabled = YES;
        return;
    }
    
    self.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.userInteractionEnabled = YES;
    });
}

- (void)addLongPressBlock:(dispatch_block_t)longpressBlock{
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionFroLongPressGesture:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:longPressGesture];
    if (longpressBlock) {
        objc_setAssociatedObject(self, &ActionHandlerTapGestureKey, longpressBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

-(void)handleActionFroLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture{
    if (longPressGesture.state == UIGestureRecognizerStateRecognized) {
        dispatch_block_t block = objc_getAssociatedObject(self, &ActionHandlerTapGestureKey);
        if (block) {
            block();
        }
    }
}

- (void)roundedRectWithView:(UIView *)view rectCorner:(UIRectCorner)rectCorner size:(CGSize)size num:(NSInteger)num {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:rectCorner cornerRadii:size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
    CAShapeLayer *borderLayer = [[CAShapeLayer alloc] init];
    borderLayer.lineWidth = 1;
    borderLayer.frame = view.bounds;
    borderLayer.path = maskPath.CGPath;
    
    borderLayer.strokeColor = [UIColor whiteColor].CGColor;
    borderLayer.fillColor = [UIColor whiteColor].CGColor;
    
    [view.layer addSublayer:borderLayer];
}

- (void)roundedRectWithView:(UIView *)view rectCorner:(UIRectCorner)rectCorner size:(CGSize)size{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:rectCorner cornerRadii:size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

- (void)setAllTimeResponse:(BOOL)allTimeResponse{
    objc_setAssociatedObject(self, &kAllTimeResponseKey, @(allTimeResponse), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isAllTimeResponse{
    id result = objc_getAssociatedObject(self, &kAllTimeResponseKey);
    return [result boolValue];
}


- (void)removeAllSubviews
{
	while (self.subviews.count)
    {
		UIView *child = self.subviews.lastObject;
		[child removeFromSuperview];
	}
}

/**
 *  设置部分圆角(绝对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii {
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    self.layer.masksToBounds = YES;
    self.layer.mask = shape;
}

@end
