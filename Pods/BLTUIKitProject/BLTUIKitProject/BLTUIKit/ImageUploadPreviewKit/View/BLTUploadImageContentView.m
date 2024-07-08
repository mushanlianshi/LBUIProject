//
//  BLTUploadImageContentView.m
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/30.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import "BLTUploadImageContentView.h"
#import "BLTImagePickerShowCell.h"
#import "BLTImagePickerShowModel.h"
#import "BLTImagePickerSectionHeaderView.h"
#import "TZImagePickerController.h"
#import "BLTUploadImageContentViewViewModel.h"
#import "BLTAliOSSUploadManager.h"
#import "BLTSystemPermissionManager.h"
#import "BLTUICommonDefines.h"
#import <BLTBasicUIKit/BLTBasicUIKit.h>
#import "BLTVideoPreviewController.h"
//#import "TZImagePreviewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIViewController+BLTPreviewImage.h"

static NSString * const kUploadImageCellIdentifier = @"kUploadImageCellIdentifier";
static NSString * const kUploadImageSectionHeaderIdentifier = @"kUploadImageSectionHeaderIdentifier";
@interface BLTUploadImageContentView ()<UICollectionViewDelegate, UICollectionViewDataSource, BLTImagePickerShowCellDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    NSMutableArray <NSMutableArray <BLTImagePickerShowModel *>*>* _imagesArray;
    BOOL hasAddObserver;
}

//记录预览当前的indexpath  用来在预览界面删除用的
@property (nonatomic, strong) NSIndexPath *previewCurrentIndexPath;

@property (nonatomic, weak) BLTImagePickerShowCell *startExchangeCell;

@property (nonatomic, strong) BLTUploadImageContentViewViewModel *viewModel;

@property (nonatomic, strong) BLTAliOSSUploadManager *uploadManager;

@property (nonatomic, weak) UIViewController *currentVC;

@property (nonatomic, strong) BLTOSSConfigModel *ossConfigModel;

//上传图片的任务
@property (nonatomic, strong) NSMutableArray <NSIndexPath *>*uploadTaskArray;

//用来提示信息的
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, assign) BOOL tipAnimating;

@property (nonatomic, strong) NSIndexPath *addImageSelectIndexPath;

@property (nonatomic, strong) NSLayoutConstraint *autoHeightConstraint;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@property (nonatomic, assign) BOOL processingVideo;

@end

@implementation BLTUploadImageContentView

static BLTUploadImageContentView *uploadInstance;
+ (instancetype)appearance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uploadInstance = [[BLTUploadImageContentView alloc] init];
    });
    return uploadInstance;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitialize];
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _flowLayout.minimumLineSpacing = 15;
        _flowLayout.minimumInteritemSpacing = 15;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, BLT_DEF_SCREEN_WIDTH, CGRectGetHeight(frame)) collectionViewLayout:_flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[BLTImagePickerShowCell class] forCellWithReuseIdentifier:kUploadImageCellIdentifier];
        [_collectionView registerClass:[BLTImagePickerSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kUploadImageSectionHeaderIdentifier];
        //IOS9拖拽移动
        if (@available(iOS 9.0, *)){
            _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureHandler:)];
            _longPressGesture.minimumPressDuration = 0.25;
            [_collectionView addGestureRecognizer:_longPressGesture];
        }
        [self addSubview:_collectionView];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    if (self.customSensorDataBlock) {
        self.customSensorDataBlock(_collectionView);
    }
}

- (void)setStyle:(BLTUploadImageContentViewStyle)style{
    _style = style;
    if (_style == BLTUploadImageContentViewStyleShow) {
        [_collectionView removeGestureRecognizer:_longPressGesture];
    }
}

- (void)setAutoHeight:(BOOL)autoHeight{
    if(_autoHeight == autoHeight) return;
    
    _autoHeight = autoHeight;
    if(autoHeight){
        if(!hasAddObserver){
            [self addCollectionObserver];
        }
    }else{
        if(hasAddObserver){
            [self removeCollectionObserver];
        }
    }
}


- (void)didInitialize{
    self.autoDismissTakePhoto = NO;
    self.maxUploadImageCount = 9;
    self.countPerLine = 4;
    _processingVideo = NO;
    _imageProportion = 1.0f;
    _scaleToKBSize = 1024;
    _videoMaximumDuration = 2 * 60;
    _videoQuality = UIImagePickerControllerQualityTypeMedium;
    self.customSensorDataBlock = uploadInstance.customSensorDataBlock;
}

