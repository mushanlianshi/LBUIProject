//
//  LLTextRecogineImageView.m
//  LBUIProject
//
//  Created by liu bin on 2021/7/16.
//

#import "LLTextRecogineImageView.h"
#import "Masonry.h"
#import <BLTUIKitProject/BLTUI.h>

@interface LLTextRecogineImageView ()<UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation LLTextRecogineImageView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
//        如果collectionview父控件上有gesture手势  会导致colllection点击事件无效   因为gesture手势优先级更高 我们需要设置gesture识别代理
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureClicked:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    如果点击的view是collectionview的子视图  则不响应手势  这样collectionview的点击事件就走了
    if ([touch.view isDescendantOfView:self.collectionView]) {
        return NO;
    }
    return YES;
}

- (void)gestureClicked:(UITapGestureRecognizer *)tap{
    NSLog(@"lblog gestureClicked ===== ");
}

- (void)setDataSources:(NSArray<UIImage *> *)dataSources{
    _dataSources = dataSources;
    [self.collectionView reloadData];
}

#pragma mark - collection delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
   return self.dataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LLTextRecogineImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([LLTextRecogineImageCell class]) forIndexPath:indexPath];
   
    cell.image = self.dataSources[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    BLTImagePreviewController *previewVC = [[BLTImagePreviewController alloc] initWithImages:self.dataSources currentIndex:indexPath.row canDelete:NO];
//    [self presentViewController:previewVC animated:YES completion:nil];
    if (self.previewImageBlock) {
        self.previewImageBlock(indexPath.row, self.dataSources);
    }
}


- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemW = (BLT_DEF_SCREEN_WIDTH - 60 - 30) / 3;
        
        flowLayout.itemSize = CGSizeMake(itemW, itemW);
        flowLayout.minimumInteritemSpacing = 15;
        flowLayout.minimumLineSpacing = 15;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, BLT_DEF_SCREEN_WIDTH, 200) collectionViewLayout:flowLayout];
        [_collectionView registerClass:[LLTextRecogineImageCell class] forCellWithReuseIdentifier:NSStringFromClass([LLTextRecogineImageCell class])];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.userInteractionEnabled = YES;
    }
    return _collectionView;
}

@end






@interface LLTextRecogineImageCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end



@implementation LLTextRecogineImageCell


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
//            make.size.mas_equalTo(CGSizeMake(120, 100));
        }];
    }
    return self;
}


- (void)setImage:(UIImage *)image{
    _image = image;
    self.imageView.image = image;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [UIImageView blt_imageViewWithMode:UIViewContentModeScaleAspectFill];
        _imageView.blt_layerCornerRaduis = 10;
    }
    return _imageView;
}

@end
