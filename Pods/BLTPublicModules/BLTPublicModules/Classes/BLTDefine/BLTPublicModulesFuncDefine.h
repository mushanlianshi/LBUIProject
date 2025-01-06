//
//  BLTPublicMoudlesDefine.h
//  Pods
//
//  Created by zhaojh on 2022/4/11.
//

#ifndef BLTPublicModulesFuncDefine_h
#define BLTPublicModulesFuncDefine_h

#import <UIKit/UIKit.h>

CG_INLINE UIViewController* GetCurrentVCFrom(UIViewController* rootVC, BOOL isRoot){

    @try {
        UIViewController *currentVC;
        if ([rootVC presentedViewController]) {
            // 视图是被presented出来的
            rootVC = GetCurrentVCFrom(rootVC.presentedViewController, NO);
        }
        if ([rootVC isKindOfClass:[UITabBarController class]]) {
            // 根视图为UITabBarController
            currentVC = GetCurrentVCFrom([(UITabBarController *)rootVC selectedViewController], NO);
        } else if ([rootVC isKindOfClass:[UINavigationController class]]){
            // 根视图为UINavigationController
            currentVC = GetCurrentVCFrom([(UINavigationController *)rootVC visibleViewController], NO);
        } else {
            // 根视图为非导航类
            if ([rootVC respondsToSelector:NSSelectorFromString(@"contentViewController")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                UIViewController *tempViewController = [rootVC performSelector:NSSelectorFromString(@"contentViewController")];
#pragma clang diagnostic pop
                if (tempViewController) {
                    currentVC = GetCurrentVCFrom(tempViewController, NO);
                }
            } else {
                if (rootVC.childViewControllers && rootVC.childViewControllers.count == 1 && isRoot) {
                    currentVC = GetCurrentVCFrom(rootVC.childViewControllers[0], NO);
                }
                else {
                    currentVC = rootVC;
                }
            }
        }
        
        return currentVC;
    } @catch (NSException *exception) {
        
    }
}

CG_INLINE UIViewController* CurrentViewController(void){

    __block UIViewController *currentVC = nil;
    if ([NSThread isMainThread]) {
        @try {
            UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            if (rootViewController != nil) {
                currentVC = GetCurrentVCFrom(rootViewController, YES);
            }
        } @catch (NSException *exception) {

        }
        return currentVC;
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            @try {
                UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
                if (rootViewController != nil) {
                    currentVC = GetCurrentVCFrom(rootViewController, YES);
                }
            } @catch (NSException *exception) {

            }
        });
        return currentVC;
    }
}



#endif
