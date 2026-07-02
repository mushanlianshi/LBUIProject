//
//  LBFSPagerViewCell.h
//  LBUIProject
//
//  Created by Wenchao Ding on 17/12/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//  Converted to Objective-C with LB prefix
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBFSPagerViewCell : UICollectionViewCell

/// Returns the label used for the main textual content of the pager view cell.
@property (nonatomic, strong, readonly, nullable) UILabel *textLabel;

/// Returns the image view of the pager view cell. Default is nil.
@property (nonatomic, strong, readonly, nullable) UIImageView *imageView;

@end

NS_ASSUME_NONNULL_END