//
//  UIButton+LBInit.m
//  nhExample
//
//  Created by liubin on 17/3/28.
//  Copyright © 2017年 liubin. All rights reserved.
//

#import "UIButton+BLTUIKit.h"
#import <objc/message.h>
#import "UIView+BLTUIKit.h"

static NSString *kNoHightlightKey;

static NSString *kButtonCustomType;

@implementation UIButton (BLTUIKit)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originSelector = @selector(layoutSubviews);
        SEL newSelector = @selector(blt_layoutSubviews);
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


- (void)blt_layoutSubviews{
    [self blt_layoutSubviews];
//    NSLog(@"LBLog blt_layoutSubviews ============");
    CAGradientLayer *grandientLayer = objc_getAssociatedObject(self, @selector(blt_addGrandientLayerStartColor:endColor:direction:needAfterLayout:));
    if (grandientLayer) {
//        [UIView performWithoutAnimation:^{
//            grandientLayer.frame = self.bounds;
//        }];
        
//        消除layer的隐式动画
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        grandientLayer.frame = self.bounds;
        [CATransaction commit];
    }
}

/** 展示文字的按钮 */
+ (instancetype)blt_buttonWithTitle:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor target:(id)target selector:(SEL)selector{
    return [self blt_buttonWithFrame:CGRectZero image:nil title:title font:font titleColor:titleColor target:target selector:selector];
}
/** 展示图片的按钮 */
+ (instancetype)blt_buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector{
    return [self blt_buttonWithFrame:CGRectZero image:image title:nil font:nil titleColor:nil target:target selector:selector];
}
/** 展示图片 文字的按钮 */
+ (instancetype)blt_buttonWithFrame:(CGRect)frame image:(UIImage *)image title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor target:(id)target selector:(SEL)selector{
    UIButton *button = [[self alloc] initWithFrame:frame];
    if (image) {
        [button setImage:image forState:UIControlStateNormal];
    }
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:titleColor forState:UIControlStateNormal];
        button.titleLabel.font = font;
    }
    if (target) {
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    return button;
}


//把图片的颜色渲染成新的颜色  针对纯色图片   例如：箭头 小纯色icon等
- (void)blt_renderImageWithColor:(UIColor *)color{
    NSAssert(self.imageView.image != nil, @"LBLog image can not be nil, please set image first");
    if (self.imageView.image == nil) {
        return;
    }
    UIImage *image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setImage:image forState:UIControlStateNormal];
    self.tintColor = color;
}

- (void)setBlt_noHighlight:(BOOL)blt_noHighlight{
    objc_setAssociatedObject(self, &kNoHightlightKey, @(blt_noHighlight), OBJC_ASSOCIATION_ASSIGN);
    if (blt_noHighlight) {
        [self addTarget:self action:@selector(preventHightlight:) forControlEvents:UIControlEventAllTouchEvents];
    }else{
        [self removeTarget:self action:@selector(preventHightlight:) forControlEvents:UIControlEventAllTouchEvents];
    }
}

- (BOOL)blt_noHighlight{
    id result = objc_getAssociatedObject(self, &kNoHightlightKey);
    return [result boolValue];
}

- (void)preventHightlight:(UIButton *)button{
    button.highlighted = NO;
}

@end
