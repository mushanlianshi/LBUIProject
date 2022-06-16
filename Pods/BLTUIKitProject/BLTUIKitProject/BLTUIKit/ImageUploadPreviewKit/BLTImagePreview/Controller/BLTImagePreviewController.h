//
//  BLTImagePreviewController.h
//  BLTUIKitProject_Example
//
//  Created by liu bin on 2020/3/24.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLTImagePreviewNaviBar.h"


@class BLTImagePreviewController;
@class BLTImagePreviewView;

@protocol BLTImagePreviewControllerDelegate <NSObject>
@optional
- (void)imagePreviewController:(BLTImagePreviewController *)imagePreviewController didDeleteAtIndex:(NSInteger)index;

@end

/// 图片预览的controller
@interface BLTImagePreviewController : UIViewController

- (instancetype)initWithImages:(NSArray *)imageArray currentIndex:(NSInteger)currentIndex canDelete:(NSInteger)canDelete;

//是否可以删除图片
@property (nonatomic, assign) BOOL canDelete;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, copy) NSArray *imagesArray;

@property (nonatomic, weak)id <BLTImagePreviewControllerDelegate> delegate;
//暴露出去是为了修改navibar样式的  使用navibar imagePreviewNaviBarConfigUI的方法修改
@property (nonatomic, strong) BLTImagePreviewNaviBar *naviBar;

//做动画用的view 从imageView展示controller
@property (nonatomic, copy) UIImageView *(^startAnimatingImageView)(void);
/** 消失动画的用的 */
@property (nonatomic, copy) UIImageView *(^endAnimatingImageView)(NSUInteger index);

@property (nonatomic, strong) BLTImagePreviewView *imagePreviewView;

@end