#pragma mark - collection delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfSectionsInUploadImageContentView:)]) {
        return [self.delegate numberOfSectionsInUploadImageContentView:self];
    }else{
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *imageArray = self.imagesArray[section];
    return imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BLTImagePickerShowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUploadImageCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[BLTImagePickerShowCell alloc] init];
    }
    cell.imageCornerRadius = self.imageCornerRadius;
    cell.delegate = self;
    NSArray *imageArray = self.imagesArray[indexPath.section];
    BLTImagePickerShowModel *model = imageArray[indexPath.row];
    cell.model = model;
    if ([self.delegate respondsToSelector:@selector(willReturnImagePickerShowCell:atIndexPath:)]) {
        [self.delegate willReturnImagePickerShowCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && self.delegate && [self.delegate respondsToSelector:@selector(uploadImageContentView:headerViewAtSection:)]) {
        return [self.delegate uploadImageContentView:self headerViewAtSection:indexPath.section];
    }else if ([kind isEqualToString:UICollectionElementKindSectionFooter] && self.delegate && [self.delegate respondsToSelector:@selector(uploadImageContentView:footerViewAtSection:)]){
        return [self.delegate uploadImageContentView:self footerViewAtSection:indexPath.section];
    }
    
    id title = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadImageContentView:titleAtSection:)]) {
        title =  [self.delegate uploadImageContentView:self titleAtSection:indexPath.section];
    }
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && title) {
        BLTImagePickerSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kUploadImageSectionHeaderIdentifier forIndexPath:indexPath];
        headerView.title = title;
        return headerView;
    }else{
        return nil;
    }
}

-(CGSize)collectionView: (UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection: (NSInteger)section{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadImageContentView:sizeForHeaderViewAtSection:)]) {
        return [self.delegate uploadImageContentView:self sizeForHeaderViewAtSection:section];
    }
    
    NSString *title = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadImageContentView:titleAtSection:)]) {
        title =  [self.delegate uploadImageContentView:self titleAtSection:section];
    }
    if (title.length > 0) {
        return CGSizeMake(collectionView.bounds.size.width, 50);
    }else{
        return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadImageContentView:sizeForFooterViewAtSection:)]) {
        [self.delegate uploadImageContentView:self sizeForFooterViewAtSection:section];
    }
    return CGSizeZero;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(uploadImageContentView:shouldSelectItemAtIndexPath:)]) {
        return [self.delegate uploadImageContentView:self shouldSelectItemAtIndexPath:indexPath];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    BLTImagePickerShowModel *model = [self modelAtIndexPath:indexPath];
    if (model.isAddModel) {
        [self addModelClickAtIndexPath:indexPath addModel:model];
    }else if(model.isVideo){
        BLTImagePickerShowCell *cell = (BLTImagePickerShowCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [self imagePickerShowCellDidClickPlay:cell];
    }else{
        [self previewImageAtIndexPath:indexPath];
    }
}

#pragma mark - collectionView layout delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = self.countPerLine;
    CGFloat width = 0;
    CGFloat height = 0;
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        CGFloat itemSpacing = self.flowLayout.minimumLineSpacing;
        width = (CGRectGetWidth(collectionView.frame) - UIEdgeInsetsGetHorizontalValue(self.collectionView.contentInset) - itemSpacing * (row - 1)) / row;
        height = width/_imageProportion;
    }else{
        height = CGRectGetHeight(self.collectionView.frame);
        width = height * _imageProportion;
    }
    width = floorf(width);
    CGSize size = CGSizeMake(width, height);
    return size;
}

#pragma mark - collectionView 移动效果的
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath{
    //交换数据源
    [self.viewModel exchangeSourceIndexPath:sourceIndexPath destinationIndexPath:destinationIndexPath];
}



#pragma mark - 长按手势   拖拽的
- (void)longGestureHandler:(UILongPressGestureRecognizer *)longGesture{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSIndexPath *beginIndexPath = [self.collectionView indexPathForItemAtPoint:[longGesture locationInView:self.collectionView]];
            self.startExchangeCell = (BLTImagePickerShowCell *)[self.collectionView cellForItemAtIndexPath:beginIndexPath];
            [self startExchangeAnimating];
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:beginIndexPath];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [longGesture locationInView:self.collectionView];
            [self.collectionView updateInteractiveMovementTargetPosition:point];
        }
            break;
        case UIGestureRecognizerStateEnded:{
            [self.collectionView endInteractiveMovement];
            [self endExchangeAnimating];
        }
            break;
        default:
        {
            [self.collectionView cancelInteractiveMovement];
            [self endExchangeAnimating];
        }
            break;
    }
#pragma clang diagnostic pop
}

- (void)startExchangeAnimating{
    self.startExchangeCell.transform = CGAffineTransformMakeScale(1.15, 1.15);
}

- (void)endExchangeAnimating{
    self.startExchangeCell.transform = CGAffineTransformIdentity;
}

