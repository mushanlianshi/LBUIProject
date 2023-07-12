//
//  UIView+AlertQueue.h
//  BLTAlertEventQueue
//
//  Created by yinxing on 2023/5/19.
//

#import <UIKit/UIKit.h>

@interface UIView (AlertQueue)

@property (nonatomic, copy) dispatch_block_t aqm_cancelBlock;

@end
