//
//  BLTUploadImageViewModel.h
//  BLTUIKitProject_Example
//
//  Created by liu bin on 2020/3/24.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLTUploadImageContentView.h"


@interface BLTUploadImageContentViewViewModel : NSObject

@property (nonatomic, weak) id<BLTUploadImageContentViewDelegate> delegate;

@property (nonatomic, weak)  NSMutableArray <NSMutableArray <BLTImagePickerShowModel *>*>*dataSources;

@property (nonatomic, weak) BLTUploadImageContentView *uploadContentView;

@property (nonatomic, assign) NSInteger maxUploadImageCount;

//最多还可以选择几张照片
- (NSInteger)leftMaxImageCountAtIndexPath:(NSIndexPath *)indexPath;

//删除图片
- (BLTImagePickerShowModel *)deletePhotoAtIndexPath:(NSIndexPath *)indexPath;

//添加新的要上传图片
- (void)addWaitingUploadImages:(NSArray <UIImage *>*)images indexPath:(NSIndexPath *)indexPath addIndexPaths:(void(^)(NSArray <NSIndexPath *>*indexPaths))addIndexPaths autoDismissTakePhoto:(BOOL)autoDismissTakePhoto;

//添加新的要上传的视频
- (void)addWaitingUploadVideos:(UIImage *)coverImage localVideoPath:(NSString *)localVideoPath indexPath:(NSIndexPath *)indexPath addIndexPath:(void(^)(NSIndexPath *indexPath))addIndexPath;

//压缩图片到指定大小
- (NSData *)compressImageToMaxSizeKB:(CGFloat)maxSizeKB image:(UIImage *)image;

//随机图片上传的名字
- (NSString *)randomUploadImageNameAtIndex:(NSInteger)index;
//随机视频上传的名字
- (NSString *)randomUploadVideoNameAtIndex:(NSInteger)index;

//单纯预览图片的
- (void)previewImagesAtIndexPath:(NSIndexPath *)indexPath successBlock:(void(^)(NSArray *imageArray, NSInteger currentIndex, BOOL hasVideo))successBlock;

//是不是有未上传完成的图片
- (BOOL)hasWaitingForUploadImage;

//交换数据源
- (void)exchangeSourceIndexPath:(NSIndexPath *)indexPath destinationIndexPath:(NSIndexPath *)destinationIndexPath;

//整个数据源下所有的模型
- (void)everyModelInDataSourcesExecuteBlock:(void(^)(BLTImagePickerShowModel *model))excuteBlock;

- (NSString *)presetNameFromVideoQuality:(UIImagePickerControllerQualityType)quality;

#pragma mark - 获取视频缩略图
- (UIImage *)getVideoThumbWithURL:(NSURL *)url;
@end

