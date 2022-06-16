//
//  UITableView+BLTTableMenu.h
//  BLTUIKitProject_Example
//
//  Created by Baletoo on 2020/12/2.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (BLTTableMenu)

@property (nonatomic, assign) NSInteger selectedRow;

@property (nonatomic, assign) NSInteger column;

@property (nonatomic, assign) BOOL onLoad;

@end

NS_ASSUME_NONNULL_END
