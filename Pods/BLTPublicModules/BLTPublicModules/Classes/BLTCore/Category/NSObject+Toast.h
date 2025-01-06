//
//  NSObject+Toast.h
//  BLTPublicModules
//
//  Created by zhaojh on 2022/4/12.
//

#import <Foundation/Foundation.h>

@interface NSObject (Toast)

#pragma mark - 加载框 提示框的
/** 加载框视图 */
- (void)showLoadingAnimation;
- (void)showLoadingAnimationInSuperView:(UIView *)superView;
/** 停止加载框 */
- (void)stopLoadingAnimation;
- (void)dismissLoadingAnimationInSuperView:(UIView *)superView;

- (void)showHintTipContent:(NSString *)tipContent;
- (void)showHintTipContent:(NSString *)tipContent superView:(UIView *)superView;
/** 提示  几秒后自动消失 */
- (void)showHintTipContent:(NSString *)tipContent afterSecond:(NSTimeInterval)afterSecond;
- (void)showHintTipContent:(NSString *)tipContent afterSecond:(NSTimeInterval)afterSecond superView:(UIView *)superView;

/** 延时显示加载框的  如果请求已经回来就不在加载HUD 做快速展示时用的 */
- (void)delayShowLoadingHudAfterSeconds:(NSTimeInterval)seconds;

- (void)dismissDelayHud;

@end

