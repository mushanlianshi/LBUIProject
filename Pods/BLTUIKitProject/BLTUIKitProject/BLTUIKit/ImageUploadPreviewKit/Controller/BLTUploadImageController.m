//
//  BLTImagePickerShowController.m
//  BLTUIKitProject_Example
//
//  Created by liu bin on 2020/3/24.
//  Copyright © 2020 mushanlianshi. All rights reserved.1.1.6 add
//

#import "BLTUploadImageController.h"
#import "BLTUICommonDefines.h"
#import "BLTImagePickerSectionHeaderView.h"
#import "BLTUploadImageContentView.h"
#import "BLTImagePickerShowModel.h"
#import "BLTImagePreviewNaviBar.h"

@interface BLTUploadImageController ()<BLTUploadImageContentViewDelegate, BLTImagePreviewNaviBarDelegate>

@property (nonatomic, strong) BLTImagePreviewNaviBar *naviBar;

//上传图片的任务
@property (nonatomic, strong) NSMutableArray <NSIndexPath *>*uploadTaskArray;

@property (nonatomic, strong) UIButton *sureButton;

@end

@implementation BLTUploadImageController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.uploadImageMode = YES;
    }
    return self;
}

/** 快速初始化一个浏览图片的VC */
- (instancetype)initPreviewPhotoList:(NSArray <NSDictionary *>*)photoList title:(NSString *)title{
    return [self initPreviewPhotoList:photoList title:title sectionTitleKey:@"title" photoListKey:@"list"];
}

/** 使用自定义的key */
- (instancetype)initPreviewPhotoList:(NSArray <NSDictionary *> *)photoList title:(NSString *)title sectionTitleKey:(NSString *)sectionTitleKey photoListKey:(NSString *)photoListKey{
    self = [self init];
    self.naviTitle = title;
    self.uploadImageMode = NO;
    [self convertPreviewPhotoDataSources:photoList sectionTitleKey:sectionTitleKey photoListKey:photoListKey];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDefaultUploadDataSources];
    [self initUI];
}

- (void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"上传照片";
    if ([self bePresented]) {
        _naviBar = [[BLTImagePreviewNaviBar alloc] init];
        _naviBar.backgroundColor = [UIColor whiteColor];
        _naviBar.backImage = UIImageNamedFromBLTUIKItBundle(@"blt_upload_image_navi_back_black");
        [_naviBar refreshNaviBarUIConfig:^(UIButton *deleteButton, UILabel *titleLab, UIButton *backButton) {
            deleteButton.hidden = YES;
            titleLab.text = self.naviTitle ? self.naviTitle : @"上传照片";
            titleLab.textColor = [UIColor blackColor];
        }];
        BLT_WS(weakSelf);
        _naviBar.backBlock = ^{
            [weakSelf back];
        };
        [self.view addSubview:self.naviBar];
    }else{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:UIImageNamedFromBLTUIKItBundle(@"blt_upload_image_navi_back_black") style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.title = self.naviTitle ? self.naviTitle : @"上传照片";
    }
   
    if (self.uploadImageMode) {
        [self.view addSubview:self.sureButton];
    }
    _uploadContentView = [[BLTUploadImageContentView alloc] initWithFrame:CGRectZero];
    _uploadContentView.style = self.uploadImageMode ? BLTUploadImageContentViewStyleUpload : BLTUploadImageContentViewStyleShow;
    _uploadContentView.delegate = self;
    _uploadContentView.collectionView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    _uploadContentView.imagesArray = self.imagesArray.mutableCopy;
    _uploadContentView.ossConfigBlock = ^BLTOSSConfigModel *{
        return nil;
    };
    [self.view addSubview:_uploadContentView];
    if (self.uploadImageControllerConfigUI) {
        self.uploadImageControllerConfigUI(_naviBar, _uploadContentView, _uploadContentView.collectionView, _sureButton);
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat verticalY = 0;
    CGFloat uploadContentH = BLT_DEF_SCREEN_HEIGHT - BLT_SCREEN_BOTTOM_OFFSET - BLT_SCREEN_NAVI_HEIGHT;
    if ([self bePresented]) {
        verticalY += CGRectGetMaxY(self.naviBar.frame);
    }
    if (self.uploadImageMode) {
        CGFloat buttonH = 50;
        uploadContentH -= buttonH;
        self.sureButton.frame = CGRectMake(0, uploadContentH, BLT_DEF_SCREEN_WIDTH, buttonH);
    }
    _uploadContentView.frame = CGRectMake(0, verticalY, BLT_DEF_SCREEN_WIDTH, uploadContentH);
}

#pragma mark - uploadContentView delegate
//有几个section的  scrollVertical时有效
- (NSInteger)numberOfSectionsInUploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView{
    return self.sectionTitlesArray.count > 0 ? self.sectionTitlesArray.count : 1;
}
//section title
- (id)uploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView titleAtSection:(NSInteger)section{
    if (self.sectionTitlesArray.count > 0) {
        return self.sectionTitlesArray[section];
    }
    return nil;
}

- (void)noOSSConfigProvideUploadImageContentView:(BLTUploadImageContentView *)uploadImageContentView{
//    [self showHintTipContent:@"获取信息失败，请退出后再试"];
}


- (void)initDefaultUploadDataSources{
    if (!_sectionTitlesArray) {
        _sectionTitlesArray = @[@"请选择照片"];
    }
    if (!_imagesArray) {
        _imagesArray = @[].mutableCopy;
        [self.sectionTitlesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BLTImagePickerShowModel *addModel = [BLTImagePickerShowModel addModel];
            [_imagesArray addObject:@[addModel].mutableCopy];
            if (idx == self.sectionTitlesArray.count - 1) {
                addModel.addTypeOptions = BLTImagePickerShowModelAddTypeOptionsVideoLibrary;
            }
        }];
    }
}

