//
//  BLTImagePreviewView.m
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/28.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import "BLTImagePreviewView.h"
#import "BLTImagePreviewCell.h"
#import "UIImageView+WebCache.h"

static NSString * const kPreviewImageCellIdentifier = @"kPreviewImageCellIdentifier";

@interface BLTImagePreviewView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation BLTImagePreviewView

#pragma mark - appeance设置
+ (instancetype)appearance{
    static dispatch_once_t onceToken;
    static BLTImagePreviewView *appeanceInstance;
    dispatch_once(&onceToken, ^{
        appeanceInstance = [[BLTImagePreviewView alloc] init];
    });
    return appeanceInstance;
}

- (instancetype)initWithFrame:(CGRect)frame imagesArray:(NSArray *)imagesArray currentIndex:(NSInteger)currentIndex{
    self = [self initWithFrame:frame];
    if (self) {
        self.imagesArray = imagesArray;
        self.currentIndex = currentIndex;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
//        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        [_collectionView registerClass:[BLTImagePreviewCell class] forCellWithReuseIdentifier:kPreviewImageCellIdentifier];
        [self addSubview:self.collectionView];
        [self addSubview:self.activityIndicatorView];
        if (self.imagePreviewViewConfigUI) {
            self.imagePreviewViewConfigUI(self.collectionView, self.activityIndicatorView);
        }
    }
    return self;
}



- (void)layoutSubviews{
    [super layoutSubviews];
    _activityIndicatorView.frame = self.bounds;
    //collctionView的frame不为0的时候设置下currentIndex
     if (!CGRectEqualToRect(self.bounds, self.collectionView.bounds)) {
        self.collectionView.frame = self.bounds;
        [self setCurrentIndex:self.currentIndex animated:NO];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    [self setCurrentIndex:currentIndex animated:NO];
}

- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated{
    _currentIndex = currentIndex;
    if (currentIndex < [self.collectionView numberOfItemsInSection:0]) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    }else{
        NSAssert(NO, @"LBLog currentIndex is out of numberOfItemsInSection");
    }
}
#pragma mark - collectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;{
    return self.imagesArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BLTImagePreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPreviewImageCellIdentifier forIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePreviewView:previewImageView:atIndex:)]) {
        [self.delegate imagePreviewView:self previewImageView:cell.imageView atIndex:indexPath.row];
    }else{
        [self p_showImageInImageView:cell.imageView atIndex:indexPath.row];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return collectionView.bounds.size;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView != self.collectionView) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(imagePreviewView:didScrollToIndex:)]) {
        [self.delegate imagePreviewView:self didScrollToIndex:self.currentIndex];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView != self.collectionView) {
        return;
    }
    CGFloat offsetX = self.collectionView.contentOffset.x;
    CGFloat cellW = [self collectionView:self.collectionView layout:self.collectionView.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].width;
    NSInteger currentIndex = offsetX / cellW;
    NSLog(@"lblog scroll offset %@ %@",@(offsetX),@(cellW));
    if (currentIndex != self.currentIndex) {
        //不要用self.  不然走setter方法。。。。。。
        _currentIndex = currentIndex;
    }
}

- (UIImageView *)imageViewAtIndex:(NSInteger)index{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    BLTImagePreviewCell *cell = (BLTImagePreviewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.imageView;
}

- (NSInteger)indexForImageView:(UIImageView *)imageView{
    BLTImagePreviewCell *cell = (BLTImagePreviewCell *)imageView.superview.superview;
    if ([cell isKindOfClass:[BLTImagePreviewCell class]]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        return indexPath.row;
    }
    return 0;
}

#pragma mark - 外部没处理展示数据  内部处理
- (void)p_showImageInImageView:(UIImageView *)imageView atIndex:(NSInteger)index{
    id image = self.imagesArray[index];
    UIImage *placeHolderImage = self.placeHolderImage ? : [BLTImagePreviewView appearance].placeHolderImage;
    if ([image isKindOfClass:[UIImage class]]) {
        imageView.image = image;
    }else if ([image isKindOfClass:[NSURL class]]){
        [self.activityIndicatorView startAnimating];
        [imageView sd_setImageWithURL:image placeholderImage:placeHolderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self.activityIndicatorView stopAnimating];
        }];
    }else if([image isKindOfClass:[NSString class]]){
        NSString *urlString = (NSString *)image;
        NSURL *URL = [NSURL URLWithString:urlString];
        [self.activityIndicatorView startAnimating];
        [imageView sd_setImageWithURL:URL placeholderImage:placeHolderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self.activityIndicatorView stopAnimating];
        }];
    }
}


- (UIActivityIndicatorView *)activityIndicatorView{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicatorView.frame = CGRectMake(0, 0, 60, 60);
        [self addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

@end
