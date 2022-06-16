//
//  BLTImagePreviewView.h
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/28.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import <UIKit/UIKit.h>



@class BLTImagePreviewView;
@protocol BLTImagePreviewViewDelegate <NSObject>

@optional
//可以用数据源来实现展示的  也可以使用内部自己处理的
- (NSInteger)numberOfImagesInImagePreviewView:(BLTImagePreviewView *)imagePreviewView;
//需要提供展示的方法  由外部来处理  不实现 默认内部自己处理
- (void)imagePreviewView:(BLTImagePreviewView *)imagePreviewView previewImageView:(UIImageView *)imageView atIndex:(NSInteger)index;
//滑动到哪的回调
- (void)imagePreviewView:(BLTImagePreviewView *)imagePreviewView didScrollToIndex:(NSInteger)scrollToIndex;

@end

/// 在封装一层出来   防止不用controller展示的
@interface BLTImagePreviewView : UIView<UIAppearance>

- (instancetype)initWithFrame:(CGRect)frame imagesArray:(NSArray *)imagesArray currentIndex:(NSInteger)currentIndex;

//图片的数组  数据源
@property (nonatomic, copy) NSArray *imagesArray;

@property (nonatomic, assign) NSInteger currentIndex;
//动画用的
- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated;

@property (nonatomic, weak)id <BLTImagePreviewViewDelegate> delegate;

@property (nonatomic, strong) UICollectionView *collectionView;

//占位图
@property (nonatomic, strong) UIImage *placeHolderImage UI_APPEARANCE_SELECTOR;

#pragma mark - 设置用的
//根据索引获取图片展示的ImageView
- (UIImageView *)imageViewAtIndex:(NSInteger)index;
//根据imageView获取索引的   通过superView找
- (NSInteger)indexForImageView:(UIImageView *)imageView;

//设置外观用的
@property (nonatomic, copy) void (^imagePreviewViewConfigUI) (UICollectionView *collctionView, UIActivityIndicatorView *activityIndicatoreView);
@end



