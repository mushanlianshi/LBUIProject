//
//  BLTTableMenuView.m
//  BLTUIKitProject_Example
//
//  Created by Baletoo on 2020/12/1.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import "BLTTableMenuView.h"
#import <Masonry/Masonry.h>
#import <objc/runtime.h>

@interface BLTTableMenuIndexPath ()

@property (nonatomic, assign, readwrite) NSInteger column;

@property (nonatomic, assign, readwrite) NSInteger row;

@end

@implementation BLTTableMenuIndexPath

+ (instancetype)indexPathWithColumn:(NSInteger)column row:(NSInteger)row
{
    BLTTableMenuIndexPath *indexPath = [[BLTTableMenuIndexPath alloc] init];
    indexPath.column = column;
    indexPath.row = row;
    return indexPath;
}

@end

#define kBLTTableMenuViewBackgroundMaskColor [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:0.5]

static NSString * const kBLTTableMenuCellIdentifier = @"kBLTTableMenuCellIdentifier";

@interface BLTTableMenuView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray<UITableView *> *tableViews;

@property (nonatomic, strong) UIStackView *horizontalStackView;

@property (nonatomic, strong) UIStackView *verticalStackView;

@property (nonatomic, assign) NSInteger columns;

@end

@implementation BLTTableMenuView

static BLTTableMenuView *menuInstance;
+ (instancetype)appearance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        menuInstance = [[BLTTableMenuView alloc] init];
    });
    return menuInstance;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.customSensorDataBlock = menuInstance.customSensorDataBlock;
    }
    return self;
}

#pragma mark - control
- (void)initTableViews
{
    NSMutableArray<UITableView *> *tableViews = [NSMutableArray arrayWithArray:self.tableViews];
    if (self.columns > tableViews.count) {
        for (int i=0; i<self.columns; i++) {
            if (i >= tableViews.count) {
                UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
                tableView.delegate = self;
                tableView.dataSource = self;
                tableView.column = i;
                tableView.selectedRow = -1;
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                [tableViews addObject:tableView];
                if (self.customSensorDataBlock) {
                    self.customSensorDataBlock(tableView);
                }
            }
        }
    }
    self.tableViews = tableViews.copy;
    [self.tableViews enumerateObjectsUsingBlock:^(UITableView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= self.columns) {
            [self.horizontalStackView removeArrangedSubview:obj];
            [obj removeFromSuperview];
            obj.onLoad = NO;
        }
        else {
            if (![self.horizontalStackView.arrangedSubviews containsObject:obj]) {
                [self.horizontalStackView addArrangedSubview:obj];
                if ([self.delegate respondsToSelector:@selector(menuView:willDisplayTableView:inColumn:)]) {
                    [self.delegate menuView:self willDisplayTableView:obj inColumn:idx];
                }
            }
            if ([self.delegate respondsToSelector:@selector(menuView:backgroundColorForColumn:)]) {
                obj.backgroundColor = [self.delegate menuView:self backgroundColorForColumn:idx];
            }
            if ([self.delegate respondsToSelector:@selector(menuView:proportionOfWidthForColumn:)]) {
                CGFloat proportion = MIN([self.delegate menuView:self proportionOfWidthForColumn:idx], 1);
                [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.horizontalStackView).multipliedBy(proportion);
                }];
            }
        }
    }];
    if ([self.delegate respondsToSelector:@selector(menuView:proportionOfWidthForColumn:)]) {
        self.horizontalStackView.distribution = UIStackViewDistributionFill;
    }
    else {
        self.horizontalStackView.distribution = UIStackViewDistributionFillEqually;
    }
    [self.horizontalStackView layoutIfNeeded];
}

- (void)layoutMenuListIfNeeded
{
    NSInteger columns = -1;
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInMenuView:)]) {
        columns = [self.dataSource numberOfColumnsInMenuView:self];
    }
    if (columns != self.columns) {
        self.columns = columns;
        [self initTableViews];
    }
}

#pragma mark - action
- (void)reloadAllColumn
{
    [self layoutMenuListIfNeeded];
    for (int i=0; i<self.columns; i++) {
        [self reloadColumn:i];
    }
}

- (void)reloadColumn:(NSInteger)column
{
    if (column < self.tableViews.count) {
        UITableView *tableView = self.tableViews[column];
        [tableView reloadData];
    }
}

