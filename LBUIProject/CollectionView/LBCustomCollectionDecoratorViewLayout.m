//
//  LBCustomCollectionDecoratorViewLayout.m
//  LBUIProject
//
//  Created by liu bin on 2022/6/16.
//

#import "LBCustomCollectionDecoratorViewLayout.h"

static NSString * const kLBCollectionDecoratorViewLayoutAttributesIdentifier = @"LBCollectionDecoratorViewLayoutAttributes";

@interface LBCustomCollectionDecoratorViewLayout ()

@property (nonatomic, weak)id <LBCustomCollectionDecoratorViewLayoutDelegate> delegate;


//装饰视图的attributes
@property (nonatomic, strong) NSMutableArray *decoratorAttributes;

@end

@implementation LBCustomCollectionDecoratorViewLayout

- (instancetype)init{
    self = [super init];
    if (self) {
        [self registerClass:[LBCollectionDecoratorView class] forDecorationViewOfKind:kLBCollectionDecoratorViewLayoutAttributesIdentifier];
    }
    return self;
}

- (void)prepareLayout{
    [super prepareLayout];
    [self.decoratorAttributes removeAllObjects];
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return;
    }
    
    for (int section = 0; section < numberOfSections; section++) {
        if ([self.delegate respondsToSelector:@selector(layoutDecoratorViewAttributesInSection:)] == false) {
            break;;
        }
        
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        LBCollectionDecoratorViewLayoutAttributes *customAttr = [self.delegate layoutDecoratorViewAttributesInSection:section];
        if (customAttr == nil) {
            continue;;
        }
        LBCollectionDecoratorViewLayoutAttributes *decoratorAttri = [LBCollectionDecoratorViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kLBCollectionDecoratorViewLayoutAttributesIdentifier withIndexPath: indexPath];
        decoratorAttri.backgroundColor = customAttr.backgroundColor;
        decoratorAttri.layoutCornerRaduis = customAttr.layoutCornerRaduis;
        
        UICollectionViewLayoutAttributes *firstItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        UICollectionViewLayoutAttributes *lastItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:numberOfItems - 1 inSection:section]];
        if (!firstItem || !lastItem) {
            continue;
        }
        
        UIEdgeInsets sectionInset = [self sectionInset];

        if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            UIEdgeInsets inset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
            sectionInset = inset;
        }

        
        CGRect sectionFrame = CGRectUnion(firstItem.frame, lastItem.frame);
        
        UICollectionViewLayoutAttributes *headerAttri = self.headersAttribute[@(section)];
        if (headerAttri) {
            sectionFrame = CGRectUnion(sectionFrame, headerAttri.frame);
        }
        
        UICollectionViewLayoutAttributes *footerAttri = self.footersAttribute[@(section)];
        if (footerAttri) {
            sectionFrame = CGRectUnion(sectionFrame, footerAttri.frame);
        }
        
        
        sectionFrame.size.width = self.collectionView.frame.size.width - sectionInset.left - sectionInset.right;
        
        if (headerAttri == nil) {
            sectionFrame.size.height += sectionInset.top;
        }
        
        if (footerAttri == nil) {
            sectionFrame.size.height += sectionInset.bottom;
        }
        sectionFrame.origin.x = sectionInset.left;
        
        decoratorAttri.frame = sectionFrame;
//        层级在下面
        decoratorAttri.zIndex = -1;
        
        [self.decoratorAttributes addObject:decoratorAttri];
        [self.allItemAttributes addObjectsFromArray:self.decoratorAttributes];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([elementKind isEqualToString:kLBCollectionDecoratorViewLayoutAttributesIdentifier]) {
        attribute = self.decoratorAttributes[indexPath.section];
    }
    return attribute;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
//    NSArray *attributes = self.allItemAttributes;
    NSMutableArray *attributes = [self.allItemAttributes mutableCopy];
    
//    处理是否有悬停
    if ([self.delegate respondsToSelector:@selector(layoutPinInSection:)]) {
        for (UICollectionViewLayoutAttributes *attr in attributes){
            BOOL shouldPin = [self.delegate layoutPinInSection:attr.indexPath.section];
            if (shouldPin) {
                 //注意不是self.collectionView layoutAttributesForSupplementaryElementOfKind:<#(nonnull NSString *)#> atIndexPath:<#(nonnull NSIndexPath *)#>
                UICollectionViewLayoutAttributes *headerAttribute = [self layoutAttributesForSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader atIndexPath:attr.indexPath];
                if (![attributes containsObject:headerAttribute]) {
                    [attributes addObject:headerAttribute];
                }
                NSInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:attr.indexPath.section];
                
                CGRect rect = headerAttribute.frame;
                
                CGFloat headerY = headerAttribute.frame.origin.y;
                NSLog(@"LBLog contentOffset y %@ %@",@(self.collectionView.contentOffset.y), @(headerY));
                CGFloat offsetY = numberOfItemsInSection == 0 ? headerY : self.collectionView.contentOffset.y;
//    //            设置section的Y值  让他悬浮起来  滚动了就修改 headerY的值让他变化  保证一直展示在最上面
                rect.origin.y = MAX(offsetY, headerY);
                headerAttribute.frame = rect;
    //            设置Zindex大一点  避免被遮挡
                headerAttribute.zIndex = 20;
            }
            
        }
        
    }
    
    return attributes;
}

//注意要悬浮  这里需要一直返回false  一直算位置
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    if (self.canSectionPin) {
        return YES;
    }
    return [super shouldInvalidateLayoutForBoundsChange:newBounds];
}


- (NSMutableArray *)decoratorAttributes{
    if (!_decoratorAttributes) {
        _decoratorAttributes = [[NSMutableArray alloc] init];
    }
    return _decoratorAttributes;
}

- (id<LBCustomCollectionDecoratorViewLayoutDelegate>)delegate{
    return (id <LBCustomCollectionDecoratorViewLayoutDelegate>)self.collectionView.delegate;
}

@end