#pragma mark - 选择图片上传
- (void)addModelClickAtIndexPath:(NSIndexPath *)indexPath addModel:(BLTImagePickerShowModel *)addModel{
    if (self.processingVideo) {
        [self showTipContent:@"视频处理中~，请稍等" autoDismiss:YES];
        return;
    }
    //剩余选择照片的数量
    NSInteger leftCount = [self.viewModel leftMaxImageCountAtIndexPath:indexPath];
    //1.判断是否达到上限
    if (leftCount <= 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(uploadImageContentView:outOfMaxCountAtSection:)]) {
            [self.delegate uploadImageContentView:self outOfMaxCountAtSection:indexPath.section];
        }
        [self showTipContent:@"超过最大个数限制了哦~" autoDismiss:YES];
        return;
    }
    //判断是否有图库权限，没有返回
    [BLTSystemPermissionManager checkHasPhotoLibraryPermission:^(BOOL hasPermission) {
        if (hasPermission) {
            if ((addModel.addTypeOptions & BLTImagePickerShowModelAddTypeOptionsPhotoLibrary) || (addModel.addTypeOptions & BLTImagePickerShowModelAddTypeOptionsVideoLibrary)) {
                [self selectImagePickerVCType:addModel.addTypeOptions indexPath:indexPath leftCount:leftCount videoMaxSecond:addModel.maxVideoTime];
            }
            else if ((addModel.addTypeOptions & BLTImagePickerShowModelAddTypeOptionsPhotoCamera) || (addModel.addTypeOptions & BLTImagePickerShowModelAddTypeOptionsVideoCamera)) {
                [BLTSystemPermissionManager checkHasCameraPermission:^(BOOL hasPermission) {
                    if (hasPermission) {
                        [self selectImagePickerVCType:addModel.addTypeOptions indexPath:indexPath leftCount:leftCount videoMaxSecond:addModel.maxVideoTime];
                    }
                } tipController:self.currentVC];
            }
        }
    } tipController:self.currentVC];
}



- (void)selectImagePickerVCType:(BLTImagePickerShowModelAddTypeOptions)addTypeOptions indexPath:(NSIndexPath *)indexPath leftCount:(NSInteger)leftCount videoMaxSecond:(NSTimeInterval)videoMaxSecond{
    TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc] init];
    imagePickerVC.barItemTextColor = self.currentVC.navigationController.navigationBar.tintColor;
    imagePickerVC.statusBarStyle = self.currentVC.preferredStatusBarStyle;
    imagePickerVC.videoMaximumDuration = self.videoMaximumDuration;
    
    //注意pick在take前面  不然take会被重置
    if (addTypeOptions & BLTImagePickerShowModelAddTypeOptionsPhotoLibrary) {
        imagePickerVC.allowPickingImage = YES;
    }else{
        imagePickerVC.allowPickingImage = NO;
    }
    
    if (addTypeOptions & BLTImagePickerShowModelAddTypeOptionsPhotoCamera) {
        imagePickerVC.allowTakePicture = YES;
    }else{
        imagePickerVC.allowTakePicture = NO;
    }
    
    
    if (addTypeOptions & BLTImagePickerShowModelAddTypeOptionsVideoLibrary) {
        imagePickerVC.allowPickingVideo = YES;
    }else{
        imagePickerVC.allowPickingVideo = NO;
    }
    
    if (addTypeOptions & BLTImagePickerShowModelAddTypeOptionsVideoCamera) {
        imagePickerVC.allowTakeVideo = YES;
    }else{
        imagePickerVC.allowTakeVideo = NO;
    }
    
    
    BOOL onlyCameraPicture = imagePickerVC.allowTakePicture && imagePickerVC.allowPickingImage == NO;
    BOOL onlyCameraVideo = imagePickerVC.allowTakeVideo && imagePickerVC.allowPickingVideo == NO;
    //处理只拍照  或则只能拍视频 第三方库不支持的
    self.addImageSelectIndexPath = indexPath;
    if (onlyCameraPicture && onlyCameraVideo) {
        [self openCameraControllerTakeImage:YES takeVideo:YES];
        return;
    }else if (onlyCameraPicture){
        [self openCameraControllerTakeImage:YES takeVideo:NO];
        return;
    }else if(onlyCameraVideo){
        [self openCameraControllerTakeImage:NO takeVideo:YES];
        return;
    }else{
        self.addImageSelectIndexPath = nil;
    }
    
    imagePickerVC.maxImagesCount = leftCount;
    [imagePickerVC setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        BLT_WS(weakSelf);
        [self.viewModel addWaitingUploadImages:photos indexPath:indexPath addIndexPaths:^(NSArray<NSIndexPath *> *indexPaths) {
            [weakSelf p_didChangeImageVideoCount];
            NSIndexSet *reloadSectionSet = [NSIndexSet indexSetWithIndex:indexPath.section];
            [weakSelf.collectionView reloadSections:reloadSectionSet];
            [weakSelf.collectionView layoutIfNeeded];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull newIndexPath, NSUInteger idx, BOOL * _Nonnull stop) {
                [weakSelf uploadImageToOssAtIndexPath:newIndexPath];
            }];
        } autoDismissTakePhoto:self.autoDismissTakePhoto];
        
    }];
    
    [imagePickerVC setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {
        if (asset.duration > videoMaxSecond + 1) {
            [self showTipContent:[NSString stringWithFormat:@"视频最大长度不得超过%zd秒哦~",(NSInteger)videoMaxSecond] autoDismiss:YES];
            return ;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(startExportVideoUploadImageContentView:)]) {
            [self.delegate startExportVideoUploadImageContentView:self];
        }
        [self showTipContent:@"处理中" autoDismiss:NO];
        self.processingVideo = YES;
        [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:[self.viewModel presetNameFromVideoQuality:self.videoQuality] success:^(NSString *outputPath) {
            [self hiddenTipView];
            //           outputPath = [NSString stringWithFormat:@"file://%@",outputPath];
//            [self getVideoTimeByUrlString:outputPath];
            BLT_LOG(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
            BLT_WS(weakSelf);
            [self.viewModel addWaitingUploadVideos:coverImage localVideoPath:outputPath indexPath:indexPath addIndexPath:^(NSIndexPath *addIndexPath) {
                [weakSelf p_didChangeImageVideoCount];
                NSIndexSet *reloadSectionSet = [NSIndexSet indexSetWithIndex:indexPath.section];
                [weakSelf.collectionView reloadSections:reloadSectionSet];
                [weakSelf.collectionView layoutIfNeeded];
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(uploadImageContentView:coverImage:videoPath:)]) {
                    [weakSelf.delegate uploadImageContentView:weakSelf coverImage:coverImage videoPath:outputPath];
                }else{
                    [weakSelf uploadVideoToOSSAtIndexPath:addIndexPath videoPath:outputPath coverImage:coverImage];
                }
            }];
            self.processingVideo = NO;
        } failure:^(NSString *errorMessage, NSError *error) {
            //处理第三方失败回调不是在主线程的情况
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(uploadImageContentView:failedError:)]) {
                    [self.delegate uploadImageContentView:self failedError:error];
                }
            });
            self.processingVideo = NO;
        }];
        
    }];
    
    [self.currentVC presentViewController:imagePickerVC animated:YES completion:nil];
}

