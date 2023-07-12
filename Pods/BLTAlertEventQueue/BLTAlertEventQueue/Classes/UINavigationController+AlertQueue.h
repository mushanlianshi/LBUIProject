//
//  UINavigationController+AlertQueue.h
//  BLTAlertEventQueue
//
//  Created by yinxing on 2023/5/24.
//

#import <UIKit/UIKit.h>

typedef void(^BLTAlertQueueManagerPushBlock)(UIViewController * _Nullable vc);

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (AlertQueue)

/// 用于处理从alert跳转页面后，继续push导致无法调用到dismissBlock
@property (nonatomic, copy) BLTAlertQueueManagerPushBlock aqm_qushBlock;

@end

NS_ASSUME_NONNULL_END