- (NSInteger)selectedRowInColumn:(NSInteger)column
{
    if (column < self.tableViews.count) {
        return self.tableViews[column].selectedRow;
    }
    else {
        return -1;
    }
}

- (BLTNormalTableViewCell *)cellForRowAtIndexPath:(BLTTableMenuIndexPath *)indexPath
{
    return [self.tableViews[indexPath.column] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
}

- (void)selectRowAtIndexPath:(BLTTableMenuIndexPath *)indexPath
{
    if (indexPath.column < self.columns) {
        [self tableView:self.tableViews[indexPath.column] didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        [self.tableViews[indexPath.column] selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - tableView delegate/dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if ([self.dataSource respondsToSelector:@selector(menuView:numberOfRowsInColumn:)]) {
        rows = [self.dataSource menuView:self numberOfRowsInColumn:tableView.column];
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BLTNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBLTTableMenuCellIdentifier];
    BLTTableMenuIndexPath *menuIndexPath = [BLTTableMenuIndexPath indexPathWithColumn:tableView.column row:indexPath.row];
    if (!cell) {
        cell = [[BLTNormalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kBLTTableMenuCellIdentifier];
        if ([self.delegate respondsToSelector:@selector(menuView:didInitCell:forRowAtIndexPath:)]) {
            [self.delegate menuView:self didInitCell:cell forRowAtIndexPath:menuIndexPath];
        }
    }
    NSString *title;
    if ([self.dataSource respondsToSelector:@selector(menuView:titleForRowAtIndexPath:)]) {
        title = [self.dataSource menuView:self titleForRowAtIndexPath:menuIndexPath];
    }
    cell.titleLabel.text = title;
    if ([self.delegate respondsToSelector:@selector(menuView:willReturnCell:forRowAtIndexPath:)]) {
        [self.delegate menuView:self willReturnCell:cell forRowAtIndexPath:menuIndexPath];
    }
    if (tableView.selectedRow == indexPath.row) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.selectedRow != indexPath.row) {
        tableView.selectedRow = indexPath.row;
        [self.tableViews enumerateObjectsUsingBlock:^(UITableView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.column > tableView.column) {
                obj.selectedRow = -1;
            }
        }];
    }
    [self layoutMenuListIfNeeded];
    if ([self.delegate respondsToSelector:@selector(menuView:didSelectRowAtIndexPath:)]) {
        [self.delegate menuView:self didSelectRowAtIndexPath:[BLTTableMenuIndexPath indexPathWithColumn:tableView.column row:indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(menuView:didDeselectRowAtIndexPath:)]) {
        [self.delegate menuView:self didDeselectRowAtIndexPath:[BLTTableMenuIndexPath indexPathWithColumn:tableView.column row:indexPath.row]];
    }
}

#pragma mark - header/footer
- (void)setHeaderView:(UIView *)headerView
{
    [self.verticalStackView removeArrangedSubview:_headerView];
    [_headerView removeFromSuperview];
    _headerView = headerView;
    if (_headerView) {
        [self.verticalStackView insertArrangedSubview:_headerView atIndex:0];
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(_headerView.frame.size.height);
        }];
        [self.verticalStackView layoutIfNeeded];
    }
}

- (void)setFooterView:(UIView *)footerView
{
    [self.verticalStackView removeArrangedSubview:_footerView];
    [_footerView removeFromSuperview];
    _footerView = footerView;
    if (_footerView) {
        [self.verticalStackView addArrangedSubview:_footerView];
        [_footerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(_footerView.frame.size.height);
        }];
        [self.verticalStackView layoutIfNeeded];
    }
}

#pragma mark - lazy load
- (UIStackView *)horizontalStackView
{
    if (!_horizontalStackView) {
        _horizontalStackView = [[UIStackView alloc] init];
        if (self.headerView) {
            [self.verticalStackView insertArrangedSubview:_horizontalStackView atIndex:1];
        }
        else {
            [self.verticalStackView insertArrangedSubview:_horizontalStackView atIndex:0];
        }
        [self.verticalStackView layoutIfNeeded];
    }
    return _horizontalStackView;
}

- (UIStackView *)verticalStackView
{
    if (!_verticalStackView) {
        _verticalStackView = [[UIStackView alloc] init];
        _verticalStackView.axis = UILayoutConstraintAxisVertical;
        [self addSubview:self.verticalStackView];
        [_verticalStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _verticalStackView;
}

@end