//获取视频信息
- (NSInteger)getVideoTimeByUrlString:(NSString *)urlString {
    NSURL *videoUrl = [NSURL fileURLWithPath:urlString];
    if (videoUrl == nil) {
        return 0;
    }
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:videoUrl];
    CMTime time = [avUrl duration];
    int seconds = ceil(time.value/time.timescale);
    
    CGSize size111 = [[[avUrl tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
    
    NSNumber *fileSizeBytes;
    [videoUrl getResourceValue:&fileSizeBytes forKey:NSURLFileSizeKey error:nil];
    NSInteger   fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:urlString error:nil].fileSize;
    NSLog(@"LBLog size111 ,size %@ %@ %@",@(size111), fileSizeBytes, @(fileSize));
    return seconds;
}

- (void)openCameraControllerTakeImage:(BOOL)takeImage takeVideo:(BOOL)takeVideo{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.delegate = self;
        pickerController.sourceType = sourceType;
        pickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
        NSMutableArray *mediaTypes = [NSMutableArray array];
        if (takeVideo) {
            [mediaTypes addObject:(NSString *)kUTTypeMovie];
        }
        if (takeImage) {
            [mediaTypes addObject:(NSString *)kUTTypeImage];
        }
        if (mediaTypes.count) {
            pickerController.mediaTypes = mediaTypes;
        }
        [self.currentVC presentViewController:pickerController animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//        NSDictionary *meta = [info objectForKey:UIImagePickerControllerMediaMetadata];
        // save photo and get asset / 保存图片，获取到asset
        if (self.addImageSelectIndexPath && image) {
            BLT_WS(weakSelf);
            [self.viewModel addWaitingUploadImages:@[image] indexPath:self.addImageSelectIndexPath addIndexPaths:^(NSArray<NSIndexPath *> *indexPaths) {
                NSIndexSet *reloadSectionSet = [NSIndexSet indexSetWithIndex:weakSelf.addImageSelectIndexPath.section];
                [weakSelf.collectionView reloadSections:reloadSectionSet];
                [weakSelf.collectionView layoutIfNeeded];
                [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull newIndexPath, NSUInteger idx, BOOL * _Nonnull stop) {
                    [weakSelf uploadImageToOssAtIndexPath:newIndexPath];
                }];
            } autoDismissTakePhoto:self.autoDismissTakePhoto];
        }
    } else if ([type isEqualToString:@"public.movie"]) {
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        UIImage *thumbImg = [self.viewModel getVideoThumbWithURL:videoUrl];
        if (videoUrl) {
            BLT_WS(weakSelf);
            [self.viewModel addWaitingUploadVideos:thumbImg localVideoPath:videoUrl.path indexPath:self.addImageSelectIndexPath addIndexPath:^(NSIndexPath *addIndexPath) {
                NSIndexSet *reloadSectionSet = [NSIndexSet indexSetWithIndex:weakSelf.addImageSelectIndexPath.section];
                [weakSelf.collectionView reloadSections:reloadSectionSet];
                [weakSelf.collectionView layoutIfNeeded];
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(uploadImageContentView:coverImage:videoPath:)]) {
                    [weakSelf.delegate uploadImageContentView:weakSelf coverImage:nil videoPath:videoUrl.path];
                }else{
                    [weakSelf uploadVideoToOSSAtIndexPath:addIndexPath videoPath:videoUrl.path coverImage:thumbImg];
                }
            }];
        }
    }
}


