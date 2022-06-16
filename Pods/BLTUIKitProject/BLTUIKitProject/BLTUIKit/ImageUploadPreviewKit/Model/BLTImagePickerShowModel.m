//
//  BLTImagePickerShowModel.m
//  BLTUIKitProject_Example
//
//  Created by liu bin on 2020/3/24.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import "BLTImagePickerShowModel.h"

@implementation BLTImagePickerShowModel

+ (instancetype)addModel{
    BLTImagePickerShowModel *model = [[BLTImagePickerShowModel alloc] init];
    model.addModel = YES;
    model.state = BLTImagePickerShowModelStateNormalShow;
    model.addTypeOptions = BLTImagePickerShowModelAddTypeOptionsPhotoLibrary | BLTImagePickerShowModelAddTypeOptionsPhotoCamera;
    return model;
}

//快速一个预览的模型
+ (instancetype)previewModelWithUrl:(NSString *)url{
    BLTImagePickerShowModel *model = [[BLTImagePickerShowModel alloc] init];
    model.state = BLTImagePickerShowModelStateNormalShow;
    model.imageUrlString = url;
    return model;
}

- (instancetype)initWithDic:(NSDictionary *)infoDic{
    self = [super init];
    if (self) {
        self.image = infoDic[@"image"];
        self.imageUrlString = infoDic[@"imageUrlString"];
        self.state = [infoDic[@"state"] integerValue];
        self.selected = [infoDic[@"selected"] boolValue];
    }
    return self;
}

- (CGFloat)maxVideoTime{
    if (_maxVideoTime < 1) {
        _maxVideoTime = 30;
    }
    return _maxVideoTime;
}

@end
