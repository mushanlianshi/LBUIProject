//
//  LBTextRecogineViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/7/15.
//

#import "LBTextRecogineViewController.h"
#import <VisionKit/VisionKit.h>
#import <Vision/Vision.h>
#import "Masonry.h"
#import <BLTUIKitProject/BLTUI.h>
#import "TZImagePickerController.h"
#import "LLTextRecogineImageView.h"
#import "NSObject+AutoProperty.h"

@interface LBTextRecogineViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate, VNDocumentCameraViewControllerDelegate>

@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, assign) UIButton *chineseFirst;

@property (nonatomic, strong) UIButton *fileScanBtn;

@property (nonatomic, strong) LLTextRecogineImageView *imageContentView;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, strong) NSArray <UIImage *>*dataSources;

@property (nonatomic, assign) BOOL isRecogining;

@end

@implementation LBTextRecogineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"识别图中的文字";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择图片" style:UIBarButtonItemStyleDone target:self action:@selector(selectButtonClicked)];
    [self.view addSubview:self.imageContentView];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.chineseFirst];
    [self.view addSubview:self.fileScanBtn];
    [self.chineseFirst mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(70, 44));
    }];
    [self.fileScanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(70, 44));
    }];
    [self.imageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_offset(UIEdgeInsetsMake(40, 60, 0, 40));
        make.height.mas_equalTo(220);
    }];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(30);
        make.right.mas_offset(-30);
        make.top.mas_equalTo(self.imageContentView.mas_bottom).mas_offset(30);
        make.bottom.mas_equalTo(self.view).mas_offset(-BLT_SCREEN_BOTTOM_OFFSET).priorityLow();
    }];
}

- (void)startRecogineImage:(UIImage *)image resultBlock:(void(^)(NSString *resultText))resultBlock{
    if (image == nil) {
        return;
    }
    __block BOOL chineseFirst = NO;
    blt_dispatch_main_sync_safe(^{
        chineseFirst = self.chineseFirst.isSelected;
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (@available(iOS 13.0, *)) {
    //        public_icon  limit_discount_tag VNClassifiyImageRequest
            NSMutableString *tmpString = @"".mutableCopy;
            VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
            VNRecognizeTextRequest *textRequest = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
                if (error == nil) {
                    [request.results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        VNRecognizedTextObservation *textObservation = (VNRecognizedTextObservation *)obj;
                        NSArray * array = [textObservation topCandidates:1];
                        NSLog(@"LBLog textObservation %@ %@",@(textObservation.confidence), @(textObservation.boundingBox));
                        for (VNRecognizedText *text in array) {
                            [tmpString appendString:text.string];
                        }
                        [tmpString appendString:@"\n"];
                    }];
                    blt_dispatch_main_sync_safe(^{
                        [self refreshRecogineText:tmpString.copy];
                        if (resultBlock) {
                            resultBlock(tmpString.copy);
                        }
                    });
                }else{
                    blt_dispatch_main_sync_safe(^{
                        [self refreshRecogineText:tmpString.copy];
                        if (resultBlock) {
                            resultBlock(tmpString.copy);
                        }
                    });
                    blt_dispatch_main_sync_safe(^{
                        [self showError:error];
                    });
                }
                
            }];
    //        精度为准确  汉字只能使用精确模式  不能使用fast模式  fast对于阿拉伯数字 英文一类的
            textRequest.recognitionLevel = VNRequestTextRecognitionLevelAccurate;
    //        是否使用语言矫正  不使用  如果使用例如：badf00d会被矫正成badfood  当成food单词
            textRequest.usesLanguageCorrection = NO;
    //        语言区域 一定要设置  不然那没有效果
            if (chineseFirst) {
                textRequest.recognitionLanguages = @[@"zh-Hans", @"en-US"];
            }else{
                textRequest.recognitionLanguages = @[ @"en-US", @"zh-Hans"];
            }
            NSError *error;
            [handler performRequests:@[textRequest] error:&error];
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showError:error];
                });
            }
        } else {
            // Fallback on earlier versions
        }
    });
}

- (void)refreshRecogineText:(NSString *)text{
    self.textView.text = text;
}

- (void)showError:(NSError *)errpr{
    NSLog(@"LBLog start recogine failed %@",errpr.localizedDescription);
    [self showHintTipWithError:errpr];
}



- (void)recogineTypeClicked{
    if (self.isRecogining) {
        return;
    }
    self.chineseFirst.selected = !self.chineseFirst.isSelected;
    self.dataSources = _dataSources;
}

- (void)scanFileButtonClicked{
    if (@available(iOS 13.0, *)) {
        VNDocumentCameraViewController *scanVC = [[VNDocumentCameraViewController alloc] init];
        scanVC.delegate = self;
        [self presentViewController:scanVC animated:YES completion:nil];
    } else {
        // Fallback on earlier versions
    }
}

