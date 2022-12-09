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


@interface LBTestAutoLayoutSubView : UIView

- (void)refreshTitle:(NSString *)title;

@end

@interface LBTestAutoLayoutGrandientButton : UIButton

@end

NS_ASSUME_NONNULL_END
