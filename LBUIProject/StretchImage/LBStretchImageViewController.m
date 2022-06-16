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
        make.size.mas_equalTo(CGSizeMake(self.backgroundImageView.image.size.width * 1.5, self.backgroundImageView.image.size.height));
        make.centerX.mas_equalTo(self.view);
    }];
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
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2 - 10, image.size.width / 2 - 10, image.size.height / 2 - 10, image.size.width / 2 - 10) resizingMode:UIImageResizingModeStretch];
        _backgroundImageView = [UIImageView blt_imageViewWithImage:image];
    }
    return _backgroundImageView;
}

@end
