//
//  LBBezierpathViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/8/3.
//

#import "LBBezierpathViewController.h"

@interface LBBezierpathViewController ()

@end

@implementation LBBezierpathViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"贝瑟尔曲线动画";
    //create a path
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:CGPointMake(0, 150)];
    [bezierPath addCurveToPoint:CGPointMake(350, 150) controlPoint1:CGPointMake(100, 400) controlPoint2:CGPointMake(200, -100)];
    
    //draw the path using a CAShapeLayer
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.path = bezierPath.CGPath;
    pathLayer.fillColor = [UIColor clearColor].CGColor;
    pathLayer.strokeColor = [UIColor redColor].CGColor;
    pathLayer.lineWidth = 2.0f;
    [self.view.layer addSublayer:pathLayer];
    
    //add the ship
    CALayer *shipLayer = [CALayer layer];
    shipLayer.frame = CGRectMake(0, 0, 64, 64);
    shipLayer.position = CGPointMake(0, 150);
    shipLayer.contents = (__bridge id _Nullable)([UIImage imageNamed: @"face"].CGImage);
    [self.view.layer addSublayer:shipLayer];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    //create the keyframe animation
    animation.keyPath = @"position";
    animation.duration = 2.5;
    animation.path = bezierPath.CGPath;
    //自动调整的方向
    animation.rotationMode = kCAAnimationRotateAuto;
    //控制动画结束  停留在原地的 和removedOnCompletion = NO一起使用
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    
    [shipLayer addAnimation:animation forKey:nil];
} 

@end
