//
//  BLTAlertQueueManager.m
//  Baletu
//
//  Created by 尹星 on 2019/11/5.
//  Copyright © 2019 朱 亮亮. All rights reserved.
//

#import "BLTAlertEventQueueManager.h"
#import "UIView+AlertQueue.h"
#import "UINavigationController+AlertQueue.h"
#import "UIViewController+AlertQueue.h"

@interface BLTAlertEventQueueManager ()

/// 一开始弹窗
@property (nonatomic, assign, getter=isStarting) BOOL                   starting;

/**
 活动类型弹窗
 */
@property (nonatomic, copy) NSArray <BLTAlertEventQueueModel *>         *activityAlerts;

/**
 事务类型弹窗
 */
@property (nonatomic, copy) NSArray <BLTAlertEventQueueModel *>         *workAlerts;

/**
 优先级最高的弹窗(数组内alert不分优先级，按照 先添加先弹 进行弹出)
 */
@property (nonatomic, copy) NSArray <BLTAlertEventQueueModel *>         *highestPriorityAlerts;

/// 当前弹出的alert
@property (nonatomic, strong) BLTAlertEventQueueModel                   *currentAlertModel;

/**
 暂存alert，在延迟弹窗中，如果temporaryStorageAlerty为YES，则暂存准备弹出的alert
 */
@property (nonatomic, strong) BLTAlertEventQueueModel                   *temporaryStorageAlertModel;

/// 持有alertQueueManager的控制器
@property (nonatomic, weak) UIViewController                            *viewController;

/**
 父视图即将消失。在页面的viewWillDisappear方法中设置为YES，如果此时已经执行弹出alert，因延迟调用未实时弹出，则缓存该alert，不执行弹出.(设置时，如果弹窗队列为空，则自动置为NO)
 */
@property (nonatomic, assign) BOOL                                      parentVCWillDisappear;

/**
 暂停弹窗，因部分弹窗在网络请求后才会添加到队列，如果此时页面跳转至其他页面，并开始弹窗时，应停止弹窗，待返回队列持有页面时再开始弹窗
 */
@property (nonatomic, assign, getter=isSuspendedAlert) BOOL             suspendedAlert;

/// 隐藏当前弹窗（当该弹窗点击跳转后，不能释放，在返回时需要继续显示该弹窗时，设置为YES），该属性和presentVC互斥，不要同时设置为YES
@property (nonatomic, assign, getter=isHiddenCurrentAlert) BOOL         hiddenCurrentAlert;

/**
 当点击弹窗内容需要跳转其他界面时，不需调用autoContinueAlert，并将该属性设置为YES
 */
@property (nonatomic, assign, getter=isPresentVC) BOOL                  presentVC;

/// 是否为单利初始化
@property (nonatomic, assign, getter=isIntranceCreat) BOOL              intranceCreat;

@end

@implementation BLTAlertEventQueueManager
{
    dispatch_semaphore_t _semaphore_t;
}

+ (instancetype)shareIntrance
{
    static BLTAlertEventQueueManager *intrance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        intrance = [[BLTAlertEventQueueManager alloc] init];
        intrance.intranceCreat = YES;
        // 使用单利初始化时，viewController 为 keyWindow的rootViewController
        intrance.viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        __weak typeof(intrance) weakIntrance = intrance;
        // 用于处理调用 gotoAlertContentPage 方法跳转页面时，不触发 controllerViewWillDisappear 方法
        intrance.viewController.aqm_presentBlock = ^(UIViewController *vc) {
            // 判断 vc 是否为 alert ，如果是，无需处理
            NSMutableArray <BLTAlertEventQueueModel *> *mutArr = [NSMutableArray array];
            [mutArr addObjectsFromArray:weakIntrance.highestPriorityAlerts];
            [mutArr addObjectsFromArray:weakIntrance.activityAlerts];
            [mutArr addObjectsFromArray:weakIntrance.workAlerts];
            for (BLTAlertEventQueueModel *alertModel in mutArr) {
                if (vc == alertModel.alert) {
                    return;
                }
            }
            
            [weakIntrance controllerViewWillDisappear];
            
            // 处理startAlert未开始前，进入到其他页面时的问题
            if ([vc isKindOfClass:[UINavigationController class]] && ((UINavigationController *)vc).viewControllers.count > 0) {
                for (UIViewController *vController in ((UINavigationController *)vc).viewControllers) {
                    vController.aqm_dismissBlock = ^{
                        [weakIntrance controllerViewWillAppear];
                    };
                }
                
                // 处理vc push vc时，如果直接dismiss，无法触发 controllerViewWillAppear 的问题
                ((UINavigationController *)vc).aqm_qushBlock = ^(UIViewController *vController) {
                    vController.aqm_dismissBlock = ^{
                        [weakIntrance controllerViewWillAppear];
                    };
                };
            }else {
                vc.aqm_dismissBlock = ^{
                    [weakIntrance controllerViewWillAppear];
                };
            }
        };
    });
    return intrance;
}

