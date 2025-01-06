//
//  LBTransmitView.h
//  LBUIProject
//
//  Created by liu bin on 2021/7/27.
//

#import <UIKit/UIKit.h>


@interface LBTransmitView : UIView

@end



@interface LBTransmitSubView : UIView

@property (nonatomic, copy) NSString *name;

- (instancetype)initWithName:(NSString *)name backgroundColor:(UIColor *)backgroudColor;

@end
