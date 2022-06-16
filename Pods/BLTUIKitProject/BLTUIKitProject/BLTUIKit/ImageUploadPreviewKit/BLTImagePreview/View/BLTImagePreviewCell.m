//
//  BLTImagePreviewCell.m
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/27.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import "BLTImagePreviewCell.h"

@implementation BLTImagePreviewCell

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

@end