- (instancetype)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        self.viewController = viewController;
        __weak typeof(self) weakSelf = self;
        // 用于处理调用 gotoAlertContentPage 方法跳转页面时，不触发 controllerViewWillDisappear 方法
        self.viewController.aqm_presentBlock = ^(UIViewController *vc) {
            // 判断 vc 是否为 alert ，如果是，无需处理
            NSMutableArray <BLTAlertEventQueueModel *> *mutArr = [NSMutableArray array];
            [mutArr addObjectsFromArray:weakSelf.highestPriorityAlerts];
            [mutArr addObjectsFromArray:weakSelf.activityAlerts];
            [mutArr addObjectsFromArray:weakSelf.workAlerts];
            for (BLTAlertEventQueueModel *alertModel in mutArr) {
                if (vc == alertModel.alert) {
                    return;
                }
            }
            
            [weakSelf controllerViewWillDisappear];
            
            // 处理startAlert未开始前，进入到其他页面时的问题
            if ([vc isKindOfClass:[UINavigationController class]] && ((UINavigationController *)vc).viewControllers.count > 0) {
                for (UIViewController *vController in ((UINavigationController *)vc).viewControllers) {
                    vController.aqm_dismissBlock = ^{
                        [weakSelf controllerViewWillAppear];
                    };
                }
                
                // 处理vc push vc时，如果直接dismiss，无法触发 controllerViewWillAppear 的问题
                ((UINavigationController *)vc).aqm_qushBlock = ^(UIViewController *vController) {
                    vController.aqm_dismissBlock = ^{
                        [weakSelf controllerViewWillAppear];
                    };
                };
            }else {
                vc.aqm_dismissBlock = ^{
                    [weakSelf controllerViewWillAppear];
                };
            }
        };
    }
    return self;
}

