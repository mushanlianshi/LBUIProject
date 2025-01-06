//
//  NSObject+Toast.m
//  BLTPublicModules
//
//  Created by zhaojh on 2022/4/12.
//

#import "NSObject+Toast.h"
#import "MBProgressHUD.h"
#import "BLTPublicModulesDefine.h"
#import "objc/runtime.h"

@implementation NSObject (Toast)

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
    if (SafeStringExist(tipContent)) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabel.text = tipContent;
        hud.detailsLabel.font = PFFontSize(14);
        hud.detailsLabel.textColor = [UIColor whiteColor];
    }
    hud.bezelView.backgroundColor = [UIColor blackColor];
    hud.userInteractionEnabled = NO;
    [hud hideAnimated:YES afterDelay:afterSecond];
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
