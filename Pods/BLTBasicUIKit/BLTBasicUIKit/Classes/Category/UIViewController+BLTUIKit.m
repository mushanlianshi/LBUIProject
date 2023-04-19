//
//  UIViewController+LLUUI.m
//  Baletoo_landlord
//
//  Created by baletu on 2018/8/14.
//  Copyright © 2018年 krisc.zampono. All rights reserved.
//

#import "UIViewController+BLTUIKit.h"
#import <objc/message.h>

@implementation UIViewController (BLTUIKit)

/** 只保留栈顶和栈底的controller */
- (void)blt_keepFirstAndLastPushNewVC:(UIViewController *)newVC{
    [self blt_keepFirstAndLastPushNewVC:newVC animated:true];
}


- (void)blt_keepFirstAndLastPushNewVC:(UIViewController *)newVC animated:(BOOL)animated{
    if (!newVC) {
        return;
    }
    if (!self.navigationController || !self.navigationController.viewControllers.count) {
        return;
    }
    if (!(self.navigationController.viewControllers.count >1)) {
        [self.navigationController pushViewController:newVC animated:YES];
        return;
    }
    NSMutableArray *vcArray = [[NSMutableArray alloc] initWithCapacity:self.navigationController.viewControllers.count];
    [vcArray addObject:self.navigationController.viewControllers.firstObject];
    [vcArray addObject:newVC];
    [self.navigationController setViewControllers:vcArray.copy animated:animated];
}



/** 只保留自己栈之前的VC push一个新界面 */
- (void)blt_keepBeforeSelfPushNewVC:(UIViewController *)newVC{
    [self blt_keepBeforeSelfPushNewVC:newVC animated:true];
}

- (void)blt_keepBeforeSelfPushNewVC:(UIViewController *)newVC animated:(BOOL)animated{
    if (!newVC) {
        return;
    }
    NSMutableArray *vcArray = @[].mutableCopy;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[self class]]) {
            *stop = YES;
        }else{
            [vcArray addObject:obj];
        }
    }];
    [vcArray addObject:newVC];
    [self.navigationController setViewControllers:vcArray.copy animated:animated];
}



/** 栈里只保留一个当前的controller */
- (void)blt_keepOnlyOneNewViewController:(UIViewController *)controller{
    [self blt_keepOnlyOneNewViewController:controller animated:true];
}

- (void)blt_keepOnlyOneNewViewController:(UIViewController *)controller animated:(BOOL)animated{
    if (!self.navigationController || !self.navigationController.viewControllers.count) {
        return;
    }
    if (!(self.navigationController.viewControllers.count >1)) {
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    NSMutableArray *vcArray = self.navigationController.viewControllers.mutableCopy;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[controller class]]) {
            [vcArray removeObject:obj];
        }
    }];
    [vcArray addObject:controller];
    [self.navigationController setViewControllers:vcArray.copy animated:animated];
}





-(BOOL)blt_backToController:(NSString *)controllerName animated:(BOOL)animaed{
    if (self.navigationController) {
        NSArray *controllers = self.navigationController.viewControllers;
        NSArray *result = [controllers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [evaluatedObject isKindOfClass:NSClassFromString(controllerName)];
        }]];
        if (result.count > 0) {
            [self.navigationController popToViewController:result[0] animated:YES];
            return YES;
        }
    }
    
    return NO;
}

/** pop 到指定所以的controller */
- (void)blt_popToViewControllerAtIndex:(NSInteger)index{
    [self blt_popToViewControllerAtIndex:index animated:true];
}

- (void)blt_popToViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated{
    if (self.navigationController.viewControllers.count > index) {
        NSMutableArray *tmpArray = @[].mutableCopy;
        [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < index) {
                [tmpArray addObject:obj];
            }
        }];
        [self.navigationController setViewControllers:tmpArray animated:animated];
    }
}


/** pop到偏移当前栈位置的controller */
- (void)blt_popToViewControllerOffsetIndex:(NSInteger)index{
    [self blt_popToViewControllerOffsetIndex:index animated:true];
}

- (void)blt_popToViewControllerOffsetIndex:(NSInteger)index animated:(BOOL)animated{
    NSInteger vcCount = self.navigationController.viewControllers.count;
    if (vcCount > index) {
        [self blt_popToViewControllerAtIndex:vcCount - index animated:animated];
    }else{
        [self.navigationController popToRootViewControllerAnimated:animated];
    }
}

/// 替换当前VC为新的VC
- (void)blt_replaceCurrentVCPushNewVC:(UIViewController *)newVC animated:(BOOL)animated
{
    if (!newVC) {
        return;
    }
    NSMutableArray *vcArray = @[].mutableCopy;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[self class]]) {
            [vcArray addObject:newVC];
        }else{
            [vcArray addObject:obj];
        }
    }];
    [self.navigationController setViewControllers:vcArray.copy animated:animated];
}

@end





