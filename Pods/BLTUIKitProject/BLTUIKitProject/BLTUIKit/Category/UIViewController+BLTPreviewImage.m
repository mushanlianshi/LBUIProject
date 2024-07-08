//
//  UIViewController+BLTPreviewImage.m
//  BLTUIKitProject
//
//  Created by liu bin on 2023/7/31.
//

#import "UIViewController+BLTPreviewImage.h"
#import <BLTBasicUIKit/BLTBasicUIKit.h>
#import "BLTUICommonDefines.h"


@implementation UIViewController (BLTPreviewImage)

static GKPhotoBrowser *photoBrowser;

- (GKPhotoBrowser *)blt_previewImage:(NSArray *)imageList currentIndex:(NSInteger)currentIndex {
    return [self blt_previewImage:imageList originList:nil currentIndex:currentIndex];
}

- (GKPhotoBrowser *)blt_previewImage:(NSArray *)imageList originList:(NSArray *)originList currentIndex:(NSInteger)currentIndex{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:imageList.count];
    [imageList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKPhoto *photo = [GKPhoto new];
        if([obj isKindOfClass:[UIImage class]]){
            photo.image = (UIImage *)obj;
        }else if ([obj isKindOfClass:[NSURL class]]){
            photo.url = (NSURL *)obj;
            if(originList.count > 0 && idx < originList.count && [originList[idx] isKindOfClass:[NSURL class]]){
                photo.originUrl = (NSURL *)originList[idx];
            }
        }
        else if ([obj isKindOfClass:[NSString class]] && [(NSString *)obj hasPrefix:@"http"]){
            photo.url = [NSURL URLWithString:obj];
            if(originList.count > 0 && idx < originList.count){
                photo.originUrl = [NSURL URLWithString:originList[idx]];
            }
        }else if ([obj isKindOfClass:[NSString class]] && [NSURL fileURLWithPath:obj]){
            photo.url = [NSURL fileURLWithPath:obj];
        }
        [tmpArray addObject:photo];
    }];
    
    GKPhotoBrowser *browser = [self p_createPhotoBrowser:tmpArray currentIndex:currentIndex];
    [browser showFromVC:self];
    return browser;
}

- (GKPhotoBrowser *)p_createPhotoBrowser:(NSArray <GKPhoto *>*)photoList currentIndex:(NSInteger)currentIndex{
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photoList currentIndex:currentIndex];
    //点击 滑动缩放消失的
    browser.hideStyle = GKPhotoBrowserHideStyleZoomScale;
    browser.isSingleTapDisabled = true;
    browser.isStatusBarShow = true;
    photoBrowser = browser;
    UIButton *closeBtn = [self p_closeBtn];
    [browser setupCoverViews:@[closeBtn] layoutBlock:^(GKPhotoBrowser * _Nonnull photoBrowser, CGRect superFrame) {
        closeBtn.blt_x = 15;
        closeBtn.blt_y = 20 + BLT_IPHONEX_MARGIN_TOP;
    }];
    return browser;
}

// 单击事件
- (BLTUIResponseAreaButton *)p_closeBtn{
    UIImage *image = UIImageNamedFromBLTUIKItBundle(@"blt_upload_image_navi_back_white");
    BLTUIResponseAreaButton *button = [[BLTUIResponseAreaButton alloc] init];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closePhotoBrowser:) forControlEvents:UIControlEventTouchUpInside];
    button.responseAreaInsets = UIEdgeInsetsMake(-10, -20, -10, -20);
    button.blt_width = image.size.width;
    button.blt_height = image.size.height;
    return button;
}

- (void)closePhotoBrowser:(UIButton *)button{
    [photoBrowser dismiss];
}



@end
