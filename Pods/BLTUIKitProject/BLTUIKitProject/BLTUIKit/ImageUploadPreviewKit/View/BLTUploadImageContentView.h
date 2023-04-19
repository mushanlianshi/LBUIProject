//
//  BLTUploadImageContentView.h
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/30.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLTAliOSSUploadManager.h"

@class BLTUploadImageContentView;
@class BLTImagePickerShowModel;
@class BLTImagePickerShowCell;

//样式  默认是上传图片的
typedef NS_ENUM(NSInteger, BLTUploadImageContentViewStyle){
    BLTUploadImageContentViewStyleUpload = 0,    //上传图片
    BLTUploadImageContentViewStyleShow,          //展示图片
};

@protocol BLTUploadImageContentViewDelegate <NSObject>

@optional
//默认每一行最大上传的图片数量，不实现默认是9张
- (NSInteger)uploadImageContentView:(BLTUploadImageContentView *)contentView maxUploadNumberInSection:(NSInteger)section;
//section title的数组 可以是字符串 或则富文本
- (id)uploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView titleAtSection:(NSInteger)section;
- (UICollectionReusableView *)uploadImageContentView:(BLTUploadImageContentView *)uploadContentView headerViewAtSection:(NSInteger)section;
- (CGSize)uploadImageContentView:(BLTUploadImageContentView *)uploadContentView sizeForHeaderViewAtSection:(NSInteger)section;

- (UICollectionReusableView *)uploadImageContentView:(BLTUploadImageContentView *)uploadContentView footerViewAtSection:(NSInteger)section;
- (CGSize)uploadImageContentView:(BLTUploadImageContentView *)uploadContentView sizeForFooterViewAtSection:(NSInteger)section;

//自定义预览图片和视频的
- (void)uploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView previewImageArray:(NSArray <BLTImagePickerShowModel *>*)imageArray currentIndex:(NSInteger)currentIndex;
- (void)uploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView previewVideoUrl:(NSString *)previewUrl;

//点击添加  选择超过了最大张数
- (void)uploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView outOfMaxCountAtSection:(NSInteger)section;
//没有OSSConfig提供的时候调用
- (void)noOSSConfigProvideUploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView;
//有几个section的  scrollVertical时有效
- (NSInteger)numberOfSectionsInUploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView;


//不使用OSS上传   自定义上传图片方法的   需要自己设置进度 以及model成功和失败的状态 (reture YES,使用自定义上传)
- (BOOL)uploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView customUploadImageAtIndexPath:(NSIndexPath *)indexPath image:(UIImage *)image imageModel:(BLTImagePickerShowModel *)imageModel uploadImageCell:(BLTImagePickerShowCell *)uploadImageCell;
//自定义上传视频 videoPath视频导出的路径 coverImage视频的缩略图 (reture YES,使用自定义上传)
- (BOOL)uploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView customUploadVideoAtIndexPath:(NSIndexPath *)indexPath videoPath:(NSString *)videoPath coverImage:(UIImage *)coverImage videoModel:(BLTImagePickerShowModel *)videoModel uploadVideoCell:(BLTImagePickerShowCell *)uploadVideoCell;
//上传成功的回调
- (void)uploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView uploadSuccessAtIndexPath:(NSIndexPath *)indexPath;
//上传失败的回调
- (void)uploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView uploadFailureAtIndexPath:(NSIndexPath *)indexPath;
//删除图片的回调
- (void)uploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView didDeleteAtIndexPath:(NSIndexPath *)indexPath deleteModel:(BLTImagePickerShowModel *)deleteModel;
//是否允许选中图片
- (BOOL)uploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//添加图片或则删除 视频的回调 给外部计算剩余个数用的
- (void)uploadImageContentViewImageVideoCountChange:(BLTUploadImageContentView *)uploadImageContentView;


//产出视频选择最大时长的
- (void)outOfMaxVideoSecondUploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView;
//开始导出图片  用于处理中 加载菊花的
- (void)startExportVideoUploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView;
//导出图片的缩略图以及视频的路径成功  关闭菊花的
- (void)uploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView coverImage:(UIImage *)coverImage videoPath:(NSString *)videoPath;
//导出视频失败
- (void)uploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView failedError:(NSError *)failedError;

//即将返回展示图片的cell对象(用于自定义处理样式)
- (void)willReturnImagePickerShowCell:(BLTImagePickerShowCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

/// 上传图片功能封装的view  针对一些不用controller处理的  封装到view层里
@interface BLTUploadImageContentView : UIView<UIAppearance>

//默认是上传的
@property (nonatomic, assign) BLTUploadImageContentViewStyle style;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, weak)id <BLTUploadImageContentViewDelegate> delegate;
//模型的数组
@property (nonatomic, strong) NSMutableArray <NSMutableArray <BLTImagePickerShowModel *>*>*imagesArray;
//图片原型的数组
@property (nonatomic, copy) NSArray <NSArray *>*photosArray;

//设置图片圆形数组   是否只是展示  控制可不可以删除的
- (void)setPhotosArray:(NSArray<NSArray *> *)photosArray onlyShow:(BOOL)onlyShow;

/// 设置图片圆角，默认为0
@property (nonatomic, assign) CGFloat imageCornerRadius;

//是否还有没有上传完的照片
@property (nonatomic, assign, readonly) BOOL hasUnUploadImage;

//最大上传图片的张数  默认9  设置代理时无效  
@property (nonatomic, assign) NSInteger maxUploadImageCount;
/** 达到上限时   是否默认隐藏拍照入口 默认NO  不隐藏 */
@property (nonatomic, assign) BOOL autoDismissTakePhoto;
//每行展示几个
@property (nonatomic, assign) NSInteger countPerLine;
//图片展示宽高比(默认为1)
@property (nonatomic, assign) CGFloat imageProportion;

//OSS配置模型  工程不一样获取方法不一样  由外面来提供
@property (nonatomic, copy) BLTOSSConfigModel*  (^ossConfigBlock)(void);

- (void)refreshOSSConfigModel:(BLTOSSConfigModel *)OSSModel;

- (BLTImagePickerShowModel *)modelAtIndexPath:(NSIndexPath *)indexPath;


#pragma mark - 获取上传信息的
//图片上传的OSS名称
@property (nonatomic, copy, readonly) NSArray *imageOSSNames;

@property (nonatomic, copy, readonly) NSArray *imageOSSURLFullPaths;

//视频缩略图上传的OSS名称
@property (nonatomic, copy, readonly) NSArray *videoCoverImageOSSNames;
//视频上传的OSS名称
@property (nonatomic, copy, readonly) NSArray *videoOSSNames;

//collection的height随contentSizeb自适应
@property (nonatomic, assign) BOOL autoHeight;
//上传视频缩略图的  默认NO 不上传
@property (nonatomic, assign) BOOL uploadVideoCoverImage;

//压缩到大小以下    默认1024kb  0不压缩
@property (nonatomic, assign) NSUInteger scaleToKBSize;

/// Default value is 2 minutes / 视频最大拍摄时间，默认是10分钟，单位是秒
@property (assign, nonatomic) NSTimeInterval videoMaximumDuration;
//视频的质量
@property (nonatomic, assign) UIImagePickerControllerQualityType    videoQuality;

@property (nonatomic, copy) void(^customSensorDataBlock)(UICollectionView *collectionView) UI_APPEARANCE_SELECTOR;

@end

