//
//  LBStretchImageViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/7/29.
//

#import "LBStretchImageViewController.h"
#import <BLTBasicUIKit/BLTBasicUIKit.h>
#import "Masonry.h"

@interface LBStretchImageViewController ()

@property (nonatomic, strong) UIImageView *bubbleImageView;

@property (nonatomic, strong) UIImageView *tagImageView;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIImageView *gradientIV;

@property (nonatomic, strong) UIImageView *gradientIV2;

@property (nonatomic, strong) UIView *grandientView;

@property (nonatomic, strong) UIImageView *arrowMiddleIV;

@end

@implementation LBStretchImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bubbleImageView];
    [self.bubbleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(40);
        make.size.mas_equalTo(CGSizeMake(260, 100));
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.view addSubview:self.tagImageView];
    [self.tagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bubbleImageView.mas_bottom).mas_offset(40);
        make.size.mas_equalTo(CGSizeMake(self.tagImageView.image.size.width * 2, self.tagImageView.image.size.height));
        make.centerX.mas_equalTo(self.view);
    }];
    
//    因为圆角是半圆的    所以保证高度不变   不然圆角就变了
    [self.view addSubview:self.backgroundImageView];
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tagImageView.mas_bottom).mas_offset(40);
        make.size.mas_equalTo(CGSizeMake(self.backgroundImageView.image.size.width * 1.5, self.backgroundImageView.image.size.height * 1.5));
        make.centerX.mas_equalTo(self.view);
    }];
    
    
    [self.view addSubview:self.gradientIV];
    [self.gradientIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(60);
        make.top.equalTo(self.backgroundImageView.mas_bottom).offset(20);
    }];
    
    
    [self.view addSubview:self.gradientIV2];
    [self.gradientIV2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(60);
        make.top.equalTo(self.gradientIV.mas_bottom).offset(20);
    }];
    
    [self.view addSubview:self.grandientView];
    [self.grandientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.gradientIV2.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
    
    [self.view addSubview:self.arrowMiddleIV];
    [self.arrowMiddleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.grandientView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(300, 80));
    }];
    
    
//    __block BOOL _stop = true;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        _stop = NO;
//    });
//    while (_stop) {
//              [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate
//          distantFuture]];
//              NSLog(@"while循环中...");
//    }
////    你需要执行的代码
//    _stop = YES;
//    NSLog(@"while循环没影响");
}


- (UIImageView *)bubbleImageView{
    if (!_bubbleImageView) {
        UIImage *image = [UIImage imageNamed:@"bubble_right_image"];
//        //该参数的意思是被保护的区域到原始图像外轮廓的上部,左部,底部,右部的直线距离
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2 + 8 , image.size.width/ 2, image.size.height / 2 -9, image.size.width / 2) resizingMode:UIImageResizingModeStretch];
        _bubbleImageView = [UIImageView blt_imageViewWithImage:image];
    }
    return _bubbleImageView;
}


- (UIImageView *)tagImageView{
    if (!_tagImageView) {
        UIImage *image = [UIImage imageNamed:@"limit_discount_tag"];
//        //该参数的意思是被保护的区域到原始图像外轮廓的上部,左部,底部,右部的直线距离
//        1.拉伸1
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2 - 6, 6, image.size.height / 2 - 6, image.size.width - 6) resizingMode:UIImageResizingModeStretch];
//        2.拉伸2
//        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(7, 5, 7, image.size.width - 5) resizingMode:UIImageResizingModeStretch];
        _tagImageView = [UIImageView blt_imageViewWithImage:image];
    }
    return _tagImageView;
}

- (UIImageView *)backgroundImageView{
    if (!_backgroundImageView) {
        UIImage *image = [UIImage imageNamed:@"background_bubble_image"];
//        //该参数的意思是被保护的区域到原始图像外轮廓的上部,左部,底部,右部的直线距离
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2 - 20, image.size.width / 2 - 20, image.size.height / 2 - 20, image.size.width / 2 - 20) resizingMode:UIImageResizingModeStretch];
        _backgroundImageView = [UIImageView blt_imageViewWithImage:image];
    }
    return _backgroundImageView;
}


