//
//  BLTUploadImageViewModel.m
//  BLTUIKitProject_Example
//
//  Created by liu bin on 2020/3/24.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import "BLTUploadImageContentViewViewModel.h"
#import "BLTImagePickerShowModel.h"
#import <CommonCrypto/CommonRandom.h>
#import <AVFoundation/AVFoundation.h>

@implementation BLTUploadImageContentViewViewModel
//最多还可以选择几张照片
- (NSInteger)leftMaxImageCountAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger nowCount = [self p_nowImageCountAtIndexpath:indexPath];
    NSInteger maxCount = self.maxUploadImageCount;
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadImageContentView:maxUploadNumberInSection:)]) {
        maxCount = [self.delegate uploadImageContentView:self.uploadContentView maxUploadNumberInSection:indexPath.section];
    }
    return maxCount - nowCount;
}

//删除图片
- (BLTImagePickerShowModel *)deletePhotoAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = self.dataSources[indexPath.section];
    BLTImagePickerShowModel *model = array[indexPath.row];
    [array removeObjectAtIndex:indexPath.row];
    BLTImagePickerShowModel *firstModel = self.dataSources.firstObject.firstObject;
    //如果还可以上传图片  且第一个模型不是添加模型  添加
    NSInteger leftCount = [self leftMaxImageCountAtIndexPath:indexPath];
    if ( leftCount > 0 && !firstModel.isAddModel) {
        [self.dataSources.firstObject insertObject:[BLTImagePickerShowModel addModel] atIndex:0];
    }
    return model;
}


//添加新的要上传图片
- (void)addWaitingUploadImages:(NSArray <UIImage *>*)images indexPath:(NSIndexPath *)indexPath addIndexPaths:(void (^)(NSArray<NSIndexPath *> *))addIndexPaths autoDismissTakePhoto:(BOOL)autoDismissTakePhoto{
    //新加图片indexpath的数组
    NSMutableArray *addIndexPathsArray = @[].mutableCopy;
    NSMutableArray *tmpArray = self.dataSources[indexPath.section];
    NSInteger startIndexPathRow = tmpArray.count;
    [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:startIndexPathRow + idx inSection:indexPath.section];
        [addIndexPathsArray addObject:newIndexPath];
        BLTImagePickerShowModel *model = [[BLTImagePickerShowModel alloc] init];
        model.image = obj;
        model.state = BLTImagePickerShowModelStateWaitingUpload;
        [tmpArray addObject:model];
    }];
    
    BOOL hasDeleteTakePhoto = NO;
    if (autoDismissTakePhoto) {
        //判断有么有达到最大数 隐藏添加按钮的
        if ([self leftMaxImageCountAtIndexPath:indexPath] <= 0) {
            [tmpArray removeObjectAtIndex:0];
            hasDeleteTakePhoto = YES;
        }
    }
    
    //删除了入口  调整要上传的indexpath
    if (hasDeleteTakePhoto) {
        NSMutableArray *afterDeleteArray = @[].mutableCopy;
        [addIndexPathsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath *indexPath = (NSIndexPath *)obj;
            NSInteger row = MAX(indexPath.row - 1, 0);
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
            [afterDeleteArray addObject:newIndexPath];
        }];
        addIndexPathsArray = afterDeleteArray.mutableCopy;
    }
    if (addIndexPaths) {
        addIndexPaths(addIndexPathsArray.copy);
    }
}

- (void)addWaitingUploadVideos:(UIImage *)coverImage localVideoPath:(NSString *)localVideoPath indexPath:(NSIndexPath *)indexPath addIndexPath:(void(^)(NSIndexPath *indexPath))addIndexPath{
    NSMutableArray *tmpArray = self.dataSources[indexPath.section];
    NSInteger startIndexPathRow = tmpArray.count;
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:startIndexPathRow inSection:indexPath.section];
    BLTImagePickerShowModel *model = [[BLTImagePickerShowModel alloc] init];
    model.image = coverImage;
    model.state = BLTImagePickerShowModelStateWaitingUpload;
    model.video = YES;
    model.videoURL = localVideoPath;
    [tmpArray addObject:model];
    if (addIndexPath) {
        addIndexPath(newIndexPath);
    }
}

//压缩图片到指定大小
- (NSData *)compressImageToMaxSizeKB:(CGFloat)maxSizeKB image:(UIImage *)image{
    if (!image) {
        return nil;
    }
    
    maxSizeKB*=1024;
    
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = nil;
//
    if (maxSizeKB == 0) {
        imageData = UIImageJPEGRepresentation(image, 1);
    }else{
        imageData = UIImageJPEGRepresentation(image, compression);
        while ([imageData length] > maxSizeKB && compression > maxCompression) {
            compression -= 0.1;
            imageData = UIImageJPEGRepresentation(image, compression);
        }
    }
    return imageData;
}


//随机图片上传的名字
- (NSString *)randomUploadImageNameAtIndex:(NSInteger)index{
    NSString *imageName = [self p_randomTimeStampStringByLength:30 suffixString:[NSString stringWithFormat:@"%zd.png",index]];
    return imageName;
}

//随机视频上传的名字
- (NSString *)randomUploadVideoNameAtIndex:(NSInteger)index{
    NSString *videoName = [self p_randomTimeStampStringByLength:30 suffixString:[NSString stringWithFormat:@"%zd.mp4",index]];
    return videoName;
}

/// 随机字符串
/// @param length 字符串的长度
- (NSString *)p_randomStringByLength:(NSInteger)length suffixString:(NSString *)suffixString{
    length = length/2;
    unsigned char digest[length];
    CCRNGStatus status = CCRandomGenerateBytes(digest, length);
    NSString *randomString = nil;
    if (status == kCCSuccess) {
        randomString = [self p_stringFromByte:digest length:length];
    } else {
        randomString = @"";
    }
    randomString = [NSString stringWithFormat:@"%@%@",randomString,suffixString];
    return randomString;
}

