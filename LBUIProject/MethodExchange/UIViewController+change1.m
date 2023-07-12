//
//  UIViewController+change1.m
//  LBUIProject
//
//  Created by liu bin on 2021/10/21.
//

#import "UIViewController+change1.h"
#import <objc/runtime.h>
//方法交换
// A     Aimp     第一次交换       A   A1imp         第二次交换   A   A2imp
// A1    A1imp                   A1  Amp                      A1  Aimp
// A2    A2imp                   A2  A2imp                    A2  A1imp
@implementation UIViewController (change1)

+ (void)load{
    Method originalMethod = class_getInstanceMethod(self, @selector(viewWillAppear:));
    Method nowMethod = class_getInstanceMethod(self, @selector(A1_viewWillAppear:));
    method_exchangeImplementations(originalMethod, nowMethod);
}

- (void)A1_viewWillAppear:(BOOL)animated{
//    NSLog(@"LBLog A1 viewwillappear before");
    [self A1_viewWillAppear:animated];
//    NSLog(@"LBLog A1 viewwillappear after");
}

@end




@implementation UIViewController (change2)

+ (void)load{
    Method originalMethod = class_getInstanceMethod(self, @selector(viewWillAppear:));
    Method nowMethod = class_getInstanceMethod(self, @selector(A2_viewWillAppear:));
    method_exchangeImplementations(originalMethod, nowMethod);
}

- (void)A2_viewWillAppear:(BOOL)animated{
//    NSLog(@"LBLog A2 viewwillappear before");
    [self A2_viewWillAppear:animated];
//    NSLog(@"LBLog A2 viewwillappear after");
}

@end
