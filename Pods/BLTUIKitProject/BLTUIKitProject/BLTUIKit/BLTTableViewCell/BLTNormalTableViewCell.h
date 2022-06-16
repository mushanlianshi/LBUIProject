//
//  BLTNormalTableViewCell.h
//  BLTUIKitProject_Example
//
//  Created by Baletoo on 2020/10/15.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BLTDefaultDisableTitleColor [UIColor colorWithRed:194/255.0f green:194/255.0f blue:194/255.0f alpha:1]
#define BLTDefaultDisableDetailColor [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1]
#define BLTDefaultNormalTitleColor [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1]
#define BLTDefaultNormalDetailColor [UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1]

#define kBLTTableViewCellSourceBundle [NSBundle bundleWithPath:[[NSBundle bundleForClass:[BLTNormalTableViewCell class]] pathForResource:@"BLTTableViewCellSource" ofType:@"bundle"]]

#define BLTDefaultDisableSingleSelectImage [UIImage imageNamed:@"blt_single_disable" inBundle:kBLTTableViewCellSourceBundle compatibleWithTraitCollection:nil]
#define BLTDefaultDisableMultiSelectImage [UIImage imageNamed:@"blt_multi_disable" inBundle:kBLTTableViewCellSourceBundle compatibleWithTraitCollection:nil]
#define BLTDefaultMultiSelectImage [UIImage imageNamed:@"blt_multi_select" inBundle:kBLTTableViewCellSourceBundle compatibleWithTraitCollection:nil]
#define BLTDefaultSingleSelectImageName [UIImage imageNamed:@"blt_single_select" inBundle:kBLTTableViewCellSourceBundle compatibleWithTraitCollection:nil]
#define BLTDefaultUnselectImage [UIImage imageNamed:@"blt_unselect_icon" inBundle:kBLTTableViewCellSourceBundle compatibleWithTraitCollection:nil]

typedef NS_ENUM(NSInteger, BLTTableViewCellType) {
    BLTTableViewCellTypeDefault = 0,    // subTitleLabel位于右侧居上
    BLTTableViewCellTypeSubTitleCenter, // subTitleLabel位于右侧居中
};

typedef NS_ENUM(NSInteger, BLTTableViewCellAccessoryViewType) {
    BLTTableViewCellAccessoryViewTypeNone = 0,   // 无AccessoryView
    BLTTableViewCellAccessoryViewTypeRightArrow, // AccessoryView为向右的箭头
};

NS_ASSUME_NONNULL_BEGIN

@interface BLTNormalTableViewCell : UITableViewCell

@property (nonatomic, assign) BLTTableViewCellType cellType;

@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, strong, readonly) UILabel *detailLabel;

@property (nonatomic, strong, readonly) UILabel *subTitleLabel;

@property (nonatomic, strong, readonly) UIImageView *mainImageView;

@property (nonatomic, strong, nullable) UIView *customAccessoryView;

@property (nonatomic, assign) BLTTableViewCellAccessoryViewType customAccessoryViewType;

@property (nonatomic, strong, nullable) UIView *additionalAccessoryView;

@property (nonatomic, assign) UIEdgeInsets additionalAccessoryViewInset;

@property (nonatomic, assign) UIEdgeInsets contentInset;

@property (nonatomic, assign) CGSize imageSize;

@property (nonatomic, assign) UIEdgeInsets customSeparatorInset;

@property (nonatomic, strong) UIColor *customSeparatorColor;

@property (nonatomic, assign) CGFloat horizontalSpacing; // default is 10

@property (nonatomic, assign) CGFloat verticalSpacing; // default is 5

- (void)prepareLayout __attribute__((deprecated("已过时"))); // 需要在cellFroRow中返回cell之前手动调用

@end

NS_ASSUME_NONNULL_END
