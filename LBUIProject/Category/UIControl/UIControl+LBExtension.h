//
//  UIControl+LBExtension.h
//  LBUIProject
//
//  Created by liu bin on 2022/6/21.
//

#import <UIKit/UIKit.h>

//防止按钮多次点击的情况
//1.给button添加个延时器，响应后延时器时间内设置不可以交互，
//2.hook button的sendAction event方法  判断event的touch的点击次数，大于1 不在调用系统的sendAction阻断事件的分发
@interface UIControl (LBExtension)

//防止多次点击
@property (nonatomic, assign) bool lb_preventRepeatTouchUpInside;


- (void)addTouchUpInsideBlock:(dispatch_block_t)handlerBlock;

@end

