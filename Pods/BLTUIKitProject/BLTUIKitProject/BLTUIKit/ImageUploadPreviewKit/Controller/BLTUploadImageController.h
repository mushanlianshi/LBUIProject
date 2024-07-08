//
//  BLTImagePickerShowController.h
//  BLTUIKitProject_Example
//
//  Created by liu bin on 2020/3/24.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLTUploadImageContentView.h"
#import "BLTImagePickerShowModel.h"
//typedef n <#new#>;

@class BLTUploadImageController;
@class BLTImagePreviewNaviBar;

//用于自定义的  需要子类类实现这个代理
@protocol BLTUploadImageControllerDelegate <NSObject>

@optional

//上传style点击了确定的回调 上传OSS的名字
- (void)uploadImageControllerDidClickSure:(BLTUploadImageController *)uploadImageController;

@end


/// 图片选择上传和展示的Controller
@interface BLTUploadImageController : UIViewController

/** 快速初始化一个浏览图片的VC   NSDictionary里键值是title list的  不是的需要自己转*/
- (instancetype)initPreviewPhotoList:(NSArray <NSDictionary *> *)photoList title:(NSString *)title;
/** 使用自定义的key */
- (instancetype)initPreviewPhotoList:(NSArray <NSDictionary *> *)photoList title:(NSString *)title sectionTitleKey:(NSString *)sectionTitleKey photoListKey:(NSString *)photoListKey;


/** 里面是字符串  或则是富文本 */
@property (nonatomic, copy) NSArray *sectionTitlesArray;

@property (nonatomic, strong) NSMutableArray <NSMutableArray <BLTImagePickerShowModel *>*>*imagesArray;

@property (nonatomic, strong) BLTUploadImageContentView *uploadContentView;

#pragma mark - 自定义用的
@property (nonatomic, weak)id <BLTUploadImageControllerDelegate> delegate;

@property (nonatomic, copy) NSString *naviTitle;

//是上传图片还是只是预览图片
@property (nonatomic, assign) BOOL uploadImageMode;

//控制外观用的
@property (nonatomic, copy) void(^uploadImageControllerConfigUI)(BLTImagePreviewNaviBar *naviBar,BLTUploadImageContentView *contentView, UICollectionView *collectionView,UIButton *sureButton) UI_APPEARANCE_SELECTOR;

@end

