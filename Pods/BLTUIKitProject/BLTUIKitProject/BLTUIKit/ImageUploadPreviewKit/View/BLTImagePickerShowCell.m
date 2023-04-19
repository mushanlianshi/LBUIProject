//
//  BLTImagePickerShowCell.m
//  BLTUIKitProject_Example
//
//  Created by liu bin on 2020/3/24.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import "BLTImagePickerShowCell.h"
#import "BLTImagePickerShowModel.h"
#import <BLTBasicUIKit/BLTBasicUIKit.h>
#import "BLTUICommonDefines.h"
#import "UIImageView+WebCache.h"
#import "BLTCircleProgressView.h"
#import "BLTCustomImageTitleButton.h"

@implementation BLTImagePickerShowCellConfig

static BLTImagePickerShowCellConfig *configAppearance;
+ (instancetype)appearance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configAppearance = [BLTImagePickerShowCellConfig new];
        configAppearance.pleaceHolderImage = UIImageNamedFromBLTUIKItBundle(@"blt_placeholder");
        configAppearance.addImage = UIImageNamedFromBLTUIKItBundle(@"blt_upload_image_take_photo");
        configAppearance.unselectimage = UIImageNamedFromBLTUIKItBundle(@"public_blue_unselected");
        configAppearance.selectImage = UIImageNamedFromBLTUIKItBundle(@"public_blue_selected");
        configAppearance.deleteImage = UIImageNamedFromBLTUIKItBundle(@"blt_upload_image_delete");
        configAppearance.failedImage = UIImageNamedFromBLTUIKItBundle(@"blt_upload_image_failed");
        configAppearance.playImage = UIImageNamedFromBLTUIKItBundle(@"blt_upload_image_play_video");
    });
    return configAppearance;
}

+ (void)initialize{
    [self appearance];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize{
    self.pleaceHolderImage = configAppearance.pleaceHolderImage;
    self.addImage = configAppearance.addImage;
    self.unselectimage = configAppearance.unselectimage;
    self.selectImage = configAppearance.selectImage;
    self.deleteImage = configAppearance.deleteImage;
    self.failedImage = configAppearance.failedImage;
    self.playImage = configAppearance.playImage;
    self.customSensorDataBlock = configAppearance.customSensorDataBlock;
}


@end


@interface BLTImagePickerShowCell ()

//右上角删除或则选择的图片
@property (nonatomic, strong) BLTUIResponseAreaButton *deleteOrSelectButton;
//中间上传失败的按钮
@property (nonatomic, strong) BLTCustomImageTitleButton *failedPlayButton;
//播放视频的按钮
@property (nonatomic, strong) UIButton *playVideoButton;

//上传进度的view
@property (nonatomic, strong) BLTCircleProgressView *progressView;

@end

@implementation BLTImagePickerShowCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.hidden = NO;
        self.progressView.hidden = YES;
        self.failedPlayButton.hidden = YES;
        self.playVideoButton.hidden = YES;
        self.deleteOrSelectButton.hidden = YES;
        if (self.cellConfig.customSensorDataBlock) {
            self.cellConfig.customSensorDataBlock(_deleteOrSelectButton, _failedPlayButton, _playVideoButton);
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
    
    CGFloat selectW = self.deleteOrSelectButton.currentImage.size.width;
    CGFloat selectH = self.deleteOrSelectButton.currentImage.size.height;
    _failedPlayButton.frame = self.bounds;
    _playVideoButton.frame = self.bounds;
    self.deleteOrSelectButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 5 - selectW, 5, selectW, selectH);
    self.progressView.frame = self.contentView.bounds;
}


