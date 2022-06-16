//
//  LBCollectionDecoratorView.m
//  LBUIProject
//
//  Created by liu bin on 2022/6/16.
//

#import "LBCollectionDecoratorView.h"

@implementation LBCollectionDecoratorView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes{
    [super applyLayoutAttributes:layoutAttributes];
    if ([layoutAttributes isKindOfClass:[LBCollectionDecoratorViewLayoutAttributes class]]) {
        LBCollectionDecoratorViewLayoutAttributes *layoutAtt = (LBCollectionDecoratorViewLayoutAttributes *)layoutAttributes;
        self.backgroundColor = layoutAtt.backgroundColor;
        self.layer.cornerRadius = layoutAtt.layoutCornerRaduis;
        self.layer.masksToBounds = true;
    }
}

@end



@implementation LBCollectionDecoratorViewLayoutAttributes


@end