- (void)setDataSources:(NSArray<UIImage *> *)dataSources{
    _dataSources = dataSources;
    self.imageContentView.dataSources = dataSources;
//    [self.collectionView layoutIfNeeded];
//    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_offset(30);
//        make.top.mas_offset(60);
//        make.right.mas_offset(-30);
//        make.size.mas_equalTo(self.collectionView.contentSize);
//    }];
    [self startRecogineCollectionImage];
}

- (void)startRecogineCollectionImage{
    if (!NSArrayIsExist(self.dataSources)) {
        return;
    }
    if (self.isRecogining) {
        return;
    }
    [self showLoadingAnimation];
    self.isRecogining = YES;
    _semaphore = dispatch_semaphore_create(0);
    NSMutableString *tmpString  = @"".mutableCopy;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        for (int i = 0; i < self.dataSources.count; i++) {
//            NSLog(@"LBLog scan image %zd ",i);
            UIImage *image = self.dataSources[i];
            //识别图片
            [self startRecogineImage:image resultBlock:^(NSString *resultText) {
                [tmpString appendString:resultText];
                [tmpString appendString:@"\n\n\n"];
                if (self->_semaphore) {
                    dispatch_semaphore_signal(self->_semaphore);
                }
            }];
            dispatch_semaphore_wait(self->_semaphore, DISPATCH_TIME_FOREVER);
        }
        
//        NSLog(@"LBLog final string is %@",tmpString);
        blt_dispatch_main_sync_safe(^{
            self.isRecogining = NO;
            [self stopLoadingAnimation];
            self.textView.text = tmpString.copy;
        });
    });
}

#pragma mark - scan delegate
- (void)documentCameraViewController:(VNDocumentCameraViewController *)controller didFinishWithScan:(VNDocumentCameraScan *)scan API_AVAILABLE(ios(13.0)){
    [controller dismissViewControllerAnimated:YES completion:nil];
    _semaphore = dispatch_semaphore_create(0);
    NSMutableArray *imageArray = @[].mutableCopy;
    for (int i = 0; i < scan.pageCount; i++) {
        UIImage *image = [scan imageOfPageAtIndex:i];
        [imageArray addObject:image];
    }
    self.dataSources = imageArray.copy;
}


// The delegate will receive this call when the user is unable to scan, with the following error.
- (void)documentCameraViewController:(VNDocumentCameraViewController *)controller didFailWithError:(NSError *)error API_AVAILABLE(ios(13.0)){
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self showError:error];
}


- (void)selectButtonClicked{
    TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc] init];
    imagePickerVC.barItemTextColor = self.navigationController.navigationBar.tintColor;
    imagePickerVC.statusBarStyle = self.preferredStatusBarStyle;
    
    
    imagePickerVC.allowPickingImage = YES;
    imagePickerVC.allowTakePicture = YES;
    imagePickerVC.maxImagesCount = 1;
    
    [imagePickerVC setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        UIImage *image = photos.firstObject;
        // save photo and get asset / 保存图片，获取到asset
        if (image) {
            self.dataSources = @[image];
        }
        
    }];
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}



- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        _textView.textColor = [UIColor blackColor];
        _textView.contentInset = UIEdgeInsetsMake(10, 15, 10, 15);
        _textView.layer.cornerRadius = 15;
//        _textView.delegate = self;
        UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        _textView.inputView = dummyView;
    }
    return _textView;
}

- (UIButton *)chineseFirst{
    if (!_chineseFirst) {
        _chineseFirst = [UIButton blt_buttonWithTitle:@"英语优先" font:UIFontPFFontSize(16) titleColor:[UIColor blackColor] target:self selector:@selector(recogineTypeClicked)];
        [_chineseFirst setTitle:@"汉字优先" forState:UIControlStateSelected];
        _chineseFirst.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        [_chineseFirst setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        _chineseFirst.selected = YES;
    }
    return _chineseFirst;
}

- (UIButton *)fileScanBtn{
    if (!_fileScanBtn) {
        _fileScanBtn = [UIButton blt_buttonWithTitle:@"文档扫描" font:UIFontPFFontSize(16) titleColor:[UIColor blueColor] target:self selector:@selector(scanFileButtonClicked)];
        _fileScanBtn.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        [_fileScanBtn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    }
    return _fileScanBtn;
}

- (LLTextRecogineImageView *)imageContentView{
    if (!_imageContentView) {
        _imageContentView = [[LLTextRecogineImageView alloc] init];
        BLT_WS(weakSelf);
        _imageContentView.previewImageBlock = ^(NSInteger currentIndex, NSArray * _Nonnull imageArray) {
            [weakSelf blt_previewImage:imageArray currentIndex:currentIndex];
        };
    }
    return _imageContentView;
}

- (void)dealloc
{
    NSLog(@"LBLog %@ dealloc =================",NSStringFromClass([self class]));
}

@end
