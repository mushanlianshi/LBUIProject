//
//  UIViewController+LLUI.h
//  Baletoo_landlord
//
//  Created by baletu on 2018/8/14.
//  Copyright © 2018年 krisc.zampono. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MBProgressHUD"

@interface UIViewController (BLTUIKit)

/** 只保留自己栈之前的VC push一个新界面 */
- (void)blt_keepBeforeSelfPushNewVC:(UIViewController *)newVC DEPRECATED_MSG_ATTRIBUTE("please use blt_keepBeforeSelfPushNewVC:animated: instead");
- (void)blt_keepBeforeSelfPushNewVC:(UIViewController *)newVC animated:(BOOL)animated;

/** 只保留栈顶和栈底的controller newVC 是需要push的VC  外面不用调用push方法*/
- (void)blt_keepFirstAndLastPushNewVC:(UIViewController *)newVC DEPRECATED_MSG_ATTRIBUTE("please use blt_keepFirstAndLastPushNewVC:animated: instead");
- (void)blt_keepFirstAndLastPushNewVC:(UIViewController *)newVC animated:(BOOL)animated;

/** 栈长只保留一个当前的controller */
- (void)blt_keepOnlyOneNewViewController:(UIViewController *)controller DEPRECATED_MSG_ATTRIBUTE("please use blt_keepOnlyOneNewViewController:animated: instead");
- (void)blt_keepOnlyOneNewViewController:(UIViewController *)controller animated:(BOOL)animated;

/** 返回到指定的在push栈中的第一个名字为controllerName的VC */
- (BOOL)blt_backToController:(NSString *)controllerName animated:(BOOL )animated;

/** pop 到指定所以的controller */
- (void)blt_popToViewControllerAtIndex:(NSInteger)index DEPRECATED_MSG_ATTRIBUTE("please use blt_popToViewControllerAtIndex:animated: instead");
- (void)blt_popToViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated;

/** pop到偏移当前栈位置的controller */
- (void)blt_popToViewControllerOffsetIndex:(NSInteger)index DEPRECATED_MSG_ATTRIBUTE("please use blt_popToViewCOntrollerOffsetIndex:animated: instead");
- (void)blt_popToViewControllerOffsetIndex:(NSInteger)index animated:(BOOL)animated;

/// 替换当前VC为新的VC
- (void)blt_replaceCurrentVCPushNewVC:(UIViewController *)newVC animated:(BOOL)animated;

@end



