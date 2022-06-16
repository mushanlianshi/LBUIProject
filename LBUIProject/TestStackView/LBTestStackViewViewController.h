//
//  LBTestStackViewViewController.h
//  LBUIProject
//
//  Created by liu bin on 2021/5/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//注意：
//1.如果横向的stackview 里面包含label是多行的   会导致子控件宽度都自动相等，可以给label包一层view父控件来解决
//2.如果设置UIStackViewDistributionFillProportionally  根据内容的尺寸等比例  注意约束等级不能设置1000  随便设置proprotyLow()  因为是根据内容自动等比例  不是我们设置的宽度  
@interface LBTestStackViewViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
