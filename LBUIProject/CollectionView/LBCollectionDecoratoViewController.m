//
//  ViewController.m
//  Demo
//
//  Created by Nelson on 12/11/27.
//  Copyright (c) 2012年 Nelson. All rights reserved.
//

#import "LBCollectionDecoratoViewController.h"
#import "CHTCollectionViewWaterfallCell.h"
#import "CHTCollectionViewWaterfallHeader.h"
#import "CHTCollectionViewWaterfallFooter.h"

#import <CHTCollectionViewWaterfallLayout/CHTCollectionViewWaterfallLayout.h>
#import "LBCustomCollectionDecoratorViewLayout.h"
#import "LBCollectionDecoratorView.h"


#define CELL_COUNT 20
#define CELL_IDENTIFIER @"WaterfallCell"
#define HEADER_IDENTIFIER @"WaterfallHeader"
#define FOOTER_IDENTIFIER @"WaterfallFooter"

@interface LBCollectionDecoratoViewController ()<LBCustomCollectionDecoratorViewLayoutDelegate, UICollectionViewDataSource>{
    LBCustomCollectionDecoratorViewLayout *layout;
}
@property (nonatomic, strong) NSArray *cellSizes;
@property (nonatomic, strong) NSArray *cats;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation LBCollectionDecoratoViewController

#pragma mark - Accessors

- (UICollectionView *)collectionView {
  if (!_collectionView) {
    layout = [[LBCustomCollectionDecoratorViewLayout alloc] init];

    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
//    layout.headerHeight = 15;
//    layout.footerHeight = 10;
    layout.minimumColumnSpacing = 20;
    layout.minimumInteritemSpacing = 30;
      layout.canSectionPin = true;

    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[CHTCollectionViewWaterfallCell class]
        forCellWithReuseIdentifier:CELL_IDENTIFIER];
    [_collectionView registerClass:[CHTCollectionViewWaterfallHeader class]
        forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader
               withReuseIdentifier:HEADER_IDENTIFIER];
    [_collectionView registerClass:[CHTCollectionViewWaterfallFooter class]
        forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter
               withReuseIdentifier:FOOTER_IDENTIFIER];
  }
  return _collectionView;
}

- (NSArray *)cellSizes {
  if (!_cellSizes) {
    _cellSizes = @[
      [NSValue valueWithCGSize:CGSizeMake(550, 550)],
      [NSValue valueWithCGSize:CGSizeMake(1000, 665)],
      [NSValue valueWithCGSize:CGSizeMake(1024, 689)],
      [NSValue valueWithCGSize:CGSizeMake(640, 427)],
    ];
  }
  return _cellSizes;
}

- (NSArray *)cats {
  if (!_cats) {
    _cats = @[@"cat1.jpg", @"cat2.jpg", @"cat3.jpg", @"cat4.jpg"];
  }
  return _cats;
}

- (void)injected{
    NSLog(@"LBLog injected =======");
    layout.headerInset = UIEdgeInsetsMake(5, 20, 30, 20);
    layout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);
    [_collectionView reloadData];
}

#pragma mark - Life Cycle

- (void)dealloc {
  _collectionView.delegate = nil;
  _collectionView.dataSource = nil;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.view addSubview:self.collectionView];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self updateLayoutForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
  [self updateLayoutForOrientation:toInterfaceOrientation];
}

- (void)updateLayoutForOrientation:(UIInterfaceOrientation)orientation {
  CHTCollectionViewWaterfallLayout *layout =
  (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
  layout.columnCount = UIInterfaceOrientationIsPortrait(orientation) ? 2 : 3;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return CELL_COUNT;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  CHTCollectionViewWaterfallCell *cell =
  (CHTCollectionViewWaterfallCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                              forIndexPath:indexPath];
  cell.imageView.image = [UIImage imageNamed:self.cats[indexPath.item % 4]];
  return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

  if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
      CHTCollectionViewWaterfallHeader *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                      withReuseIdentifier:HEADER_IDENTIFIER
                                                             forIndexPath:indexPath];
      reusableView.title = [NSString stringWithFormat:@"header %@",@(indexPath.section)];
      return  reusableView;
  } else if ([kind isEqualToString:CHTCollectionElementKindSectionFooter]) {
      CHTCollectionViewWaterfallFooter *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                      withReuseIdentifier:FOOTER_IDENTIFIER
                                                             forIndexPath:indexPath];
    reusableView.title = [NSString stringWithFormat:@"footer %@",@(indexPath.section)];
      return  reusableView;
  }

  return nil;
}





#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self.cellSizes[indexPath.item % 4] CGSizeValue];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section{
    if (section % 4 == 0) {
        return  100;
    }else if(section % 4 == 1){
        return  50;
    }
    
    return  25;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section{
    if (section % 4 == 0) {
        return  25;
    }else if(section % 4 == 1){
        return  50;
    }
    
    return  100;
}


#pragma custom layout
- (LBCollectionDecoratorViewLayoutAttributes *)layoutDecoratorViewAttributesInSection:(NSInteger)section{
    if (section == 2) {
        LBCollectionDecoratorViewLayoutAttributes *attributes = [[LBCollectionDecoratorViewLayoutAttributes alloc] init];
        attributes.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.4];
        attributes.layoutCornerRaduis = 10;
        return attributes;
    }
    return nil;
}

- (BOOL)layoutPinInSection:(NSInteger)section{
    if (section == 1) {
        return true;
    }
    return false;
}

@end
