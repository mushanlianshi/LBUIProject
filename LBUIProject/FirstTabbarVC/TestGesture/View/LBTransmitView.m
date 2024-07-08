//
//  LBTransmitView.m
//  LBUIProject
//
//  Created by liu bin on 2021/7/27.
//

#import "LBTransmitView.h"
#import "Masonry.h"

@implementation LBTransmitView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviewA];
        [self addSubviewB];
//        [self addTarget:self action:@selector(clicked) forControlEvents:UIControlEventTouchUpInside];
        
//      view   - viewA
//                      -subviewA
//                      -subviewAsubviewA
//
//             - viewB
//                      -subviewB
//                      -subviewBsubviewB
//        UIResponder响应触摸的原来：
//如果触摸在viewA中  也会先传递给ViewB  因为B在A后面  在反向遍历那个能响应的时候B先接受到事件  B可以接受事件(hidden = false,userInterable = YES,alpha > 0.01,如果B不可以接受事件，B的hitTest 直接返回nil, ) 会走到pointInside方法判断是不是在B的范围内，不在hitTest返回null  接着给下一个A新的轮回
//如果点击在viewB中  先传递给viewB 判断B可以响应 就不会在传递给A了
//如果点击的是subviewB 会先传递给subviewBsuviewB中  因为subviewBsubviewB在subviewB后面  suvivewBsubviewB不在点击范围内  不能响应事件 在传递给subviewB
//
//
//        如果想让子视图响应事件和父视图同时响应事件  子视图touchBegan处理完之后 在调用super touchBegan传递给父视图  注意不要是UIControl的子控件  UIControl子控件比较特殊
    }
    return self;
}

- (void)clicked{
    NSLog(@"LBLog 1111 clicked ");
}

- (void)addSubviewA{
    LBTransmitSubView *viewA = [[LBTransmitSubView alloc] initWithName:@"viewA" backgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.7]];
    [self addSubview:viewA];
    
    LBTransmitSubView *subviewA = [[LBTransmitSubView alloc] initWithName:@"subviewA" backgroundColor:[UIColor lightGrayColor]];
    [viewA addSubview:subviewA];
    
    LBTransmitSubView *subviewASubviewA = [[LBTransmitSubView alloc] initWithName:@"subviewASubviewA" backgroundColor:[UIColor redColor]];
    
    [viewA addSubview:subviewASubviewA];
    [viewA mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(40);
        make.top.mas_offset(40);
        make.right.mas_offset(-40);
        make.height.mas_equalTo(200);
    }];
    
    [subviewA mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(viewA);
        make.width.height.mas_equalTo(80);
    }];
    
    [subviewASubviewA mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(viewA.mas_bottom).mas_offset(-40);
        make.centerX.mas_equalTo(subviewASubviewA);
        make.width.height.mas_equalTo(80);
    }];
}


- (void)addSubviewB{
    LBTransmitSubView *viewB = [[LBTransmitSubView alloc] initWithName:@"viewB" backgroundColor:[[UIColor orangeColor] colorWithAlphaComponent:0.7]];
    [self addSubview:viewB];
    
    LBTransmitSubView *subviewB = [[LBTransmitSubView alloc] initWithName:@"subviewB" backgroundColor:[UIColor lightGrayColor]];
    [viewB addSubview:subviewB];
    
    LBTransmitSubView *subviewBSubviewB = [[LBTransmitSubView alloc] initWithName:@"subviewBSubviewB" backgroundColor:[UIColor redColor]];
    
    [viewB addSubview:subviewBSubviewB];
    [viewB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(40);
        make.top.mas_offset(200);
        make.right.mas_offset(-40);
        make.height.mas_equalTo(360);
    }];
    
    [subviewB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(viewB).mas_offset(30);
        make.centerX.mas_equalTo(viewB);
        make.width.height.mas_equalTo(80);
    }];
    
    [subviewBSubviewB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(subviewB.mas_bottom).mas_offset(40);
        make.centerX.mas_equalTo(viewB);
        make.width.height.mas_equalTo(80);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self clicked];
    [super touchesBegan:touches withEvent:event];
    NSLog(@"LBLog touch began 11111");
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    NSLog(@"LBLog touch ended 111111");
}


- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"LBLog touch canceled 11111 ");

}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    LBTransmitSubView *view = (LBTransmitSubView *)[super hitTest:point withEvent:event];
//    if ([view isKindOfClass:[LBTransmitSubView class]]) {
//        NSLog(@"LBLog hitTest 1111 %@",view.name);
//    }
//    return view;
//}

@end





@interface LBTransmitSubView ()

@end

@implementation LBTransmitSubView

- (instancetype)initWithName:(NSString *)name backgroundColor:(UIColor *)backgroudColor{
    self = [super init];
    if (self) {
        self.name = name;
        self.backgroundColor = backgroudColor;
//        [self addTarget:self action:@selector(clicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)clicked{
    NSLog(@"LBLog %@ clicked ",self.name);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self clicked];
    [super touchesBegan:touches withEvent:event];
    NSLog(@"LBLog touch began %@",self.name);
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
//    NSLog(@"LBLog touch ended %@",self.name);
}


- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
//    NSLog(@"LBLog touch canceled %@",self.name);

}

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
//
//    BOOL result = [super pointInside:point withEvent:event];
//    NSLog(@"LBLog pointInside %@ %@",self.name, @(result));
//    return result;
//}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    
////    hitTest的伪实现
////    1.如果不可以交互 直接返回nil
//    if(self.userInteractionEnabled == false || self.hidden == YES || self.alpha < 0.01){
//        return nil;
//    }
////    2.如果可以交互，判断点击返回是否在自己响应范围内,如果不在自己范围内  返回nil
//    if ([self pointInside:point withEvent:event] == false) {
//        return nil;
//    }
////    3.可以交互 也在自己响应范围内,反向遍历，找到子控件的最佳响应者
//    int count = (int)self.subviews.count - 1;
//    for (int i = count; i > 0; i--) {
//        UIView *subview = self.subviews[i];
////        把点击转换到子视图的范围内的点上
//        CGPoint subviewPoint = [self convertPoint:point toView:subview];
////        寻找子视图的最佳响应者，就是hitTest递归
//        UIView *hitTestView = [subview hitTest:subviewPoint withEvent:event];
////        如果找到最佳响应者 返回
//        if (hitTestView) {
//            return hitTestView;
//        }
//    }
//    NSLog(@"LBLog hiTestView %@",self);
//    return self;
    
    LBTransmitSubView *view = (LBTransmitSubView *)[super hitTest:point withEvent:event];
//    NSLog(@"LBLog hitTest %@ %@",self.name,view.name);
    return view;
}

@end
