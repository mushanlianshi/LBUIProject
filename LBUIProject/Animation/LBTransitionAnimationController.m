//
//  LBTransitionAnimationController.m
//  LBUIProject
//
//  Created by liu bin on 2021/8/4.
//

#import "LBTransitionAnimationController.h"
#import <BLTUIKitProject/BLTUI.h>
#import "Masonry.h"


//过渡动画 transition  CATransition 并不作用于指定的图层属性，这就是说你可以在即使不能准确得 知改变了什么的情况下对图层做动画
//我们证实了过渡是一种对那些不太好做平滑动画属性的强大工具，但
//是 CATransition 的提供的动画类型太少了
//过渡动画做基础的原则就是对原始的图层 外观截图，然后添加一段动画，平滑过渡到图层改变之后那个截图的效果
@interface LBTransitionAnimationController ()

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, copy) NSArray *imageArray;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UIImageView *removeIV;

@end


@implementation LBTransitionAnimationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"过渡动画";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 200));
    }];
    [self.view addSubview:self.removeIV];
    [self.removeIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.imageView.mas_bottom).mas_offset(60);
    }];
    [self transitionImageView];
    [self startTimer];
    
}

- (void)startTimer{
    BLT_WS(weakSelf);
    if (@available(iOS 10.0, *)) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
            weakSelf.index ++;
            [weakSelf transitionImageView];
            [weakSelf removeTransitionIV];
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)transitionImageView{
    NSInteger index = self.index % self.imageArray.count;
    NSLog(@"LBLog image transtion %@",@(index));
    UIImage *image = [UIImage imageNamed:self.imageArray[index]];
    
    //图片设置的动画  用不了CAKeyFrameAnimation CABasicAnimation等  只能使用过渡动画
    CATransition *transition = [[CATransition alloc] init];
    //subtype 只有在type不等于发的才起作用
//    transition.type = kCATransitionFade;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromLeft;
    transition.duration = 0.5;
    [self.imageView.layer addAnimation:transition forKey:nil];
    self.imageView.image = image;
}


//过渡动画   对于不知道要发生什么  做动画
- (void)removeTransitionIV{
//    第一种  对于要动画的父类的layer添加过渡动画
//    CATransition *transition = [[CATransition alloc] init];
//    //subtype 只有在type不等于发的才起作用
//    transition.type = kCATransitionFade;
//    transition.duration = 0.5;
//    [self.view.layer addAnimation:transition forKey:nil];
////    移除动画
////    if (self.removeIV.superview) {
////        [self.removeIV removeFromSuperview];
////    }else{
////        [self.view addSubview:self.removeIV];
////    }
////    隐藏动画
//    self.removeIV.hidden = !self.removeIV.hidden;
    
    
    
//    第二种
    UIViewAnimationOptions option = self.removeIV.isHidden ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown;
    NSLog(@"LBLog option is %@",@(option));
    [UIView transitionWithView:self.removeIV duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.removeIV.hidden = !self.removeIV.hidden;
    } completion:^(BOOL finished) {

    }];
    
    
    
//    self.removeIV.hidden = NO;
//    [UIView animateWithDuration:0.5 animations:^{
////        self.removeIV.hidden = !self.removeIV.hidden;
//        self.removeIV.blt_x += 100;
//    } completion:^(BOOL finished) {
//
//    }];

//    self.removeIV.hidden = !self.removeIV.hidden;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (NSArray *)imageArray{
    if (!_imageArray) {
        _imageArray = @[@"image1",@"image2",@"image3",@"image3"];
    }
    return _imageArray;
}

- (UIImageView *)removeIV{
    if (!_removeIV) {
        _removeIV = [UIImageView blt_imageViewWithImage:[UIImage imageNamed:@"image1"]];
    }
    return _removeIV;
}


- (void)dealloc
{
    NSLog(@"LBLog %@ dealloc =================",NSStringFromClass([self class]));
    [self.timer invalidate];
    self.timer = nil;
}

@end
