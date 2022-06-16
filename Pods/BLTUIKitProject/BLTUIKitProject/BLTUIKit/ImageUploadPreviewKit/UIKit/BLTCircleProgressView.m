//
//  BLTCircleProgressView.m
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/25.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import "BLTCircleProgressView.h"

@interface BLTCircleProgressView ()

@property (nonatomic, strong) UIBezierPath *backgroundCirclePath;

@property (nonatomic, strong) CAShapeLayer *backgroundCircleLayer;

@property (nonatomic, strong) CAShapeLayer *progressCircleLayer;

@end

@implementation BLTCircleProgressView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.circleWidth = 10;
        self.circleRaduis = 12;
        self.backgroundCircleColor = [UIColor blackColor];
        self.progressCircleColor = [UIColor whiteColor];
        [self.layer addSublayer:self.backgroundCircleLayer];
        [self.layer addSublayer:self.progressCircleLayer];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress{
    progress = fmin(progress, 1);
    progress = fmax(progress, 0);
    _progress = progress;
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = -M_PI_2 + M_PI * 2 * progress;
    UIBezierPath *circleProgressPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2) radius:self.circleRaduis startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.progressCircleLayer.path = circleProgressPath.CGPath;
}

- (void)refreshBackgroundCircle{
    _backgroundCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2) radius:self.circleRaduis startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
    self.backgroundCircleLayer.path = self.backgroundCirclePath.CGPath;
}

- (void)setCircleWidth:(CGFloat)circleWidth{
    _circleWidth = circleWidth;
    self.backgroundCircleLayer.lineWidth = circleWidth;
    self.progressCircleLayer.lineWidth = circleWidth;
}

- (void)setCircleRaduis:(CGFloat)circleRaduis{
    _circleRaduis = circleRaduis;
    self.backgroundCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2) radius:self.circleRaduis startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
    self.backgroundCircleLayer.path = self.backgroundCirclePath.CGPath;
}

- (void)setBackgroundCircleColor:(UIColor *)backgroundCircleColor{
    _backgroundCircleColor = backgroundCircleColor;
    self.backgroundCircleLayer.strokeColor = backgroundCircleColor.CGColor;
}

- (void)setProgressCircleColor:(UIColor *)progressCircleColor{
    _progressCircleColor = progressCircleColor;
    self.progressCircleLayer.strokeColor = progressCircleColor.CGColor;
}



- (UIBezierPath *)backgroundCirclePath{
    if (!_backgroundCirclePath) {
        _backgroundCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2) radius:self.circleRaduis startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
    }
    return _backgroundCirclePath;
}


- (CAShapeLayer *)backgroundCircleLayer{
    if (!_backgroundCircleLayer) {
        _backgroundCircleLayer = [CAShapeLayer layer];
//        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2) radius:self.circleRaduis startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
        _backgroundCircleLayer.path = self.backgroundCirclePath.CGPath;
        _backgroundCircleLayer.lineWidth = self.circleWidth;
        _backgroundCircleLayer.strokeColor = self.backgroundCircleColor.CGColor;
        _backgroundCircleLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _backgroundCircleLayer;
}

- (CAShapeLayer *)progressCircleLayer{
    if (!_progressCircleLayer) {
        _progressCircleLayer = [CAShapeLayer layer];
        _progressCircleLayer.lineWidth = self.circleWidth;
//        _progressCircleLayer.fillColor = self.
        _progressCircleLayer.strokeColor = self.progressCircleColor.CGColor;
        _progressCircleLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _progressCircleLayer;
}


@end
