//
//  LBCustomCollectionDecoratorViewLayout.h
//  LBUIProject
//
//  Created by liu bin on 2022/6/16.
//

#import <CHTCollectionViewWaterfallLayout/CHTCollectionViewWaterfallLayout.h>
#import "LBCollectionDecoratorView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LBCustomCollectionDecoratorViewLayoutDelegate <CHTCollectionViewDelegateWaterfallLayout>

- (LBCollectionDecoratorViewLayoutAttributes *)layoutDecoratorViewAttributesInSection:(NSInteger)section;

- (BOOL)layoutPinInSection:(NSInteger)section;

@end

@interface LBCustomCollectionDecoratorViewLayout : CHTCollectionViewWaterfallLayout

//section 是否可以悬浮  
@property (nonatomic, assign) BOOL canSectionPin;

@end

NS_ASSUME_NONNULL_END