/// 添加弹窗
- (void)addAlertInfo:(BLTAlertEventQueueModel *)alertInfo
{
    if (alertInfo) {
        [self p_addAlertHideMoniter:alertInfo];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"alertLevel" ascending:YES];
        if (alertInfo.alertPriority == BLTAlertQueuePriorityWithActivity) {
            NSMutableArray *mutArr = [NSMutableArray arrayWithArray:self.activityAlerts];
            [mutArr addObject:alertInfo];
            self.activityAlerts = [[mutArr copy] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        }else if (alertInfo.alertPriority == BLTAlertQueuePriorityWithHigh) {
            NSMutableArray *mutArr = [NSMutableArray arrayWithArray:self.highestPriorityAlerts];
            [mutArr addObject:alertInfo];
            self.highestPriorityAlerts = [[mutArr copy] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        }else { // 如果alert_type为空，则默认为workAlert
            NSMutableArray *mutArr = [NSMutableArray arrayWithArray:self.workAlerts];
            [mutArr addObject:alertInfo];
            self.workAlerts = [[mutArr copy] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        }
    }
}

/// 添加结束，开始弹窗
- (void)startAlert
{
    // 如果持有控制器不存在，
    if (!self.viewController) {
        return;
    }
    
    // 开始弹窗时，如果当前页面不是队列所在页面，则停止弹窗。
    if (self.parentVCWillDisappear) {
        self.suspendedAlert = YES;
        return;
    }
    
    // 判断是否已经执行过starAlert，不可重复执行
    if (self.starting) {
        return;
    }
    
    self.starting = YES;
    
    // 开异步线程
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        // 初始化一个信号量为0的dispatch_semaphore_t
        strongSelf->_semaphore_t = dispatch_semaphore_create(0);
        // 将活动类弹窗放到最上面
        NSMutableArray <BLTAlertEventQueueModel *> *mutArr = [NSMutableArray array];
        [mutArr addObjectsFromArray:self.highestPriorityAlerts];
        [mutArr addObjectsFromArray:self.activityAlerts];
        [mutArr addObjectsFromArray:self.workAlerts];
        if (mutArr.count == 0) {
            self.starting = NO;
            strongSelf->_semaphore_t = nil;
            return ;
        }
        for (BLTAlertEventQueueModel *obj in mutArr) {
            // 回主线程弹框
            dispatch_sync(dispatch_get_main_queue(), ^{
                // 万能延迟法，因有的alert hidden会有动画效果，导致下一个弹窗出现后，将下一个弹窗一起移除了。所以如果这个方法某个弹窗显示后马上消失，就是hidden动画效果设置时长大于0.3秒了。
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // 如果为YES，说明页面即将跳转，暂存改alert，为NO，执行alert
                    if (self.parentVCWillDisappear) {
                        self.temporaryStorageAlertModel = obj;
                    }else {
                        // 弹出alert
                        [self p_alertWithModel:obj];
                    }
                });
            });
            // 信号量-1
            dispatch_semaphore_wait(strongSelf->_semaphore_t, DISPATCH_TIME_FOREVER);
            // 弹完最后一个框后，置空所有
            if ([mutArr indexOfObject:obj] == mutArr.count - 1) {
                self.highestPriorityAlerts = @[];
                self.activityAlerts = @[];
                self.workAlerts = @[];
                self.starting = NO;
                strongSelf->_semaphore_t = nil;
            }
        }
    });
}

/// 插入弹窗
- (void)insertAlertInfo:(BLTAlertEventQueueModel *)alertInfo
{
    if (alertInfo) {
        [self p_addAlertHideMoniter:alertInfo];
        // 在回到对应页面时，设置为NO
        self.parentVCWillDisappear = NO;
        [self p_alertWithModel:alertInfo];
    }
}

- (void)continueAlert
{
    
}

- (void)gotoAlertContentPage:(UIViewController *)vc
                      isPush:(BOOL)isPush
                    animated:(BOOL)animated
                  completion:(dispatch_block_t)completion
{
    self.presentVC = YES;
    self.currentAlertModel.alert = nil;
    
    // 处理present时，页面vc.modalPresentationStyle != UIModalPresentationFullScreen时，关闭页面无法触发manager持有者的viewWillAppear
    __weak typeof(self) weakSelf = self;
    if (!isPush) {
        if ([vc isKindOfClass:[UINavigationController class]] && ((UINavigationController *)vc).viewControllers.count > 0) {
            for (UIViewController *vController in ((UINavigationController *)vc).viewControllers) {
                vController.aqm_dismissBlock = ^{
                    [weakSelf controllerViewWillAppear];
                };
            }
            
            // 处理vc push vc时，如果直接dismiss，无法触发 controllerViewWillAppear 的问题
            ((UINavigationController *)vc).aqm_qushBlock = ^(UIViewController *vController) {
                vController.aqm_dismissBlock = ^{
                    [weakSelf controllerViewWillAppear];
                };
            };
        }else {
            vc.aqm_dismissBlock = ^{
                [weakSelf controllerViewWillAppear];
            };
        }
        
        vc.aqm_presentBlock = ^(UIViewController *vc) {
            [weakSelf controllerViewWillDisappear];
        };
        
        [self.viewController presentViewController:vc
                                          animated:animated
                                        completion:completion];
    }else {
        [self.viewController.navigationController pushViewController:vc
                                                            animated:animated];
    }
}

