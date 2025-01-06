//
//  NSObject+AutoProperty.m
//  RuntimeDemo
//
//  Created by 邱学伟 on 16/9/8.
//  Copyright © 2016年 邱学伟. All rights reserved.
//

#import "NSObject+AutoProperty.h"
#import "MBProgressHUD.h"
#import <BLTUIKitProject/BLTUI.h>
#import <objc/runtime.h>

@implementation NSObject (AutoProperty)
/**
 *  自动生成属性列表
 *
 *  @param dict JSON字典/模型字典
 */
+(void)printPropertyWithDict:(NSDictionary *)dict{
    NSMutableString *allPropertyCode = [[NSMutableString alloc]init];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *oneProperty = [[NSString alloc]init];
        if ([obj isKindOfClass:[NSString class]]) {
            oneProperty = [NSString stringWithFormat:@"@property (nonatomic, copy) NSString *%@;",key];
        }else if ([obj isKindOfClass:[NSNumber class]]){
            oneProperty = [NSString stringWithFormat:@"@property (nonatomic, assign) NSInteger %@;",key];
        }else if ([obj isKindOfClass:[NSArray class]]){
            oneProperty = [NSString stringWithFormat:@"@property (nonatomic, copy) NSArray *%@;",key];
        }else if ([obj isKindOfClass:[NSDictionary class]]){
            oneProperty = [NSString stringWithFormat:@"@property (nonatomic, copy) NSDictionary *%@;",key];
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFBoolean")]){
            oneProperty = [NSString stringWithFormat:@"@property (nonatomic, assign) BOOL %@;",key];
        }
        [allPropertyCode appendFormat:@"\n%@\n",oneProperty];
    }];
    NSLog(@"%@",allPropertyCode);
}


- (void)setCustomActionBlock:(void (^)(id, int))customActionBlock{
    objc_setAssociatedObject(self, @selector(customActionBlock), customActionBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(id, int))customActionBlock{
    return objc_getAssociatedObject(self, _cmd);
}




@end


@implementation NSObject (LoadingTip)

#pragma mark - 加载框  提示框的 ============================
/** 加载视图 */
- (void)showLoadingAnimation{
    [self showLoadingAnimationInSuperView:nil];
}

- (void)showLoadingAnimationInSuperView:(UIView *)superView{
    superView = superView ? superView : [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD showHUDAddedTo:superView animated:YES];
}

/** 停止加载 */
- (void)stopLoadingAnimation{
    [self dismissLoadingAnimationInSuperView:nil];
}

- (void)dismissLoadingAnimationInSuperView:(UIView *)superView{
    superView = superView ? superView : [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideHUDForView:superView animated:YES];
}

- (void)showHintTipContent:(NSString *)tipContent{
    [self showHintTipContent:tipContent superView:nil];
}

- (void)showHintTipContent:(NSString *)tipContent superView:(UIView *)superView{
    [self showHintTipContent:tipContent afterSecond:0 superView:superView];
}

/** 提示  几秒后自动消失 */
- (void)showHintTipContent:(NSString *)tipContent afterSecond:(NSTimeInterval)afterSecond{
    [self showHintTipContent:tipContent afterSecond:afterSecond superView:nil];
}

- (void)showHintTipContent:(NSString *)tipContent afterSecond:(NSTimeInterval)afterSecond superView:(UIView *)superView{
    afterSecond = fabs(afterSecond) > 0 ? fabs(afterSecond) : 1.5;
    superView = superView ? superView : [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    if (NSStringIsExist(tipContent)) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabel.text = tipContent;
        hud.detailsLabel.font = UIFontPFFontSize(14);
        hud.detailsLabel.textColor = [UIColor whiteColor];
    }
    hud.bezelView.backgroundColor = [UIColor blackColor];
    hud.userInteractionEnabled = NO;
    [hud hideAnimated:YES afterDelay:afterSecond];
}

- (void)showHintTipWithError:(NSError *)error{
    if (error == nil || NSStringIsExist(error.localizedDescription) == false) {
        return;
    }
    //主动取消的不提示网络错误
    if (error.code == -999) return ;
    NSString *errorMsg = error.localizedDescription ?: @"网络错误";
    [self showHintTipContent:errorMsg];
}

/** 延时显示加载框的  如果请求已经回来就不在加载HUD 做快速展示时用的 */
- (void)delayShowLoadingHudAfterSeconds:(NSTimeInterval)seconds superView:(UIView *)superView{
    [self setNeedDelayShowHud:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self needDelayShowHud]) {
            [MBProgressHUD showHUDAddedTo:superView animated:NO];
        }
    });
}

- (void)dismissDelayHudSuperView:(UIView *)superView{
    [self setNeedDelayShowHud:NO];
    [MBProgressHUD hideHUDForView:superView animated:NO];
}

- (void)setNeedDelayShowHud:(BOOL)hasShowHud{
    objc_setAssociatedObject(self, @selector(needDelayShowHud), [NSNumber numberWithBool:hasShowHud], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)needDelayShowHud{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