- (void)setModel:(BLTImagePickerShowModel *)model{
    _model = model;
    if (model.isAddModel) {
        if (model.image) {
            self.imageView.image = model.image;
        }else{
            self.imageView.image = self.cellConfig.addImage;
        }
        self.playVideoButton.hidden = YES;
        [self hiddenActionSubviews];
        return;
    }
    self.playVideoButton.hidden = !model.isVideo;
    if (model.image) {
        self.imageView.image = model.image;
    }else if (model.imageUrlString){
        BLT_WS(weakSelf);
        //防止刷新导致图片变成了add模型
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.imageUrlString] placeholderImage:self.cellConfig.pleaceHolderImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (weakSelf.model.isAddModel) {
                weakSelf.imageView.image = self.cellConfig.addImage;
            };
        }];
    }else{
        self.imageView.image = self.cellConfig.pleaceHolderImage;
    }
    switch (model.state) {
        case BLTImagePickerShowModelStateNormalShow:
            [self normalModelShowContent];
            break;
        case BLTImagePickerShowModelStateUploading:
            [self uploadImagelIngModelShowContent];
            break;
        case BLTImagePickerShowModelStateUploadFailed:
            [self uploadFailedModelShowContent];
            break;
        case BLTImagePickerShowModelStateWaitingUpload:
        case BLTImagePickerShowModelStateUploadSuccess:
        case BLTImagePickerShowModelStateDeleting:
            [self deleteModelShowContent];
            break;
        case BLTImagePickerShowModelStateSelect:
            [self selectModelShowContent];
            break;
            
        default:
            break;
    }
}

- (void)setUploadProgress:(CGFloat)uploadProgress{
    if (_failedPlayButton.hidden == NO) {
        _failedPlayButton.hidden = YES;
    }
    self.deleteOrSelectButton.hidden = YES;
    if (self.model.state == BLTImagePickerShowModelStateUploadSuccess) {
        if (self.model.isVideo) {
            self.playVideoButton.hidden = NO;
        }
        self.deleteOrSelectButton.hidden = NO;
        return;
    }
    uploadProgress = fmin(uploadProgress, 1);
    uploadProgress = fmax(uploadProgress, 0);
    _uploadProgress = uploadProgress;
    self.progressView.progress = uploadProgress;
    self.playVideoButton.hidden = YES;
    if (self.progressView.hidden) {
        [self.progressView refreshBackgroundCircle];
    }
    self.progressView.hidden = NO;
}

- (void)setImageCornerRadius:(CGFloat)imageCornerRadius
{
    _imageCornerRadius = imageCornerRadius;
    self.imageView.layer.cornerRadius = imageCornerRadius;
}

- (void)hiddenActionSubviews{
    _failedPlayButton.hidden = YES;
    _deleteOrSelectButton.hidden = YES;
    _progressView.hidden = YES;
}

//正常显示内容UI
- (void)normalModelShowContent{
    _deleteOrSelectButton.hidden = YES;
    if (self.model.isVideo) {
        self.failedPlayButton.hidden = NO;
        [self.failedPlayButton setImage:self.cellConfig.playImage forState:UIControlStateNormal];
        [self.failedPlayButton setTitle:nil forState:UIControlStateNormal];
    }else{
        _failedPlayButton.hidden = YES;
    }
}

//正在上传图片
- (void)uploadImagelIngModelShowContent{
    _failedPlayButton.hidden = YES;
    _deleteOrSelectButton.hidden = YES;
    self.progressView.hidden = NO;
}

//s
- (void)uploadFailedModelShowContent{
    _playVideoButton.hidden = YES;
    _progressView.hidden = YES;
    self.failedPlayButton.hidden = NO;
    [self.failedPlayButton setImage:self.cellConfig.failedImage forState:UIControlStateNormal];
    self.deleteOrSelectButton.hidden = NO;
    [self.deleteOrSelectButton setImage:self.cellConfig.deleteImage forState:UIControlStateNormal];
}

//删除模式下的展示
- (void)deleteModelShowContent{
    _progressView.hidden = YES;
    _failedPlayButton.hidden = YES;
    self.deleteOrSelectButton.hidden = NO;
    [self.deleteOrSelectButton setImage:self.cellConfig.deleteImage forState:UIControlStateNormal];
}

