//
//  UIViewController+BLTPreviewImage.h
//  BLTUIKitProject
//
//  Created by liu bin on 2023/7/31.
//

#import <UIKit/UIKit.h>
#import <GKPhotoBrowser/GKPhotoBrowser.h>

@interface UIViewController (BLTPreviewImage)

///预览图片的
- (GKPhotoBrowser *)blt_previewImage:(NSArray *)imageList currentIndex:(NSInteger)currentIndex;

///预览图片 支持原图的
- (GKPhotoBrowser *)blt_previewImage:(NSArray *)imageList originList:(NSArray <NSString *>*)originList currentIndex:(NSInteger)currentIndex;

@end

