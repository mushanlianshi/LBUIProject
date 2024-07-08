//
//  LBClockViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/8/2.
//

#import "LBClockViewController.h"
#import <BLTBasicUIKit/BLTBasicUIKit.h>

@interface LBClockViewController ()

@property (nonatomic, strong) NSCalendar *calendar;

@property (nonatomic, strong) UIView *clockView;

@property (nonatomic, strong) UIImageView *hourIV;

@property (nonatomic, strong) UIImageView *minuteIV;

@property (nonatomic, strong) UIImageView *secondIV;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UIImageView *rotateIV;

@property (nonatomic, assign) NSInteger rotateAngle;

@property (nonatomic, strong) UIView *rotateIVAnchorPointView;

@end

@implementation LBClockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.clockView];
    [self.clockView addSubview:self.hourIV];
    [self.clockView addSubview:self.minuteIV];
    [self.clockView addSubview:self.secondIV];
    
    [self.view addSubview:self.rotateIV];
    [self.view addSubview:self.rotateIVAnchorPointView];
    
    self.clockView.blt_centerX = self.view.blt_width / 2;
    self.clockView.blt_y = 100;
    
    self.rotateIV.blt_centerX = self.view.blt_width / 2;
    self.rotateIV.blt_y = self.clockView.blt_bottom + 60;
    
    self.rotateIVAnchorPointView.blt_centerX = self.rotateIV.blt_centerX;
    self.rotateIVAnchorPointView.blt_centerY = self.rotateIV.blt_centerY;
    
//    self.hourIV.blt_x = self.clockView.blt_width / 2 - self.hourIV.blt_width / 2;
//    self.hourIV.blt_bottom = self.clockView.blt_height / 2;
//
//    self.minuteIV.blt_x = self.clockView.blt_width / 2 - self.minuteIV.blt_width / 2;
//    self.minuteIV.blt_bottom = self.clockView.blt_height / 2;
//
//    self.secondIV.blt_x = self.clockView.blt_width / 2 - self.secondIV.blt_width / 2;
//    self.secondIV.blt_bottom = self.clockView.blt_height / 2;
//
    self.hourIV.blt_centerX = self.clockView.blt_width / 2;
    self.hourIV.blt_centerY = self.clockView.blt_height / 2;

    self.minuteIV.blt_centerX = self.clockView.blt_width / 2;
    self.minuteIV.blt_centerY = self.clockView.blt_height / 2;

    self.secondIV.blt_centerX = self.clockView.blt_width / 2;
    self.secondIV.blt_centerY = self.clockView.blt_height / 2;
    [self setAnchorPoint];
}

//设置锚点
- (void)setAnchorPoint{
    self.hourIV.layer.anchorPoint = CGPointMake(0.5, 0.9);
    self.minuteIV.layer.anchorPoint = CGPointMake(0.5, 0.9);
    self.secondIV.layer.anchorPoint = CGPointMake(0.5, 0.9);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self timer];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)animatClock{
    NSUInteger units = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [self.calendar components:units fromDate:[NSDate date]];
    
    CGFloat hourAngle = (components.hour / 12.0) * M_PI * 2;
    CGFloat minuteAngle = (components.minute / 60.0) * M_PI * 2;
    CGFloat secondAngle = (components.second / 60.0) * M_PI * 2;
    
    NSLog(@"LBLog timer animatClock %@ %@ %@",@(hourAngle), @(minuteAngle), @(secondAngle));
    self.hourIV.transform = CGAffineTransformMakeRotation(hourAngle);
    self.minuteIV.transform = CGAffineTransformMakeRotation(minuteAngle);
    self.secondIV.transform = CGAffineTransformMakeRotation(secondAngle);
    
    
    self.rotateAngle ++;
//    [UIView animateKeyframesWithDuration:0.29 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
//            self.rotateIV.transform = CGAffineTransformMakeRotation(self.rotateAngle / 5.0 * M_PI * 2);
//    } completion:nil];
    
    [UIView animateWithDuration:0.29 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.rotateIV.transform = CGAffineTransformMakeRotation(self.rotateAngle / 5.0 * M_PI * 2);
    } completion:nil];
}

- (UIView *)clockView{
    if (!_clockView) {
        _clockView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        _clockView.backgroundColor = [UIColor lightGrayColor];
        _clockView.layer.cornerRadius = 100;
    }
    return _clockView;
}


- (UIImageView *)hourIV{
    if (!_hourIV) {
        _hourIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 6, 40)];
        _hourIV.backgroundColor = [UIColor redColor];
    }
    return _hourIV;
}

- (UIImageView *)minuteIV{
    if (!_minuteIV) {
        _minuteIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 4, 60)];
        _minuteIV.backgroundColor = [UIColor blackColor];
    }
    return _minuteIV;
}

- (UIImageView *)secondIV{
    if (!_secondIV) {
        _secondIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 2, 80)];
        _secondIV.backgroundColor = [UIColor blackColor];
    }
    return _secondIV;
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(animatClock) userInfo:nil repeats:YES];
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [runloop addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (NSCalendar *)calendar{
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
        
    }
    return _calendar;
}

- (UIImageView *)rotateIV{
    if (!_rotateIV) {
        UIImage *image = [UIImage imageNamed:@"face"];
        _rotateIV = [[UIImageView alloc] initWithImage:image];
        _rotateIV.frame = CGRectMake(0, 0, 150, 150.0 * 1280 / 853);
    }
    return _rotateIV;
}

- (UIView *)rotateIVAnchorPointView{
    if (!_rotateIVAnchorPointView) {
        _rotateIVAnchorPointView = [[UIView alloc] init];
        _rotateIVAnchorPointView.layer.cornerRadius = 5;
        _rotateIVAnchorPointView.backgroundColor = [UIColor redColor];
        _rotateIVAnchorPointView.frame = CGRectMake(0, 0, 10, 10);
    }
    return _rotateIVAnchorPointView;
}

@end
