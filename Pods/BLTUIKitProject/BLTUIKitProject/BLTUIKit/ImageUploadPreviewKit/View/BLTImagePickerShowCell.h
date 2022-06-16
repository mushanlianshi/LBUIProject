//
//  BLTImagePickerShowCell.h
//  BLTUIKitProject_Example
//
//  Created by liu bin on 2020/3/24.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BLTImagePickerShowCell;
@class BLTImagePickerShowModel;

@interface BLTImagePickerShowCellConfig : NSObject

@property (nonatomic, strong) UIImage *pleaceHolderImage;
@property (nonatomic, strong) UIImage *addImage;
@property (nonatomic, strong) UIImage *unselectimage;
@property (nonatomic, strong) UIImage *selectImage;
@property (nonatomic, strong) UIImage *deleteImage;
@property (nonatomic, strong) UIImage *failedImage;
@property (nonatomic, strong) UIImage *playImage;
+ (instancetype)appearance;

@end


@protocol BLTImagePickerShowCellDelegate <NSObject>

//点击选择图片
- (void)imagePickerShowCellDidClickSelect:(BLTImagePickerShowCell *)cell;
//点击删除图片
- (void)imagePickerShowCellDidClickDelete:(BLTImagePickerShowCell *)cell;
//上传失败重试
- (void)imagePickerShowCellDidClickFailed:(BLTImagePickerShowCell *)cell;
//点击视频播放
- (void)imagePickerShowCellDidClickPlay:(BLTImagePickerShowCell *)cell;

@end

@interface BLTImagePickerShowCell : UICollectionViewCell

@property (nonatomic, strong) BLTImagePickerShowModel *model;

//@property (nonatomic, strong, readonly) NSIndexPath *indexPath;

@property (nonatomic, weak)id <BLTImagePickerShowCellDelegate> delegate;

@property (nonatomic, strong) UIImageView *imageView;

//上传的进度
@property (nonatomic, assign) CGFloat uploadProgress;




#pragma mark - appearance 外观展示修改的
@property (nonatomic, strong) BLTImagePickerShowCellConfig *cellConfig;

@end