- (void)hiddenCurrentAlertAndSkipPage:(UIViewController *)vc
                             animated:(BOOL)animated
                           completion:(dispatch_block_t)completion
{
    self.hiddenCurrentAlert = YES;
    
    // 处理present时，页面vc.modalPresentationStyle != UIModalPresentationFullScreen时，关闭页面无法触发manager持有者的viewWillAppear
    __weak typeof(self) weakSelf = self;
    if ([vc isKindOfClass:[UINavigationController class]] && ((UINavigationController *)vc).viewControllers.count > 0) {
        for (UIViewController *vController in ((UINavigationController *)vc).viewControllers) {
            vController.aqm_dismissBlock = ^{
                [weakSelf controllerViewWillAppear];
            };
        }
        
        // 处理vc push vc时，如果直接dismiss，无法触发 controllerViewWillAppear 的问题
        ((UINavigationController *)vc).aqm_qushBlock = ^(UIViewController *vController) {
            vController.aqm_dismissBlock = ^{
                [weakSelf controllerViewWillAppear];
            };
        };
    }else {
        vc.aqm_dismissBlock = ^{
            [weakSelf controllerViewWillAppear];
        };
    }
    
    vc.aqm_presentBlock = ^(UIViewController *vc) {
        [weakSelf controllerViewWillDisappear];
    };
    
    if ([self.currentAlertModel.alert isKindOfClass:[UIView class]]) {
        ((UIView *)self.currentAlertModel.alert).hidden = self.hiddenCurrentAlert;
        [self.viewController presentViewController:vc
                                          animated:animated
                                        completion:completion];
    }else if ([self.currentAlertModel.alert isKindOfClass:[UIViewController class]]) { // 直接使用 alert 去 present vc，无需隐藏alert
        [((UIViewController *)self.currentAlertModel.alert) presentViewController:vc
                                                                         animated:animated
                                                                       completion:completion];
    }
}

#pragma mark - 必须调用方法
- (void)controllerViewWillAppear
{
    // 弹窗队列管理
    if (self.currentAlertModel && self.isHiddenCurrentAlert) { // 当前的弹窗存在，并且isHiddenCurrentAlert为YES时，返回后显示当前弹窗
        self.parentVCWillDisappear = NO;
        self.hiddenCurrentAlert = NO;
        if ([self.currentAlertModel.alert isKindOfClass:[UIView class]]) {
            ((UIView *)self.currentAlertModel.alert).hidden = self.hiddenCurrentAlert;
        }
    }else if (self.isPresentVC) { // 点击弹窗，跳转页面，返回之后执行
        self.parentVCWillDisappear = NO;
        self.presentVC = NO;
        [self autoContinueAlert];
    }else if (self.isSuspendedAlert && self.parentVCWillDisappear) { // 在网络请求结束之前，跳转页面，返回之后执行
        self.parentVCWillDisappear = NO;
        self.suspendedAlert = NO;
        [self startAlert];
    }else if (self.parentVCWillDisappear) { // 在延迟弹框期间，跳转页面，返回之后执行
        self.parentVCWillDisappear = NO;
        [self autoContinueAlert];
    }
}

- (void)controllerViewWillDisappear
{
    self.parentVCWillDisappear = YES;
}

#pragma mark - --------------------------- 必须调用方法 end ---------------------

#pragma mark - 私有方法
- (void)p_alertWithModel:(BLTAlertEventQueueModel *)obj
{
    // 定义了alert方法，则调用alert方法弹框。
    if (obj.alertSelString) {
        [self p_callMethodAlertWithModel:obj];
    }else {
        // 未定义alert方法，如果aler为view，则直接继续下一个弹窗。如果是VC则调用presentVC
        if ([obj.alert isKindOfClass:[UIView class]]) {
            [self autoContinueAlert];
        }else if ([obj.alert isKindOfClass:[UIViewController class]]) {
            [self.viewController presentViewController:obj.alert animated:YES completion:nil];
            if (obj.alertSuccessBlock) {
                obj.alertSuccessBlock();
            }
        }
    }
    self.currentAlertModel = obj;
}

