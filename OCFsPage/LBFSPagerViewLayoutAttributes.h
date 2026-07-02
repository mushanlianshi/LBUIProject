//
//  LBFSPagerViewLayoutAttributes.h
//  LBUIProject
//
//  Created by Wenchao Ding on 26/02/2017.
//  Copyright © 2017 Wenchao Ding. All rights reserved.
//  Converted to Objective-C with LB prefix
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBFSPagerViewLayoutAttributes : UICollectionViewLayoutAttributes

/// The position of the attribute in the pager view, used for applying transforms.
@property (nonatomic, assign) CGFloat position;

@end

NS_ASSUME_NONNULL_END