- (UIImageView *)gradientIV{
    if (!_gradientIV) {
        UIImage *image = [UIImage imageNamed:@"gradient_image2"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
        _gradientIV = [[UIImageView alloc] init];
        _gradientIV.image = image;
    }
    return _gradientIV;
}


- (UIImageView *)gradientIV2{
    if (!_gradientIV2) {
        UIImage *image = [UIImage imageNamed:@"gradient_image2"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2 - 10, image.size.width / 2 - 10, image.size.height / 2 - 10, image.size.width / 2 - 10) resizingMode:UIImageResizingModeStretch];
//        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _gradientIV2 = [[UIImageView alloc] init];
//        _gradientIV2.tintColor = [UIColor yellowColor];
        _gradientIV2.image = image;
    }
    return _gradientIV2;
}

- (UIView *)grandientView{
    if (!_grandientView) {
        _grandientView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        [_grandientView blt_addGrandientLayerStartColor:[[UIColor redColor] colorWithAlphaComponent:0.5] endColor:[[UIColor blueColor] colorWithAlphaComponent:0.9] direction:BLTGrandientLayerDirectionLeftToRight];
    }
    return _grandientView;
}

- (UIImageView *)arrowMiddleIV{
    if(!_arrowMiddleIV){
        UIImage *originImage = [UIImage imageNamed:@"bubble_right_image"];
//        UIImage *image = [self lg_stretchTopAndBottomWithimg:originImage withsize:CGSizeMake(300, 80)];
        UIImage *image = [originImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 6, originImage.size.height -7, 40) resizingMode:UIImageResizingModeStretch];
        _arrowMiddleIV = [[UIImageView alloc] init];
        _arrowMiddleIV.image = image;
    }
    return _arrowMiddleIV;
}

- (UIImage *)lg_stretchLeftAndRightWithimg:(UIImage*)img withsize:(CGSize)size

{

    CGSize imageSize = img.size;

    CGSize bgSize = size;

    //1.第一次拉伸右边 保护左边
    UIImage *image = [img stretchableImageWithLeftCapWidth:imageSize.width *0.8 topCapHeight:imageSize.height * 0.5];

    //第一次拉伸的距离之后图片总宽度

    CGFloat tempWidth = (bgSize.width)/2 + imageSize.width/2;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(tempWidth, imageSize.height), NO, [UIScreen mainScreen].scale);

    [image drawInRect:CGRectMake(0, 0, tempWidth, bgSize.height)];

    //拿到拉伸过的图片

    UIImage *firstStrechImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    //2.第二次拉伸左边 保护右边

    UIImage *secondStrechImage = [firstStrechImage stretchableImageWithLeftCapWidth:firstStrechImage.size.width *0.2 topCapHeight:firstStrechImage.size.height*0.5];

    return secondStrechImage;
}

- (UIImage *)lg_stretchTopAndBottomWithimg:(UIImage*)img withsize:(CGSize)size

{

    CGSize imageSize = img.size;

    CGSize bgSize = size;

    //1.第一次拉伸上边 保护下边
    UIImage *image = [img stretchableImageWithLeftCapWidth:imageSize.height *0.8 topCapHeight:imageSize.width * 0.5];

    //第一次拉伸的距离之后图片总高度

    CGFloat tempHeight = (bgSize.height)/2 + imageSize.height/2;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(tempHeight, imageSize.height), NO, [UIScreen mainScreen].scale);

    [image drawInRect:CGRectMake(0, 0, tempHeight, bgSize.height)];

    //拿到拉伸过的图片

    UIImage *firstStrechImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    //2.第二次拉伸下边 保护上边

    UIImage *secondStrechImage = [firstStrechImage stretchableImageWithLeftCapWidth:firstStrechImage.size.height *0.2 topCapHeight:firstStrechImage.size.width*0.5];

    return secondStrechImage;
}

@end
