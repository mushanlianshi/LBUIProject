//
//  LBCloseDoorAnimationViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/8/4.
//

#import "LBCloseDoorAnimationViewController.h"
#import <BLTUIKitProject/BLTUI.h>
#import "Masonry.h"

@interface LBCloseDoorAnimationViewController ()

@property (nonatomic, strong) UIImageView *doorIV;

@end

@implementation LBCloseDoorAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.doorIV];
//    [self.doorIV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.mas_equalTo(self.view);
//        make.width.mas_equalTo(200);
//        make.height.mas_equalTo(self.doorIV.mas_width).multipliedBy(self.doorIV.image.size.height / self.doorIV.image.size.width);
//    }];
    
    self.doorIV.frame = CGRectMake(0, 200, 200, 300);
    
    //把锚点改成最左边   开关门动画以最左边稳准
    self.doorIV.layer.anchorPoint = CGPointMake(0, 0.5);
    
    //1.设置看起来有立体效果
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0 / 500.0;
    self.view.layer.sublayerTransform = perspective;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    animation.duration = 1;
    animation.speed = 1;
    animation.toValue = @(-M_PI_4);
    animation.autoreverses = YES;
//    animation.removedOnCompletion = NO;
//    animation.fillMode = kCAFillModeForwards;
    [self.doorIV.layer addAnimation:animation forKey:nil];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecoginzer:)];
    [self.view addGestureRecognizer:panGesture];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"LBLog time offset  %@",@(self.doorIV.layer.timeOffset));
        self.doorIV.layer.timeOffset = 0.5;
    });
}


- (void)panGestureRecoginzer:(UIPanGestureRecognizer *)panGesture{
    //获取偏移量
    CGFloat x = [panGesture translationInView:self.view].x;
    NSLog(@"LBLog pangesture x %@",@(x));
    //设置超过一半距离的手势到下面就不识别了
    x/= self.view.blt_width / 2;
    CFTimeInterval timeOffset = self.doorIV.layer.timeOffset;
    //最大1   最小0
    timeOffset = MIN(0.999, MAX(0, timeOffset - x));
    NSLog(@"LBLog time offset  %@",@(timeOffset));
    self.doorIV.layer.timeOffset = timeOffset;
    //清空偏移量
    [panGesture setTranslation:CGPointZero inView:self.view];
}



- (UIImageView *)doorIV{
    if (!_doorIV) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_0568" ofType:@"HEIC"];
        _doorIV = [UIImageView blt_imageViewWithImage:[UIImage imageWithContentsOfFile:path]];
    }
    return _doorIV;
}

@end
