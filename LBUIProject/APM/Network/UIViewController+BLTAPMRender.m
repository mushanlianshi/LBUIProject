//
//  UIViewController+BLTAPMRender.m
//  chugefang
//
//  Created by liu bin on 2021/3/23.
//  Copyright © 2021 baletu123. All rights reserved.
//

#import "UIViewController+BLTAPMRender.h"
#import <objc/runtime.h>

@interface UIViewController ()

@property (nonatomic, strong) NSMutableArray *timeArray;

@end

@implementation UIViewController (BLTAPMRender)

//+ (void)initialize{
//    NSLog(@"LBLog UIViewController  initialize====");
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//
////        swizzleInstanceMethod([self class], @selector(viewDidLayoutSubviews), @selector(blt_apm_viewDidLayoutSubviews));
//    });
//}

- (void)blt_apm_viewDidLayoutSubviews{
    [self blt_apm_viewDidLayoutSubviews];
    [self.timeArray addObject:@(CFAbsoluteTimeGetCurrent())];
//    DEF_DEBUG(@"LBLog blt_apm_viewDidLayoutSubviews %@ render %@",NSStringFromClass([self class]),self.timeArray);
}

- (void)setTimeArray:(NSMutableArray *)timeArray{
    objc_setAssociatedObject(self, @selector(timeArray), timeArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)timeArray{
    NSMutableArray *array = objc_getAssociatedObject(self, _cmd);
    if (array == nil) {
        array = @[].mutableCopy;
        self.timeArray = array;
    }
    return array;
}


@end
