//
//  BLTImagePreviewController.m
//  BLTUIKitProject_Example
//
//  Created by liu bin on 2020/3/24.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import "BLTImagePreviewController.h"
#import "BLTImagePreviewView.h"
#import "BLTImagePreviewControllerAnimator.h"

@interface BLTImagePreviewController ()<BLTImagePreviewViewDelegate, BLTImagePreviewNaviBarDelegate, UIViewControllerTransitioningDelegate>

//navibar是否在渐变动画
@property (nonatomic, assign) BOOL naviBarAnimating;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) CGPoint panGestureStartPoint;

@property (nonatomic, weak) UIImageView *panGestureStartImageView;

@property (nonatomic, strong) BLTImagePreviewControllerAnimator *transitonAnimator;

@end

@implementation BLTImagePreviewController

- (instancetype)initWithImages:(NSArray *)imageArray currentIndex:(NSInteger)currentIndex canDelete:(NSInteger)canDelete{
    self = [self init];
    if (self) {
        self.imagesArray = imageArray;
        self.currentIndex = currentIndex;
        _canDelete = canDelete;
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        [self transitonAnimator];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _imagePreviewView = [[BLTImagePreviewView alloc] initWithFrame:self.view.bounds imagesArray:self.imagesArray currentIndex:self.currentIndex];
    _imagePreviewView.frame = self.view.bounds;
    _imagePreviewView.delegate = self;
    [self.view addSubview:self.imagePreviewView];
    [_imagePreviewView layoutIfNeeded];
    [self.view addSubview:self.naviBar];
    [self refreshCurrentIndexTitle];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addGestureRecognizer:self.tapGesture];
    [self.view addGestureRecognizer:self.panGesture];
    [self.naviBar refreshNaviBarUIConfig:^(UIButton *deleteButton, UILabel *titleLab) {
        deleteButton.hidden = !self.canDelete;
    }];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.imagePreviewView.frame = self.view.bounds;
}

#pragma mark - imagePreview delegate
- (void)imagePreviewView:(BLTImagePreviewView *)imagePreviewView didScrollToIndex:(NSInteger)scrollToIndex{
    self.currentIndex = scrollToIndex;
    [self refreshCurrentIndexTitle];
}

- (void)tapGestureClicked:(UITapGestureRecognizer *)tapGesture{
    if (self.naviBarAnimating) {
        return;
    }
    BOOL naviBarHidden = self.naviBar.hidden;
    if (naviBarHidden) {
        self.naviBar.alpha = 0;
        self.naviBar.hidden = NO;
        self.naviBarAnimating = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.naviBar.alpha = 1;
        } completion:^(BOOL finished) {
            self.naviBarAnimating = NO;
        }];
    }else{
        self.naviBar.alpha = 1;
        self.naviBarAnimating = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.naviBar.alpha = 0;
        } completion:^(BOOL finished) {
            self.naviBar.hidden = YES;
            self.naviBarAnimating = NO;
        }];
    }
}

- (void)handleDismissPanGesture:(UIPanGestureRecognizer *)panGesture{
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            self.panGestureStartPoint = [panGesture locationInView:self.view];
            self.panGestureStartImageView = [self.imagePreviewView imageViewAtIndex:self.imagePreviewView.currentIndex];
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [panGesture locationInView:self.view];
            CGFloat offsetX = point.x - self.panGestureStartPoint.x;
            CGFloat offsetY = point.y - self.panGestureStartPoint.y;
            CGFloat scale = 1;
            CGFloat alpha = 1;
            //向下
            if (offsetY > 0) {
                scale = 1 - offsetY / CGRectGetHeight(self.view.bounds) / 2;
                alpha = 1 - offsetY / CGRectGetHeight(self.view.bounds) * 2;
            }else{
                
            }
            //做动画
            CGAffineTransform transform = CGAffineTransformMakeTranslation(offsetX, offsetY);
            transform = CGAffineTransformScale(transform, scale, scale);
            self.view.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:alpha];
            self.naviBar.backgroundColor = [self.naviBar.backgroundColor colorWithAlphaComponent:alpha];
            self.panGestureStartImageView.transform = transform;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint enablePoint = [panGesture locationInView:self.view];
            CGFloat offsetY = enablePoint.y - self.panGestureStartPoint.y;
            //大于一半屏幕的1/3  就认为触发返回
            if (offsetY > CGRectGetHeight(self.view.bounds) / 2 / 3) {
                [self back];
            }else{
                //手势不识别  默认失败
                [self panGestureRecognizeFailed];
            }
        }
            break;
        default:
            [self panGestureRecognizeFailed];
            break;
    }
}


