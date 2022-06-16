//
//  BLTSystemPermissionManager.h
//  BLTUIKitProject_Example
//
//  Created by liu bin on 2020/3/25.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import <Foundation/Foundation.h>



/// 检测系统权限的
@interface BLTSystemPermissionManager : NSObject

//检测是否有相机权限 下面z一种会自动弹框提示
+ (void)checkHasCameraPermission:(void(^)(BOOL hasPermission))completion;
+ (void)checkHasCameraPermission:(void(^)(BOOL hasPermission))completion tipController:(UIViewController *)controller;

//检测是否有图库权限
+ (void)checkHasPhotoLibraryPermission:(void(^)(BOOL hasPermission))completion;
+ (void)checkHasPhotoLibraryPermission:(void(^)(BOOL hasPermission))completion  tipController:(UIViewController *)controller;

//点击确定  自动跳转设置界面的
+ (void)tipUserNoPermissionTitle:(NSString *)title message:(NSString *)message controller:(UIViewController *)controller;
//自己处理的
+ (void)tipUserNoPermissionTitle:(NSString *)title message:(NSString *)message cancelBlock:(dispatch_block_t)cancelBlock sureBlock:(dispatch_block_t)sureBlock controller:(UIViewController *)controller;

//iOS 跳转系统设置打开定位页面
+ (void)openLocationSettings;

@end