- (void)uploadImageToOssAtIndexPath:(NSIndexPath *)indexPath{
    BLTImagePickerShowModel *model = [self modelAtIndexPath:indexPath];
    if (model.isAddModel) {
        return;
    }
    if (model.state != BLTImagePickerShowModelStateWaitingUpload && model.state != BLTImagePickerShowModelStateUploadFailed) {
        return;
    }
    NSData *data = [self.viewModel compressImageToMaxSizeKB:self.scaleToKBSize image:model.image];
    
    BLTImagePickerShowCell *cell = (BLTImagePickerShowCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    //使用自定义上传任务的   不使用默认的OSS上传
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadImageContentView:customUploadImageAtIndexPath:image:imageModel:uploadImageCell:)]) {
        BOOL flag = [self.delegate uploadImageContentView:self customUploadImageAtIndexPath:indexPath image:model.image imageModel:model uploadImageCell:cell];
        if (flag) {
            return;
        }
    }
    
    //不使用自定义上传  使用OSS上传
    if (!self.ossConfigModel) {
        [self showTipContent:@"请设置OSSConfigModel，退出后再试" autoDismiss:YES];
        model.state = BLTImagePickerShowModelStateUploadFailed;
        cell.model = model;
        return;
    }
    
    BLT_WS(weakSelf);
    NSString *uploadImageName = [self.viewModel randomUploadImageNameAtIndex:indexPath.row];
    model.imageOSSName = uploadImageName;
    //使用默认OSS上传的
    [self.uploadManager refreshClientWithConfigModel:self.ossConfigModel];
    [self.uploadManager ossUploadImageData:data objectKey:uploadImageName successBlock:^(NSString *uploadOSSURL){
        model.state = BLTImagePickerShowModelStateUploadSuccess;
        model.imageUrlString = uploadOSSURL;
        cell.model = model;
        //刷新OSSImageNames
        [weakSelf p_uploadSuccessCallBackAtIndexPath:indexPath];
    } progressBlock:^(CGFloat progress) {
        [cell setUploadProgress:progress];
    } failureBlock:^(NSError *error) {
        model.state = BLTImagePickerShowModelStateUploadFailed;
        model.imageOSSName = nil;
        cell.model = model;
        [weakSelf p_uploadFailureCallBackAtIndexPath:indexPath];
    }];
}

- (void)uploadVideoToOSSAtIndexPath:(NSIndexPath *)indexPath videoPath:(NSString *)videoPath coverImage:(UIImage *)coverImage{
    BLTImagePickerShowModel *model = [self modelAtIndexPath:indexPath];
    if (model.isAddModel) {
        return;
    }
    if ((model.state != BLTImagePickerShowModelStateUploadFailed && model.state == BLTImagePickerShowModelStateUploadFailed) || (videoPath.length == 0) ) {
        return;
    }
    BLTImagePickerShowCell *cell = (BLTImagePickerShowCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    //使用自定义的上传方法
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadImageContentView:customUploadVideoAtIndexPath:videoPath:coverImage:videoModel:uploadVideoCell:)]) {
        BOOL flag = [self.delegate uploadImageContentView:self customUploadVideoAtIndexPath:indexPath videoPath:videoPath coverImage:coverImage videoModel:model uploadVideoCell:cell];
        if (flag) {
            return;
        }
    }
    
    //不使用自定义上传  使用OSS上传
    if (!self.ossConfigModel) {
        [self showTipContent:@"请设置OSSConfigModel，退出后再试" autoDismiss:YES];
        return;
    }
    
    BLT_WS(weakSelf);
    //使用默认的OSS上传视频 和缩略图的
    NSString *videoRandomName = [self.viewModel randomUploadVideoNameAtIndex:indexPath.row];
    model.videoOSSName = videoRandomName;
    [self.uploadManager refreshClientWithConfigModel:self.ossConfigModel];
    [self.uploadManager ossUploadDataUrl:videoPath objectKey:videoRandomName successBlock:^(NSString *uploadOSSURL){
        model.state = BLTImagePickerShowModelStateUploadSuccess;
        model.imageUrlString = uploadOSSURL;
        cell.model = model;
        [weakSelf p_uploadSuccessCallBackAtIndexPath:indexPath];
    } progressBlock:^(CGFloat progress) {
        [cell setUploadProgress:progress];
    } failureBlock:^(NSError *error) {
        model.state = BLTImagePickerShowModelStateUploadFailed;
        cell.model = model;
        [weakSelf p_uploadFailureCallBackAtIndexPath:indexPath];
    }];
    if (self.uploadVideoCoverImage) {
        //上传封面图
        NSData *data = [self.viewModel compressImageToMaxSizeKB:self.scaleToKBSize image:model.image];
        NSString *uploadImageName = [self.viewModel randomUploadImageNameAtIndex:indexPath.row];
        model.imageOSSName = uploadImageName;
        [self.uploadManager ossUploadImageData:data objectKey:uploadImageName successBlock:^(NSString *uploadOSSURL){
        } progressBlock:^(CGFloat progress) {
            
        } failureBlock:^(NSError *error) {
            
        }];
    }
}