//将bytes转为字符串
- (NSString *)p_stringFromByte:(unsigned char *)digest length:(NSInteger)length{
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < length; i++) {
        [string appendFormat:@"%02x",digest[i]];
    }
    return string;
}


- (NSString *)p_randomTimeStampStringByLength:(NSInteger)length suffixString:(NSString *)suffixString{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [[NSNumber numberWithLong:nowTime] stringValue];
    if (length <= fileName.length) {
        return fileName;
    }
    NSString *leftString = [self p_randomStringByLength:length - fileName.length suffixString:suffixString];
    return [NSString stringWithFormat:@"%@%@",fileName,leftString];
}

//现有几张照片
- (NSInteger)p_nowImageCountAtIndexpath:(NSIndexPath *)indexPath{
    __block NSInteger nowCount = 0;
    NSArray *array = self.dataSources[indexPath.section];
    for (int i = 0; i < array.count; i++) {
        BLTImagePickerShowModel *model = array[i];
        if (!model.isAddModel) {
            nowCount ++;
        }
    }
    return nowCount;
}


- (void)previewImagesAtIndexPath:(NSIndexPath *)indexPath successBlock:(void(^)(NSArray *imageArray, NSInteger currentIndex, BOOL hasVideo))successBlock{
    NSMutableArray *sourcesArray = @[].mutableCopy;
    __block NSInteger currentIndex = indexPath.row;
    __block BOOL hasVideo = NO;
    [self p_everyModelAtIndexPath:indexPath excuteBlock:^(BLTImagePickerShowModel *model, NSUInteger index) {
        if (model.isAddModel) {
            currentIndex --;
        }else{
            if (model.isVideo) {
                if (index <= indexPath.row) {
                    currentIndex --;
                }
                hasVideo = YES;
            }else if(model.imageUrlString && [model.imageUrlString isKindOfClass:[NSString class]] && model.imageUrlString.length > 0){
                NSURL *url = [NSURL URLWithString:model.imageUrlString];
                if (url) {
                    [sourcesArray addObject:url];
                }
            }else if (model.image){
                [sourcesArray addObject:model.image];
            }
        }
    }];
    if (currentIndex >= sourcesArray.count) {
        currentIndex = sourcesArray.count - 1;
    }
    if (successBlock) {
        successBlock(sourcesArray.copy, currentIndex, hasVideo);
    }
}




//是不是有未上传完成的图片
- (BOOL)hasWaitingForUploadImage{
    __block BOOL hasUnUploadImage = NO;
    [self everyModelInDataSourcesExecuteBlock:^(BLTImagePickerShowModel *model) {
        if (model.state == BLTImagePickerShowModelStateWaitingUpload || model.state == BLTImagePickerShowModelStateUploading) {
            hasUnUploadImage = YES;
        }
    }];
    return hasUnUploadImage;
}

//交换数据源
- (void)exchangeSourceIndexPath:(NSIndexPath *)indexPath destinationIndexPath:(NSIndexPath *)destinationIndexPath{
    //同一section
    NSMutableArray *firstArray = self.dataSources[indexPath.section];
    if (indexPath.section == destinationIndexPath.section) {
        BLTImagePickerShowModel *model = firstArray[indexPath.row];
        [firstArray removeObjectAtIndex:indexPath.row];
        [firstArray insertObject:model atIndex:destinationIndexPath.row];
    }else{
        NSMutableArray *secondArray = self.dataSources[destinationIndexPath.section];
        BLTImagePickerShowModel *model = firstArray[indexPath.row];
        [firstArray removeObjectAtIndex:indexPath.row];
        [secondArray insertObject:model atIndex:destinationIndexPath.row];
    }
}

//indexPath下 所有的模型
- (void)p_everyModelAtIndexPath:(NSIndexPath *)indexPath excuteBlock:(void(^)(BLTImagePickerShowModel *model, NSUInteger index))excuteBlock{
     NSArray <BLTImagePickerShowModel *>*sectionArray = self.dataSources[indexPath.section];
    [sectionArray enumerateObjectsUsingBlock:^(BLTImagePickerShowModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        excuteBlock(obj, idx);
    }];
}

//整个数据源下所有的模型
- (void)everyModelInDataSourcesExecuteBlock:(void(^)(BLTImagePickerShowModel *model))excuteBlock{
    [self.dataSources enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray <BLTImagePickerShowModel *>*array = obj;
        [array enumerateObjectsUsingBlock:^(BLTImagePickerShowModel * _Nonnull model, NSUInteger modelIdx, BOOL * _Nonnull modelStop) {
            if (excuteBlock) {
                excuteBlock(model);
            }
        }];
    }];
}

- (NSString *)presetNameFromVideoQuality:(UIImagePickerControllerQualityType)quality{
    NSString *presetName = AVAssetExportPresetMediumQuality;
    switch (quality) {
        case UIImagePickerControllerQualityTypeLow:
            presetName = AVAssetExportPresetLowQuality;
            break;
        case UIImagePickerControllerQualityTypeMedium:
            presetName = AVAssetExportPresetMediumQuality;
            break;
        case UIImagePickerControllerQualityTypeHigh:
            presetName = AVAssetExportPresetHighestQuality;
            break;
        default:
            break;
    }
    return presetName;
}

#pragma mark - 获取视频缩略图
- (UIImage *)getVideoThumbWithURL:(NSURL *)url{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

@end
