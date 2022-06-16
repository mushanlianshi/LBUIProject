//
//  BLTSystemPermissionManager.m
//  BLTUIKitProject_Example
//
//  Created by liu bin on 2020/3/25.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import "BLTSystemPermissionManager.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "BLTUICommonDefines.h"

typedef NS_ENUM(NSInteger, BLTSystemPermissionType){
    BLTSystemPermissionTypeCamera = 1,
    BLTSystemPermissionTypePhotoLibrary,
};

@implementation BLTSystemPermissionManager

//检测是否有相机权限
+ (void)checkHasCameraPermission:(void(^)(BOOL hasPermission))completion{
    [self checkHasCameraPermission:completion tipController:nil];
}
+ (void)checkHasCameraPermission:(void(^)(BOOL hasPermission))completion tipController:(UIViewController *)controller{
    if (!completion) {
        return;
    }
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        blt_dispatch_main_sync_safe(^{
            [self tipNoPermissionType:BLTSystemPermissionTypeCamera controller:controller];
            completion(NO);
        });
    }else if (authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                blt_dispatch_main_sync_safe(^{
                    if (!granted) {
                        [self tipNoPermissionType:BLTSystemPermissionTypeCamera controller:controller];
                    }
                    completion(granted);
                });
            });
        }];
    }else if (authStatus == AVAuthorizationStatusAuthorized){
        blt_dispatch_main_sync_safe(^{
            completion(YES);
        });
    }else{
        blt_dispatch_main_sync_safe(^{
            [self tipNoPermissionType:BLTSystemPermissionTypeCamera controller:controller];
            completion(NO);
        });
    }
}

//检测是否有图库权限
+ (void)checkHasPhotoLibraryPermission:(void(^)(BOOL hasPermission))completion{
    [self checkHasPhotoLibraryPermission:completion tipController:nil];
}

+ (void)checkHasPhotoLibraryPermission:(void(^)(BOOL hasPermission))completion tipController:(UIViewController *)controller{
    if (!completion) {
        return;
    }
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus == PHAuthorizationStatusDenied || authStatus == PHAuthorizationStatusRestricted) {
        blt_dispatch_main_sync_safe(^{
            [self tipNoPermissionType:BLTSystemPermissionTypePhotoLibrary controller:controller];
            completion(NO);
        });
    }else if (authStatus == PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            blt_dispatch_main_sync_safe(^{
                [self checkHasPhotoLibraryPermission:completion tipController:controller];
            });
        }];
    }else if (authStatus == PHAuthorizationStatusAuthorized){
        blt_dispatch_main_sync_safe(^{
            completion(YES);
        });
    }else{
        blt_dispatch_main_sync_safe(^{
            [self tipNoPermissionType:BLTSystemPermissionTypePhotoLibrary controller:controller];
            completion(NO);
        });
    }
}


+ (void)tipNoPermissionType:(BLTSystemPermissionType)type controller:(UIViewController *)controller{
    if (controller == nil) {
        return;
    }
    switch (type) {
        case BLTSystemPermissionTypeCamera:
            [self tipUserNoPermissionTitle:@"无法访问相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相册" controller:controller];
            break;
        case BLTSystemPermissionTypePhotoLibrary:
            [self tipUserNoPermissionTitle:@"无法访问相册" message:@"拍照和存储选择照片需要相册权限，请在iPhone的""设置-隐私-相册""中允许访问相册" controller:controller];
            break;
        default:
            break;
    }
    
}

//点击确定  自动跳转设置界面的
+ (void)tipUserNoPermissionTitle:(NSString *)title message:(NSString *)message controller:(UIViewController *)controller{
    [self tipUserNoPermissionTitle:title message:message cancelBlock:^{
        
    } sureBlock:^{
        [self openLocationSettings];
    } controller:controller];
}
//自己处理的
+ (void)tipUserNoPermissionTitle:(NSString *)title message:(NSString *)message cancelBlock:(dispatch_block_t)cancelBlock sureBlock:(dispatch_block_t)sureBlock controller:(UIViewController *)controller{
    if (!controller) {
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cancelBlock) {
            cancelBlock();
        }
    }];
    UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (sureBlock) {
            sureBlock();
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:settingAction];
    alertController.modalPresentationStyle = UIModalPresentationFullScreen;
    [controller presentViewController:alertController animated:YES completion:nil];
}

//iOS 跳转系统设置打开定位页面
+ (void)openLocationSettings{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10.0, *)){
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }else{
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end
