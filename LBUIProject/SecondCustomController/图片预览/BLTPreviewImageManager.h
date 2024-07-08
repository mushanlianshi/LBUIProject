//
//  BLTPreviewImageManager.h
//  LBUIProject
//
//  Created by liu bin on 2023/7/28.
//

#import <UIKit/UIKit.h>
#import <GKPhotoBrowser/GKPhotoBrowser.h>


@interface BLTPreviewImageManager : NSObject

+ (GKPhotoBrowser *)previewImage:(NSArray *)imageList originList:(NSArray <NSString *>*)originList currentIndex:(NSInteger)currentIndex currentVC:(UIViewController *)currentVC;

@end

