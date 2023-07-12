//
//  BLTAlertQueueManager.h
//  Baletu
//
//  Created by 尹星 on 2019/11/5.
//  Copyright © 2019 朱 亮亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLTAlertEventQueueModel.h"

@interface BLTAlertEventQueueManager : NSObject

/// 单利
+ (instancetype)shareIntrance;

/// 自定义初始化方法
/// @param viewController 持有alertQueueManager的控制器
- (instancetype)initWithViewController:(UIViewController *)viewController;

/// 需要在队列所属控制器的viewWillAppear或viewDidAppear方法中调用的方法（必须调用）
- (void)controllerViewWillAppear;

/// 需要在队列所属控制器的viewWillDisappear方法中调用的方法（必须调用）
- (void)controllerViewWillDisappear;

/**
 group队列
 */
@property (nonatomic, strong) dispatch_group_t                          group_t;

/**
 添加alert
 */
- (void)addAlertInfo:(BLTAlertEventQueueModel *)alertInfo;

/**
 插入弹框
 */
- (void)insertAlertInfo:(BLTAlertEventQueueModel *)alertInfo;

/**
 开始弹窗
 */
- (void)startAlert;

/**
 继续弹窗（在弹窗消失的回调中需要主动调用该方法）
 */
- (void)continueAlert DEPRECATED_MSG_ATTRIBUTE("该方法已废弃，无需手动调用该方法");

/// 跳转页面，返回后继续后面弹窗
/// - Parameters:
///   - vc: 需要跳转的vc
///   - isPush: 使用push还是present
///   - animated: 动画
///   - completion: present成功回调
- (void)gotoAlertContentPage:(UIViewController *)vc
                      isPush:(BOOL)isPush
                    animated:(BOOL)animated
                  completion:(dispatch_block_t)completion;

/// 隐藏当前弹窗，并跳转页面
/// - Parameters:
///   - vc: 跳转的页面（present）
///   - animated: present 动画
///   - completion: present成功回调
- (void)hiddenCurrentAlertAndSkipPage:(UIViewController *)vc
                             animated:(BOOL)animated
                           completion:(dispatch_block_t)completion;

@end