- (void)convertPreviewPhotoDataSources:(NSArray <NSDictionary *>*)array sectionTitleKey:(NSString *)sectionTitleKey photoListKey:(NSString *)photoListKey{
    _imagesArray = @[].mutableCopy;
    NSMutableArray *tmpSectionTitles = @[].mutableCopy;
    
    [array enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id title = obj[sectionTitleKey] ? : @"";
        [tmpSectionTitles addObject:title];
        NSArray <NSString *>*sectionPhotos = obj[photoListKey];
        NSMutableArray *sectionPhotoModelArray = @[].mutableCopy;
        [sectionPhotos enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BLTImagePickerShowModel *photoModel = [BLTImagePickerShowModel previewModelWithUrl:obj];
            [sectionPhotoModelArray addObject:photoModel];
        }];
        [_imagesArray addObject:sectionPhotoModelArray.copy];
    }];
    _sectionTitlesArray = tmpSectionTitles.copy;
}

- (void)back{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)sureButtonClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadImageControllerDidClickSure:)]) {
        [self.delegate uploadImageControllerDidClickSure:self];
    }
}



- (BLTImagePreviewNaviBar *)naviBar{
    if (!_naviBar) {
        _naviBar = [[BLTImagePreviewNaviBar alloc] init];
        _naviBar.backImage = UIImageNamedFromBLTUIKItBundle(@"blt_upload_image_navi_back_black");
        BLT_WS(weakSelf);
        _naviBar.backBlock = ^{
            [weakSelf back];
        };
    }
    return _naviBar;
}

- (UIButton *)sureButton{
    if (!_sureButton) {
        CGFloat y = [UIScreen mainScreen].bounds.size.height - 44 - BLT_SCREEN_BOTTOM_OFFSET;
        _sureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, y, [UIScreen mainScreen].bounds.size.width, 44)];
        [_sureButton addTarget:self action:@selector(sureButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        _sureButton.backgroundColor = BLT_HEXCOLOR(0x4E8CEE);
    }
    return _sureButton;
}

- (BOOL)bePresented{
    if (self.navigationController && self.navigationController.viewControllers.count > 0 && self.navigationController.viewControllers.firstObject != self) {
        return NO;
    }
    return YES;
}



@end