#pragma mark - 预览图片
//预览图片
- (void)previewImageAtIndexPath:(NSIndexPath *)indexPath{
    self.previewCurrentIndexPath = indexPath;
    BLTImagePickerShowModel *firstModel = self.imagesArray[indexPath.section].firstObject;
    if ([self.delegate respondsToSelector:@selector(uploadImageContentView:previewImageArray:currentIndex:)]) {
        [self.delegate uploadImageContentView:self previewImageArray:self.imagesArray[indexPath.section].copy currentIndex:indexPath.row];
        return;
    }

    BLT_WS(weakSelf);
    [self.viewModel previewImagesAtIndexPath:indexPath successBlock:^(NSArray *imageArray, NSInteger currentIndex, BOOL hasVideo) {
        [weakSelf.currentVC blt_previewImage:imageArray currentIndex:currentIndex];
    }];
}

//- (void)imagePreviewController:(BLTImagePreviewController *)imagePreviewController didDeleteAtIndex:(NSInteger)index{
//    NSArray <BLTImagePickerShowModel *>*sectionArray = self.imagesArray[self.previewCurrentIndexPath.section];
//    NSInteger row = sectionArray.firstObject.isAddModel ? index + 1 : index ;
//    NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:row inSection:self.previewCurrentIndexPath.section];
//    BLTImagePickerShowModel *deleteModel = [self.viewModel deletePhotoAtIndexPath:deleteIndexPath];
//    [self.collectionView deleteItemsAtIndexPaths:@[deleteIndexPath]];
//    [self p_didDeleteAtIndexPath:deleteIndexPath deleteModel:deleteModel];
//}

#pragma mark - cell click delegate
//点击选择图片
- (void)imagePickerShowCellDidClickSelect:(BLTImagePickerShowCell *)cell{
    cell.model.selected = !cell.model.selected;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
}
//点击删除图片
- (void)imagePickerShowCellDidClickDelete:(BLTImagePickerShowCell *)cell{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSMutableArray *array = self.viewModel.dataSources[indexPath.section];
    BLTImagePickerShowModel *model = array[indexPath.row];
    if (model.state == BLTImagePickerShowModelStateUploading) {
        [self showTipContent:@"正在上传哦~，暂不可以删除" autoDismiss:YES];
        return;
    }
    
    BLTImagePickerShowModel *deleteModel = [self.viewModel deletePhotoAtIndexPath:indexPath];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    [self p_didDeleteAtIndexPath:indexPath deleteModel:deleteModel];
    [self p_didChangeImageVideoCount];
}
//上传失败重试
- (void)imagePickerShowCellDidClickFailed:(BLTImagePickerShowCell *)cell{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"重新上传该图片" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"上传" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        [self uploadImageToOssAtIndexPath:indexPath];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:sureAction];
    [self.currentVC presentViewController:alertVC animated:YES completion:nil];
}
//点击视频播放
- (void)imagePickerShowCellDidClickPlay:(BLTImagePickerShowCell *)cell{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    BLTImagePickerShowModel *model = self.imagesArray[indexPath.section][indexPath.row];
    if ([self.delegate respondsToSelector:@selector(uploadImageContentView:previewVideoUrl:)]) {
        [self.delegate uploadImageContentView:self previewVideoUrl:model.videoURL];
    }else{
        BLTVideoPreviewController *playVideoVC = [[BLTVideoPreviewController alloc] initWithVideoUrl:model.videoURL];
        [self.currentVC presentViewController:playVideoVC animated:YES completion:nil];
    }
}

- (BLTImagePickerShowModel *)modelAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = self.imagesArray[indexPath.section];
    BLTImagePickerShowModel *model = array[indexPath.row];
    return model;
}

- (BOOL)hasUnUploadImage{
    return [self.viewModel hasWaitingForUploadImage];
}

//设置图片原型 转模型
- (void)setPhotosArray:(NSArray <NSArray *>*)photosArray onlyShow:(BOOL)onlyShow{
    _photosArray = photosArray;
    if (photosArray == nil) {
        self.imagesArray = nil;
        return;
    }
    NSMutableArray *outArray = @[].mutableCopy;
    [photosArray enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *innerArray = @[].mutableCopy;
        [obj enumerateObjectsUsingBlock:^(id  _Nonnull obj2, NSUInteger idx2, BOOL * _Nonnull stop2) {
            BLTImagePickerShowModel *model = [[BLTImagePickerShowModel alloc] init];
            model.state = onlyShow ? BLTImagePickerShowModelStateNormalShow : BLTImagePickerShowModelStateUploadSuccess;
            if ([obj2 isKindOfClass:[UIImage class]]) {
                model.image = obj2;
            }else if ([obj2 isKindOfClass:[NSString class]] && [obj2 hasPrefix:@"http"]){
                model.imageUrlString = obj2;
            }else{
                model.imageUrlString = obj2;
            }
            [innerArray addObject:model];
        }];
        [outArray addObject:innerArray];
    }];
    self.imagesArray = outArray.mutableCopy;
    BLT_LOG(@"LBLog -------- %@ ",self.imagesArray);
}

