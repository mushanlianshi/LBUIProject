//
//  LBStretchImageViewController.h
//  LBUIProject
//
//  Created by liu bin on 2021/7/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//拉伸的时候注意不要拉到圆角  不然会出现不好定位的原因
//resizableImageWithCapInsets insets内的区域是保护的   会拉伸剩余框的区域
@interface LBStretchImageViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
