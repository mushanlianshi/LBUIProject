//
//  BLTImagePickerShowModel.h
//  BLTUIKitProject_Example
//
//  Created by liu bin on 2020/3/24.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import <Foundation/Foundation.h>

//图片展示的状态
typedef NS_ENUM(NSInteger, BLTImagePickerShowModelState){
    BLTImagePickerShowModelStateNormalShow = 0,      //正常展示
    BLTImagePickerShowModelStateWaitingUpload = 1,   //等待上传
    BLTImagePickerShowModelStateUploading,      //正在上传ing
    BLTImagePickerShowModelStateUploadSuccess,  //上传成功
    BLTImagePickerShowModelStateUploadFailed,   //上传失败
    BLTImagePickerShowModelStateDeleting,       //删除模式下
    BLTImagePickerShowModelStateSelect,         //选择状态
};

//添加的类型  默认添加照片  可组合
typedef NS_OPTIONS(NSInteger, BLTImagePickerShowModelAddTypeOptions){
    BLTImagePickerShowModelAddTypeOptionsPhotoLibrary = 1 << 0,  //图片相册
    BLTImagePickerShowModelAddTypeOptionsPhotoCamera = 1 << 1,       //拍照图片
    BLTImagePickerShowModelAddTypeOptionsVideoLibrary = 1 << 2,      //视频相册
    BLTImagePickerShowModelAddTypeOptionsVideoCamera = 1 << 3,       //拍照视频
};

@class BLTImagePickerShowTagModel;

@interface BLTImagePickerShowModel : NSObject

+ (instancetype)addModel;
//快速一个预览的模型
+ (instancetype)previewModelWithUrl:(NSString *)url;
    
- (instancetype)initWithDic:(NSDictionary *)infoDic;

@property (nonatomic, strong) UIImage *image;
//图片的链接   如果是上传到OSS上的就是OSS的链接 如果是视频  就是视频的缩略图
@property (nonatomic, copy) NSString *imageUrlString;

//上传图片到OSS上的名称 如果是视频就是视频的缩略图
@property (nonatomic, copy) NSString *imageOSSName;
//视频上传到OSS上的名称
@property (nonatomic, copy) NSString *videoOSSName;

@property (nonatomic, assign) BLTImagePickerShowModelState state;

//是否选中状态 state==BLTImagePickerShowModelStateSelect有效
@property (nonatomic, assign) BOOL selected;
//是不是视频
@property (nonatomic, assign, getter=isVideo) BOOL video;

@property (nonatomic, copy) NSString *videoURL;

//添加图片或则视频的
@property (nonatomic, assign, getter=isAddModel) BOOL addModel;

@property (nonatomic, assign) BLTImagePickerShowModelAddTypeOptions addTypeOptions;
//最长选择视频的时长 默认30s
@property (nonatomic, assign) CGFloat maxVideoTime;

@end