//选择模式下的展示
- (void)selectModelShowContent{
    _progressView.hidden = YES;
    self.deleteOrSelectButton.hidden = NO;
    UIImage *image = self.model.selected ? self.cellConfig.selectImage : self.cellConfig.unselectimage;
    [self.deleteOrSelectButton setImage:image forState:UIControlStateNormal];
}



#pragma mark - click event
- (void)deleteOrSelectButtonClicked{
    if (self.model.state == BLTImagePickerShowModelStateSelect){
        [self callBackSEL:@selector(imagePickerShowCellDidClickSelect:)];
    }else if (self.model.state == BLTImagePickerShowModelStateDeleting || self.model.state == BLTImagePickerShowModelStateUploadFailed || self.model.state == BLTImagePickerShowModelStateUploadSuccess || self.model.state == BLTImagePickerShowModelStateWaitingUpload || self.model.state == BLTImagePickerShowModelStateUploading){
        [self callBackSEL:@selector(imagePickerShowCellDidClickDelete:)];
    }
}

- (void)failedUploadButtonClicked{
    if (self.model.state == BLTImagePickerShowModelStateUploadFailed) {
        [self callBackSEL:@selector(imagePickerShowCellDidClickFailed:)];
    }else if (self.model.isVideo){
        [self callBackSEL:@selector(imagePickerShowCellDidClickPlay:)];
    }
}

- (void)playVideoButtonClicked{
    if (self.model.isVideo) {
        [self callBackSEL:@selector(imagePickerShowCellDidClickPlay:)];
    }
}


- (void)callBackSEL:(SEL)selector{
    if ([self.delegate respondsToSelector:selector]) {
        [self.delegate performSelector:selector withObject:self];
    }
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

- (BLTUIResponseAreaButton *)deleteOrSelectButton{
    if (!_deleteOrSelectButton) {
        _deleteOrSelectButton = [[BLTUIResponseAreaButton alloc] initWithResponseArea:UIEdgeInsetsMake(-10, -10, -10, -10)];
        [_deleteOrSelectButton addTarget:self action:@selector(deleteOrSelectButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_deleteOrSelectButton setImage:self.cellConfig.deleteImage forState:UIControlStateNormal];
        [self.contentView addSubview:_deleteOrSelectButton];
    }
    return _deleteOrSelectButton;
}

- (BLTCustomImageTitleButton *)failedPlayButton{
    if (!_failedPlayButton) {
        _failedPlayButton = [[BLTCustomImageTitleButton alloc] init];
        [_failedPlayButton addTarget:self action:@selector(failedUploadButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _failedPlayButton.backgroundColor = [UIColor clearColor];
        _failedPlayButton.titleLabel.font = UIFontPFFontSize(11);
        _failedPlayButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [_failedPlayButton setImage:self.cellConfig.failedImage forState:UIControlStateNormal];
        [_failedPlayButton setTitle:@"上传失败" forState:UIControlStateNormal];
        _failedPlayButton.imagePosition = BLTCustomButtonImagePositionTop;
        _failedPlayButton.imageTitleInnerMargin = 5;
        [self.contentView addSubview:_failedPlayButton];
    }
    return _failedPlayButton;
}

- (UIButton *)playVideoButton{
    if (!_playVideoButton) {
        _playVideoButton = [[UIButton alloc] init];
        [_playVideoButton setImage:self.cellConfig.playImage forState:UIControlStateNormal];
        [_playVideoButton addTarget:self action:@selector(playVideoButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_playVideoButton];
    }
    return _playVideoButton;
}


- (BLTCircleProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[BLTCircleProgressView alloc] init];
        _progressView.backgroundCircleColor = BLT_HEXCOLOR(0x333333);
        _progressView.progressCircleColor = [UIColor whiteColor];
        _progressView.circleWidth = 4;
        _progressView.circleRaduis = 15;
        [self.contentView addSubview:_progressView];
    }
    return _progressView;
}

- (BLTImagePickerShowCellConfig *)cellConfig{
    if (!_cellConfig) {
        _cellConfig = [[BLTImagePickerShowCellConfig alloc] init];
    }
    return _cellConfig;
}

@end
