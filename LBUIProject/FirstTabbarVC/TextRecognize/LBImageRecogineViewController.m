//
//  LBImageRecogineViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/7/21.
//

#import <CoreML/CoreML.h>
#import "LBImageRecogineViewController.h"
#import <Vision/Vision.h>
#import "Masonry.h"
#import <BLTUIKitProject/BLTUI.h>
#import "TZImagePickerController.h"
#import "NSObject+AutoProperty.h"
#import "LBUIProject-Swift.h"
//#import "YOLOv3Tiny.h"

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
    [self.view addSubview:self.imageView];
//    [self.scrollView addSubview:self.imageView];
//    [self setConstraints];
}


- (void)setConstraints{
//    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(self.view);
//    }];
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
                [self recognizeByCoreML];
            });
        }
        
    }];
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}



- (void)recognizeByCoreML{
    if (!self.imageView.image) {
        return;
    }

    while (self.imageView.layer.sublayers.count > 0) {
        [self.imageView.layer.sublayers.lastObject removeFromSuperlayer];
    }
    
    UIImage *image = self.imageView.image;
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.equalTo(self.imageView.mas_width).multipliedBy(image.size.height / image.size.width);
    }];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (@available(iOS 13.0, *)) {
            
//            这种得到的YOLOv3TinyOutput输出  还需要自己处理
//            YOLOv3Tiny *yolo = [[YOLOv3Tiny alloc] init];
//            YOLOv3TinyInput *input = [[YOLOv3TinyInput alloc] initWithImage:[self CVPixelBufferRefFromUiImage:self.imageView.image]];
//            NSError *yoloError = nil;
//            YOLOv3TinyOutput *output = [yolo predictionFromFeatures:input error:&yoloError];
//            NSLog(@"LBLog output %@ %@",output.confidence, output.featureNames);
            
            VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
//            获取不到资源  直接alloc  init
            NSString *path = [[NSBundle mainBundle] pathForResource:@"YOLOv3Tiny" ofType:@"mlmodelc"];
            NSError *error = nil;
            MLModel *model = [MLModel modelWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
            
//            YOLOv3Tiny *model = [[YOLOv3Tiny alloc] init];
            NSError *modelError = nil;
            VNCoreMLModel *coreML = [VNCoreMLModel modelForMLModel:model error:&modelError];
            VNCoreMLRequest *objectRequest = [[VNCoreMLRequest alloc] initWithModel:coreML completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
                for (VNRecognizedObjectObservation *observation in request.results) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGRect frame = [self convertBounds:observation.boundingBox imageFrame:self.imageView.frame];
                        CALayer *borderLayer = [self createRoundedRectLayerWithBounds:frame];
                        CATextLayer *textLayer = [self createTextSubLayerInBounds:frame identifier:observation.labels.firstObject.identifier confidence:observation.confidence];
                        [self.imageView.layer addSublayer:borderLayer];
                        [self.imageView.layer addSublayer:textLayer];
                    });
                }
            }];
            
            NSError *handleError = nil;
            handler.accessibilityLanguage = @"zh-Hans";
            [handler performRequests:@[objectRequest] error:&handleError];
            
        } else {
            
        }
    });
}


- (CALayer *)createRoundedRectLayerWithBounds:(CGRect)bounds{
    CALayer *layer = [[CALayer alloc] init];
    layer.bounds = bounds;
    layer.position = CGPointMake(bounds.origin.x, bounds.origin.y);
    layer.borderColor = BLT_HEXCOLOR(0xffff44).CGColor;
    layer.borderWidth = 1;
    return layer;
}

- (CATextLayer *)createTextSubLayerInBounds:(CGRect)bounds identifier:(NSString *)identifier confidence:(VNConfidence)confidence{
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    textLayer.string = identifier;
    textLayer.bounds = bounds;
    textLayer.position = CGPointMake(bounds.origin.x, bounds.origin.y);
    textLayer.borderColor = BLT_HEXCOLOR(0xffff44).CGColor;
    textLayer.borderWidth = 1 ;
    return textLayer;
}

- (CGRect)convertBounds:(CGRect)rect imageFrame:(CGRect)imageFrame{
    CGFloat x = rect.origin.x * imageFrame.size.width;
    CGFloat y = rect.origin.y * imageFrame.size.height;
    CGFloat width = rect.size.width * imageFrame.size.width;
    CGFloat height = rect.size.height * imageFrame.size.height;
    return  CGRectMake(x, y, width, height);
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
                    if ([request.results.firstObject isKindOfClass:[VNClassificationObservation class]]) {
                        VNClassificationObservation * result = request.results.firstObject;
                        NSLog(@"LBLog obseration %@ %@",result.identifier, [NSNumber numberWithFloat:result.confidence]);
                    }
//                    [request.results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                        VNClassificationObservation *observation = (VNClassificationObservation *)obj;
//                        NSLog(@"LBLog obseration %@ %@",req.identifier, [NSNumber numberWithFloat:observation.confidence]);
//                    }];
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

- (CVPixelBufferRef)CVPixelBufferRefFromUiImage:(UIImage *)img
{
    CGImageRef image = [img CGImage];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = MIN(416, CGImageGetWidth(image));
    CGFloat frameHeight = MIN(416, CGImageGetHeight(image));
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
        
        CVPixelBufferLockBaseAddress(pxbuffer, 0);
        void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
        NSParameterAssert(pxdata != NULL);
        
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef context = CGBitmapContextCreate(pxdata,
                                                     frameWidth,
                                                     frameHeight,
                                                     8,
                                                     CVPixelBufferGetBytesPerRow(pxbuffer),
                                                     rgbColorSpace,
                                                     (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
        NSParameterAssert(context);
        CGContextConcatCTM(context, CGAffineTransformIdentity);
        CGContextDrawImage(context, CGRectMake(0,
                                               0,
                                               frameWidth,
                                               frameHeight),
                           image);
        CGColorSpaceRelease(rgbColorSpace);
        CGContextRelease(context);
        
        CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
        
        return pxbuffer;
    }


- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
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
