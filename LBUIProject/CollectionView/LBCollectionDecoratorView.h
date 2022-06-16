//
//  LBCollectionDecoratorView.h
//  LBUIProject
//
//  Created by liu bin on 2022/6/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//自定义装饰视图
@interface LBCollectionDecoratorView : UICollectionReusableView



@end


//自定义装饰视图的layout属性
@interface LBCollectionDecoratorViewLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, assign) CGFloat layoutCornerRaduis;

@end

NS_ASSUME_NONNULL_END