- (void)panGestureRecognizeFailed{
    self.panGestureStartImageView.transform = CGAffineTransformIdentity;
    self.panGestureStartPoint = CGPointZero;
    self.view.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:1];
    self.naviBar.backgroundColor = [self.naviBar.backgroundColor colorWithAlphaComponent:1];
}


- (void)refreshCurrentIndexTitle{
    NSInteger showIndex = MIN(self.currentIndex + 1, self.imagesArray.count);
    NSString *title = [NSString stringWithFormat:@"%ld/%ld",showIndex,self.imagesArray.count];
    [self.naviBar refreshNaviBarUIConfig:^(UIButton *deleteButton, UILabel *titleLab) {
        titleLab.text = title;
    }];
}

#pragma mark - navibar delegate
- (void)navibarDidClickBack:(BLTImagePreviewNaviBar *)naviBar{
    [self back];
}

- (void)navibarDidClickDelete:(BLTImagePreviewNaviBar *)navibar{
    //删除的是最后一个  刷新当前索引
    if (self.currentIndex == self.imagesArray.count) {
        self.currentIndex --;
        self.imagePreviewView.currentIndex = self.currentIndex;
    }
    NSMutableArray *array = self.imagesArray.mutableCopy;
    [array removeObjectAtIndex:self.currentIndex];
   
    self.imagesArray = array.copy;
    [self refreshCurrentIndexTitle];
    [self.imagePreviewView.collectionView reloadData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePreviewController:didDeleteAtIndex:)]) {
        [self.delegate imagePreviewController:self didDeleteAtIndex:self.currentIndex];
    }
    //删除完了  没有图片了
    if (self.imagesArray.count == 0) {
        [self back];
    }
}

- (void)setImagesArray:(NSArray *)imagesArray{
    _imagesArray = imagesArray;
    self.imagePreviewView.imagesArray = imagesArray;
}

- (void)setCanDelete:(BOOL)canDelete{
    _canDelete = canDelete;
    [self.naviBar refreshNaviBarUIConfig:^(UIButton *deleteButton, UILabel *titleLab) {
        deleteButton.hidden = !canDelete;
    }];
}

- (void)back{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 转场动画
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    if (!self.startAnimatingImageView) {
        return nil;
    }
    return self.transitonAnimator;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    if (!self.endAnimatingImageView) {
        return nil;
    }
    return self.transitonAnimator;
}


- (BLTImagePreviewNaviBar *)naviBar{
    if (!_naviBar) {
        _naviBar = [[BLTImagePreviewNaviBar alloc] init];
        _naviBar.backgroundColor = [UIColor blackColor];
        _naviBar.delegate = self;
    }
    return _naviBar;
}

- (UITapGestureRecognizer *)tapGesture{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] init];
        [_tapGesture addTarget:self action:@selector(tapGestureClicked:)];
    }
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissPanGesture:)];
    }
    return _panGesture;
}


- (BLTImagePreviewControllerAnimator *)transitonAnimator{
    if (!_transitonAnimator) {
        _transitonAnimator = [[BLTImagePreviewControllerAnimator alloc] init];
        _transitonAnimator.imagePreviewController = self;
        self.transitioningDelegate = self;
    }
    return _transitonAnimator;
}


@end
