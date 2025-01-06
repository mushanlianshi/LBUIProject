//
//  BLTPhotoLibraryManager.m
//  Baletu
//
//  Created by Baletoo on 2020/9/17.
//  Copyright © 2020 Baletu. All rights reserved.
//

#import "BLTPhotoLibraryManager.h"
#import <Photos/Photos.h>

@implementation BLTPhotoLibraryManager

+ (instancetype)sharedManager
{
    static BLTPhotoLibraryManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[BLTPhotoLibraryManager alloc] init];
    });
    return _sharedManager;
}

- (void)savePhoto:(UIImage *)photo
    completeBlock:(void(^)(BOOL success, NSError *error))completeBlock
{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:photo];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (completeBlock) {
                if ([NSThread isMainThread]) {
                    completeBlock(success, error);
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeBlock(success, error);
                    });
                }
            }
        }];
    }
    else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self savePhoto:photo completeBlock:completeBlock];
            }
            else {
                if (completeBlock) {
                    NSError *error = [NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"未授权访问相册"}];
                    if ([NSThread isMainThread]) {
                        completeBlock(NO, error);
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeBlock(NO, error);
                        });
                    }
                }
            }
        }];
    }
}

@end
