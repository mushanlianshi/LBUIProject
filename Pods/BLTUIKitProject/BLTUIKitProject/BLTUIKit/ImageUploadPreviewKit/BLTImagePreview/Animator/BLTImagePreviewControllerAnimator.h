//
//  BLTImagePreviewControllerAnimator.h
//  AliyunOSSiOS
//
//  Created by liu bin on 2020/4/7.
//

#import <Foundation/Foundation.h>
#import "BLTImagePreviewController.h"
//BLTImagePreviewController present 动画的animator
@interface BLTImagePreviewControllerAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, weak) BLTImagePreviewController *imagePreviewController;

//默认0.29
@property (nonatomic, assign) NSTimeInterval duration;

@end

