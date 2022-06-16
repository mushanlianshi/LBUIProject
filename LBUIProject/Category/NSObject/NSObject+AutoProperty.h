//
//  NSObject+AutoProperty.h
//  RuntimeDemo
//
//  Created by 邱学伟 on 16/9/8.
//  Copyright © 2016年 邱学伟. All rights reserved.
//  自动生成属性列表

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (AutoProperty)
/**
 *  自动生成属性列表
 *
 *  @param dict JSON字典/模型字典
 */
+(void)printPropertyWithDict:(NSDictionary *)dict;

#pragma mark -- 扩展事件传递block
/**事件外传递block*/
@property (nonatomic, copy) void (^customActionBlock)(id obj, NSInteger actionType);

@end


/** 方便开发放到这分类的  最好不要这么做 */
@interface NSObject (LoadingTip)

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

- (void)showHintTipWithError:(NSError *)error;

/** 延时显示加载框的  如果请求已经回来就不在加载HUD 做快速展示时用的 */
- (void)delayShowLoadingHudAfterSeconds:(NSTimeInterval)seconds;

- (void)dismissDelayHud;

@end