- (void)setImagesArray:(NSMutableArray<NSMutableArray<BLTImagePickerShowModel *> *> *)imagesArray{
    _imagesArray = imagesArray;
    [self.imagesArray enumerateObjectsUsingBlock:^(NSMutableArray<BLTImagePickerShowModel *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.viewModel leftMaxImageCountAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:idx]] > 0 && !self.imagesArray[idx].firstObject.isAddModel && self.style == BLTUploadImageContentViewStyleUpload) {
            BLTImagePickerShowModel *addModel = [BLTImagePickerShowModel addModel];
            [obj insertObject:addModel atIndex:0];
        }
    }];
    self.viewModel.dataSources = _imagesArray;
    [self.collectionView reloadData];
}

- (void)setImageCornerRadius:(CGFloat)imageCornerRadius
{
    _imageCornerRadius = imageCornerRadius;
    [self.collectionView reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGSizeEqualToSize(self.collectionView.bounds.size, self.bounds.size)) {
        self.collectionView.frame = self.bounds;
    }
}

- (void)refreshOSSConfigModel:(BLTOSSConfigModel *)OSSModel{
    self.ossConfigModel = OSSModel;
}

- (void)showTipContent:(NSString *)tipContent autoDismiss:(BOOL)autoDismiss{
    if (self.tipAnimating) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTipView) object:nil];
    }
    if (tipContent) {
        self.tipAnimating = YES;
        self.tipLabel.text = tipContent;
        CGSize size = [self.tipLabel sizeThatFits:CGSizeMake(self.blt_width - 80, self.blt_height - 20)];
        CGFloat width = size.width + 40;
        CGFloat height = size.height + 20;
        self.tipLabel.frame = CGRectMake(self.blt_width/2 - width/2, self.blt_height/2 - height /2, width, height);
        self.tipLabel.hidden = NO;
        [self performSelector:@selector(hiddenTipView) withObject:nil afterDelay:1.5];
    }
}

- (void)hiddenTipView{
    self.tipLabel.hidden = YES;
    self.tipAnimating = NO;
}


- (void)p_uploadSuccessCallBackAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadImageContentView:uploadSuccessAtIndexPath:)]) {
        [self.delegate uploadImageContentView:self uploadSuccessAtIndexPath:indexPath];
    }
}

- (void)p_uploadFailureCallBackAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadImageContentView:uploadFailureAtIndexPath:)]) {
        [self.delegate uploadImageContentView:self uploadFailureAtIndexPath:indexPath];
    }
}

- (void)p_didDeleteAtIndexPath:(NSIndexPath *)indexPath deleteModel:(BLTImagePickerShowModel *)deleteModel{
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadImageContentView:didDeleteAtIndexPath:deleteModel:)]) {
        [self.delegate uploadImageContentView:self didDeleteAtIndexPath:indexPath deleteModel:deleteModel];
    }
}

- (void)p_didChangeImageVideoCount{
    if([self.delegate respondsToSelector:@selector(uploadImageContentViewImageVideoCountChange:)]){
        [self.delegate uploadImageContentViewImageVideoCountChange:self];
    }
}

#pragma mark - 获取OSS上传的名称
- (NSArray *)imageOSSNames{
    NSMutableArray *OSSNames = @[].mutableCopy;
    [self.viewModel everyModelInDataSourcesExecuteBlock:^(BLTImagePickerShowModel *model) {
        if (model.imageOSSName.length > 0 && !model.isVideo && model.state == BLTImagePickerShowModelStateUploadSuccess) {
            [OSSNames addObject:model.imageOSSName];
        }
    }];
    return OSSNames.copy;
}

- (NSArray *)imageOSSURLFullPaths{
    NSMutableArray *OSSNames = @[].mutableCopy;
    [self.viewModel everyModelInDataSourcesExecuteBlock:^(BLTImagePickerShowModel *model) {
        if (model.imageUrlString.length > 0 && !model.isVideo && model.state == BLTImagePickerShowModelStateUploadSuccess) {
            [OSSNames addObject:model.imageUrlString];
        }
    }];
    return OSSNames.copy;
}

- (NSArray *)videoCoverImageOSSNames{
    NSMutableArray *OSSNames = @[].mutableCopy;
    [self.viewModel everyModelInDataSourcesExecuteBlock:^(BLTImagePickerShowModel *model) {
        if (model.imageOSSName.length > 0 && model.isVideo && model.state == BLTImagePickerShowModelStateUploadSuccess) {
            [OSSNames addObject:model.imageOSSName];
        }
    }];
    return OSSNames.copy;
}

