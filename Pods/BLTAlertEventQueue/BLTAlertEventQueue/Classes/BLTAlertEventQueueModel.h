//
//  BLTAlertEventQueueModel.h
//  Baletu
//
//  Created by 尹星 on 2019/11/5.
//  Copyright © 2019 朱 亮亮. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 弹窗优先级，业务弹窗优先级最低，依次越来越高，优先级低的后弹出
typedef NS_ENUM(NSInteger, BLTAlertQueuePriority) {
    BLTAlertQueuePriorityWithBusiness = 0,       // 业务类弹窗
    BLTAlertQueuePriorityWithActivity,           // 活动类弹窗
    BLTAlertQueuePriorityWithHigh                // 优先级最高弹窗
};

@interface BLTAlertEventQueueModel : NSObject

/**
 弹窗优先级
 */
@property (nonatomic, assign) BLTAlertQueuePriority  alertPriority;

/// 弹窗等级，同类型弹窗如果存在先后顺序的话，alertLevel越小，等级越高，越先展示(默认为INT_MAX)
@property (nonatomic, assign) NSUInteger             alertLevel;

/**
 alert
 */
@property (nonatomic, strong) id                     alert;

/**
 如果alert继承自view，alert使用该方法弹出
 */
@property (nonatomic, strong) NSString               *alertSelString;

/// 弹窗成功的回调
@property (nonatomic, copy) dispatch_block_t alertSuccessBlock;

@end
