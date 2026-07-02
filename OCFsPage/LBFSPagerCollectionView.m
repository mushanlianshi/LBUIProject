//
//  LBFSPagerCollectionView.m
//  LBUIProject
//
//  Created by Wenchao Ding on 24/12/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//  Converted to Objective-C with LB prefix
//

#import "LBFSPagerCollectionView.h"

@implementation LBFSPagerCollectionView

#if !TARGET_OS_TV
- (void)setScrollsToTop:(BOOL)scrollsToTop {
    // Always NO, ignore set
    [super setScrollsToTop:NO];
}

- (BOOL)scrollsToTop {
    return NO;
}
#endif

- (void)setContentInset:(UIEdgeInsets)contentInset {
    // Always zero, adjust contentOffset if needed
    [super setContentInset:UIEdgeInsetsZero];
    if (contentInset.top > 0) {
        CGPoint contentOffset = self.contentOffset;
        contentOffset.y += contentInset.top;
        self.contentOffset = contentOffset;
    }
}

- (UIEdgeInsets)contentInset {
    return [super contentInset];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.contentInset = UIEdgeInsetsZero;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;

    if (@available(iOS 10.0, *)) {
        self.prefetchingEnabled = NO;
    }

    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

#if !TARGET_OS_TV
    self.scrollsToTop = NO;
    self.pagingEnabled = NO;
#endif
}

@end