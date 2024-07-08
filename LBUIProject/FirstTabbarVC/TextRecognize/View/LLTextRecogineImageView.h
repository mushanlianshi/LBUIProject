//
//  LLTextRecogineImageView.h
//  LBUIProject
//
//  Created by liu bin on 2021/7/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLTextRecogineImageView : UIView

@property (nonatomic, strong) NSArray <UIImage *>*dataSources;

@property (nonatomic, copy) void(^previewImageBlock) (NSInteger currentIndex, NSArray *imageArray);

@end


@interface LLTextRecogineImageCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;

@end

NS_ASSUME_NONNULL_END
