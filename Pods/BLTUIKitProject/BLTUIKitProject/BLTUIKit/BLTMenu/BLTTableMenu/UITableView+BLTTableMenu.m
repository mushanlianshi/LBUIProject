//
//  UITableView+BLTTableMenu.m
//  BLTUIKitProject_Example
//
//  Created by Baletoo on 2020/12/2.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import <objc/runtime.h>

@implementation UITableView (BLTTableMenu)

- (void)setSelectedRow:(NSInteger)selectedRow
{
    objc_setAssociatedObject(self, @selector(selectedRow), @(selectedRow), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)selectedRow
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setColumn:(NSInteger)column
{
    objc_setAssociatedObject(self, @selector(column), @(column), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)column
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setOnLoad:(BOOL)onLoad
{
    objc_setAssociatedObject(self, @selector(onLoad), @(onLoad), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)onLoad
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
