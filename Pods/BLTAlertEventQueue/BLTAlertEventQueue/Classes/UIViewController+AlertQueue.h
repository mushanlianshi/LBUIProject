//
//  UIViewController+AlertQueue.h
//  BLTAlertEventQueue
//
//  Created by yinxing on 2023/5/19.
//

#import <UIKit/UIKit.h>

typedef void(^BLTAlertQueueManagerBlock)(UIViewController *vc);

@interface UIViewController (AlertQueue)

/// 弹窗属性
@property (nonatomic, copy) dispatch_block_t aqm_cancelBlock;

/// 跳转页面属性
@property (nonatomic, copy) dispatch_block_t aqm_dismissBlock;

/// alertManager所属页面属性
@property (nonatomic, copy) BLTAlertQueueManagerBlock aqm_presentBlock;

@end
