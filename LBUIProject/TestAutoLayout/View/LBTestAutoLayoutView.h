//
//  LBTestAutoLayoutView.h
//  LBUIProject
//
//  Created by liu bin on 2021/5/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBTestAutoLayoutView : UIView

@property (nonatomic, copy) NSString *testString;

- (void)setConstraints;

@end

NS_ASSUME_NONNULL_END
