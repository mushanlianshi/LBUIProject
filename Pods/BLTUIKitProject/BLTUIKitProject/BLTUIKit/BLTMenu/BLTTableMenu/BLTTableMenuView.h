//
//  BLTTableMenuView.h
//  BLTUIKitProject_Example
//
//  Created by Baletoo on 2020/12/1.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLTNormalTableViewCell.h"
#import "UITableView+BLTTableMenu.h"

NS_ASSUME_NONNULL_BEGIN

@class BLTTableMenuView;

@interface BLTTableMenuIndexPath : NSObject

@property (nonatomic, assign, readonly) NSInteger column;

@property (nonatomic, assign, readonly) NSInteger row;

+ (instancetype)indexPathWithColumn:(NSInteger)column row:(NSInteger)row;

@end

@protocol BLTTableMenuDataSource <NSObject>

@required
- (NSInteger)menuView:(BLTTableMenuView *)menuView numberOfRowsInColumn:(NSInteger)column;

- (NSString *)menuView:(BLTTableMenuView *)menuView titleForRowAtIndexPath:(BLTTableMenuIndexPath *)indexPath;

@optional
- (NSInteger)numberOfColumnsInMenuView:(BLTTableMenuView *)menuView;

@end

@protocol BLTTableMenuDelegate <NSObject>

@optional
- (void)menuView:(BLTTableMenuView *)menuView didInitCell:(BLTNormalTableViewCell *)cell forRowAtIndexPath:(BLTTableMenuIndexPath *)indexPath;

- (void)menuView:(BLTTableMenuView *)menuView willReturnCell:(BLTNormalTableViewCell *)cell forRowAtIndexPath:(BLTTableMenuIndexPath *)indexPath;

- (void)menuView:(BLTTableMenuView *)menuView didSelectRowAtIndexPath:(BLTTableMenuIndexPath *)indexPath;

- (void)menuView:(BLTTableMenuView *)menuView didDeselectRowAtIndexPath:(BLTTableMenuIndexPath *)indexPath;

- (void)menuView:(BLTTableMenuView *)menuView willDisplayTableView:(UITableView *)tableView inColumn:(NSInteger)column;

- (UIColor *)menuView:(BLTTableMenuView *)menuView backgroundColorForColumn:(NSInteger)column;

- (CGFloat)menuView:(BLTTableMenuView *)menuView proportionOfWidthForColumn:(NSInteger)column;

@end

@interface BLTTableMenuView : UIView<UIAppearance>

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, weak) id<BLTTableMenuDataSource> dataSource;

@property (nonatomic, weak) id<BLTTableMenuDelegate> delegate;

- (NSInteger)selectedRowInColumn:(NSInteger)column;

- (BLTNormalTableViewCell *)cellForRowAtIndexPath:(BLTTableMenuIndexPath *)indexPath;

- (void)selectRowAtIndexPath:(BLTTableMenuIndexPath *)indexPath;

- (void)reloadColumn:(NSInteger)column;

- (void)reloadAllColumn;


@property (nonatomic, copy) void(^customSensorDataBlock)(UITableView *tableView) UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END
