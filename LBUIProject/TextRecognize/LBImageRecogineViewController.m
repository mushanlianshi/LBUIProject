//
//  LBImageRecogineViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/7/21.
//

#import "LBImageRecogineViewController.h"
#import <Vision/Vision.h>
#import "Masonry.h"
#import <BLTUIKitProject/BLTUI.h>
#import "TZImagePickerController.h"
#import "NSObject+AutoProperty.h"

@interface LBImageRecogineViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation LBImageRecogineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"识别图片中的物品";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择图片" style:UIBarButtonItemStyleDone target:self action:@selector(selectImage)];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    [self setConstraints];
}


- (void)setConstraints{
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.scrollView);
        make.top.bottom.mas_equalTo(self.view).priorityLow();
    }];
}


- (void)selectImage{
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
            blt_dispatch_main_sync_safe(^{
                self.imageView.image = image;
                [self recognizeImage];
            });
        }
        
    }];
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)recognizeImage{
    if (!self.imageView.image) {
        return;
    }
    UIImage *image = self.imageView.image;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (@available(iOS 13.0, *)) {
            VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
            VNClassifyImageRequest *imageRequest = [[VNClassifyImageRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
                if (error == nil) {
                    [request.results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        VNClassificationObservation *observation = (VNClassificationObservation *)obj;
                        NSLog(@"LBLog obseration %@ %@",observation.identifier, [NSNumber numberWithFloat:observation.confidence]);
                    }];
                }else{
                    [self showHintTipWithError:error];
                }
            }];
            
            //        精度为准确  汉字只能使用精确模式  不能使用fast模式  fast对于阿拉伯数字 英文一类的
//            request.recognitionLevel = VNRequestTextRecognitionLevelAccurate;
//            //        是否使用语言矫正  不使用  如果使用例如：badf00d会被矫正成badfood  当成food单词
//            request.usesLanguageCorrection = NO;
//            request.recognitionLanguages = @[@"zh-Hans", @"en-US"];
            imageRequest.accessibilityLanguage = @"zh-Hans";
            NSError *error = nil;
            [handler performRequests:@[imageRequest] error:&error];
        } else {
            // Fallback on earlier versions
        }
    });
    
}


- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.maximumZoomScale = 2;
        _scrollView.minimumZoomScale = 0.5;
    }
    return _scrollView;
}

@end