- (NSArray *)videoOSSNames{
    NSMutableArray *OSSNames = @[].mutableCopy;
    [self.viewModel everyModelInDataSourcesExecuteBlock:^(BLTImagePickerShowModel *model) {
        if (model.videoOSSName.length > 0 && model.isVideo && model.state == BLTImagePickerShowModelStateUploadSuccess) {
            [OSSNames addObject:model.videoOSSName];
        }
    }];
    return OSSNames.copy;
}


- (void)setOssConfigBlock:(BLTOSSConfigModel *(^)(void))ossConfigBlock{
    _ossConfigBlock = ossConfigBlock;
    if (self.ossConfigBlock) {
        self.ossConfigBlock();
    }
}

- (void)setMaxUploadImageCount:(NSInteger)maxUploadImageCount{
    _maxUploadImageCount = maxUploadImageCount;
    self.viewModel.maxUploadImageCount = maxUploadImageCount;
}

#pragma mark - lazy load
- (BLTUploadImageContentViewViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[BLTUploadImageContentViewViewModel alloc] init];
        _viewModel.dataSources = self.imagesArray;
        _viewModel.delegate = self.delegate;
        _viewModel.maxUploadImageCount = self.maxUploadImageCount;
    }
    return _viewModel;
}

- (BLTAliOSSUploadManager *)uploadManager{
    if (!_uploadManager) {
        _uploadManager = [[BLTAliOSSUploadManager alloc] init];
    }
    return _uploadManager;
}

- (UIViewController *)currentVC{
    if (!_currentVC) {
        _currentVC = [self blt_getCurrentControllerFromSelf];
    }
    return _currentVC;
}

- (NSMutableArray<NSMutableArray<BLTImagePickerShowModel *> *> *)imagesArray{
    if (!_imagesArray) {
        _imagesArray = [[NSMutableArray alloc] init];
        NSInteger section = [self numberOfSectionsInCollectionView:self.collectionView];
        for (int i = 0; i < section; i ++) {
            NSMutableArray *innerArray = @[].mutableCopy;
            [innerArray addObject:[BLTImagePickerShowModel addModel]];
            [_imagesArray addObject:innerArray];
        }
    }
    return _imagesArray;
}

- (BLTOSSConfigModel *)ossConfigModel{
    if (!_ossConfigModel) {
        if (self.ossConfigBlock) {
            _ossConfigModel = self.ossConfigBlock();
        }
        if (!_ossConfigModel && self.delegate && [self.delegate respondsToSelector:@selector(noOSSConfigProvideUploadImageContentView:)]) {
            [self.delegate noOSSConfigProvideUploadImageContentView:self];
        }
        //        NSAssert(NO, @"LBLog please provide ossConfigModel =====");
    }
    return _ossConfigModel;
}


#pragma mark - 队列上传用的
- (void)addUploadTaskByIndexPaths:(NSArray <NSIndexPath *>*)array{
    [self.uploadTaskArray addObjectsFromArray:array];
    [self startUploadTask];
}

//开始上传任务  用队列一个一个上传的
- (void)startUploadTask{
    if (self.uploadTaskArray.count == 0) {
        return;
    }
    
}

//移除最近上传的任务
- (void)removeLastTaskAtIndexPath:(NSIndexPath *)indexPath{
    [self.uploadTaskArray removeObject:indexPath];
}


#pragma mark - 自适应高度的
- (void)addCollectionObserver{
    [_collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    hasAddObserver = true;
    [self addConstraint:self.autoHeightConstraint];
}

- (void)removeCollectionObserver{
    [_collectionView removeObserver:self forKeyPath:@"contentSize"];
    hasAddObserver = false;
    [self removeConstraint:self.autoHeightConstraint];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGSize size = [change[NSKeyValueChangeNewKey] CGSizeValue];
        if (floorf(self.collectionView.bounds.size.height) == floorf(size.height)) {
            return;
        }
        self.collectionView.blt_height = size.height;
    }
}


- (NSMutableArray<NSIndexPath *> *)uploadTaskArray{
    if (!_uploadTaskArray) {
        _uploadTaskArray = @[].mutableCopy;
    }
    return _uploadTaskArray;
}

- (UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.backgroundColor = [UIColor blackColor];
        _tipLabel.numberOfLines = 0;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.layer.cornerRadius = 10;
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.font = UIFontPFFontSize(16);
        _tipLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 80;
        _tipLabel.clipsToBounds = YES;
        [self addSubview:_tipLabel];
    }
    return _tipLabel;
}

- (NSLayoutConstraint *)autoHeightConstraint{
    if (!_autoHeightConstraint) {
        _autoHeightConstraint = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        _autoHeightConstraint.priority = UILayoutPriorityDefaultLow;
    }
    return _autoHeightConstraint;
}

- (void)dealloc{
    if (hasAddObserver) {
        [self removeCollectionObserver];
    }
}

@end