- (void)p_callMethodAlertWithModel:(BLTAlertEventQueueModel *)obj
{
    if (!obj.alert) { return; }
    SEL selector = NSSelectorFromString(obj.alertSelString);
    IMP imp = [obj.alert methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(obj.alert, selector);
    
    if (obj.alertSuccessBlock) {
        obj.alertSuccessBlock();
    }
}

/// 给alert添加关闭监测
/// - Parameter alertInfo: 弹窗model
- (void)p_addAlertHideMoniter:(BLTAlertEventQueueModel *)alertInfo
{
    // 检测UIViewController的弹窗是否消失了
    if ([alertInfo.alert isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)alertInfo.alert;
        __weak typeof(self) weakSelf = self;
        __weak typeof(vc) weakVC = vc;
        vc.aqm_cancelBlock = ^{
            // 外部已经调用过"autoContinueAlert"，此时已经被释放 || 调用了"hiddenCurrentAlert"方法，不用再调用"autoContinueAlert" || 调用了"gotoAlertContentPage"方法，不用再调用"autoContinueAlert"
            if (!weakVC || weakSelf.isHiddenCurrentAlert || weakSelf.isPresentVC) {
                return;
            }
            
            // 自动调用"autoContinueAlert"
            [weakSelf autoContinueAlert];
        };
    }else if ([alertInfo.alert isKindOfClass:[UIView class]]) {
        UIView *alertV = (UIView *)alertInfo.alert;
        __weak typeof(self) weakSelf = self;
        __weak typeof(alertV) weakAlertV = alertV;
        alertV.aqm_cancelBlock = ^{
            // 外部已经调用过"autoContinueAlert"，此时已经被释放 || 调用了"hiddenCurrentAlert"方法，不用再调用"autoContinueAlert" || 调用了"gotoAlertContentPage"方法，不用再调用"autoContinueAlert"
            if (!weakAlertV || weakSelf.isHiddenCurrentAlert || weakSelf.isPresentVC) {
                return;
            }
            
            // 自动调用"autoContinueAlert"
            [weakSelf autoContinueAlert];
        };
    }
}

/// 继续弹窗（在上一个弹窗消失的回调中需要手动调用该方法）
- (void)autoContinueAlert
{
    if (!self.isStarting || (self.highestPriorityAlerts.count == 0 && self.activityAlerts.count == 0 && self.workAlerts.count == 0 && !self.temporaryStorageAlertModel)) {
        return;
    }
    
    // 存在暂存alert,则先弹暂存alert
    if (self.temporaryStorageAlertModel) {
        // 在继续弹框时，如果存在暂存alert，优先弹出暂存alert
        [self p_alertWithModel:self.temporaryStorageAlertModel];
        self.temporaryStorageAlertModel = nil;
        return;
    }
    
    // 继续弹出下一个alert时，释放之前的alert
    self.currentAlertModel.alert = nil;
    
    // 继续弹窗
    self.suspendedAlert = NO;
    if (_semaphore_t) {
        dispatch_semaphore_signal(_semaphore_t);
    }
}

- (void)p_changeTransitionViewIsHiddent:(BOOL)isHidden
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window) {
        NSMutableArray *array = [NSMutableArray array];
        for (UIView *subView in window.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UITransitionView")] && [[[subView valueForKey:@"_delegate"] valueForKey:@"_presentedViewController"] isKindOfClass:[self.currentAlertModel.alert class]]) {
                [array addObject:subView];
            }
        }

        if (array.count > 0) {
            UIView *transitionView = array.lastObject;
            transitionView.hidden = isHidden;
        }
    }
}
#pragma mark - --------------------------- 私有方法 end ---------------------

#pragma mark - 懒加载
- (dispatch_group_t)group_t
{
    if (!_group_t) {
        _group_t = dispatch_group_create();
    }
    return _group_t;
}

- (NSArray<BLTAlertEventQueueModel *> *)activityAlerts
{
    if (!_activityAlerts) {
        _activityAlerts = @[];
    }
    return _activityAlerts;
}

- (NSArray<BLTAlertEventQueueModel *> *)workAlerts
{
    if (!_workAlerts) {
        _workAlerts = @[];
    }
    return _workAlerts;
}

- (NSArray<BLTAlertEventQueueModel *> *)highestPriorityAlerts
{
    if (!_highestPriorityAlerts) {
        _highestPriorityAlerts = @[];
    }
    return _highestPriorityAlerts;
}

#pragma mark - ------------------------------------------------------------------------------------

@end
