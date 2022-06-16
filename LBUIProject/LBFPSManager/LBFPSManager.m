//
//  LBFPSManager.m
//  LBUIProject
//
//  Created by liu bin on 2021/6/23.
//

#import "LBFPSManager.h"
#import <QuartzCore/CADisplayLink.h>
#import <UIKit/UIKit.h>
#import "Masonry.h"

@interface LBFPSManager ()

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) NSUInteger fpsCountPerSecond;

@property (nonatomic, assign) CFTimeInterval lastSecondTimeStamp;

@property (nonatomic, strong) UILabel *fpsLab;

@end

@implementation LBFPSManager

static LBFPSManager *instance = nil;

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LBFPSManager alloc] init];
    });
    return instance;
}

- (void)startFPSObserver{
    [self displayLink];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.fpsLab];
    [self.fpsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(-80);
        make.right.mas_offset(-40);
        make.size.mas_equalTo(CGSizeMake(60, 40));
    }];
}

- (void)stopFPSObserver{
    [_displayLink invalidate];
    _displayLink = nil;
    [_fpsLab removeFromSuperview];
    _fpsLab = nil;
}

- (void)p_caculateFPS{
    _fpsCountPerSecond ++;
    if (_lastSecondTimeStamp == 0) {
        _lastSecondTimeStamp = self.displayLink.timestamp;
    }
    CFTimeInterval offset = self.displayLink.timestamp - _lastSecondTimeStamp;
//    1秒计算一次
    if (offset >= 1.0) {
        //fps
        CGFloat fps = _fpsCountPerSecond/offset;
//        NSLog(@"LBLog fps %f  %f %f",fps, offset, self.displayLink.timestamp);
        _lastSecondTimeStamp = self.displayLink.timestamp;
        _fpsCountPerSecond = 0;
        self.fpsLab.text = [NSString stringWithFormat:@"%zd",[NSNumber numberWithFloat:fps].integerValue];
    }
}


- (CADisplayLink *)displayLink{
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(p_caculateFPS)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (UILabel *)fpsLab{
    if (!_fpsLab) {
        _fpsLab = [[UILabel alloc] init];
        _fpsLab.backgroundColor = [UIColor lightGrayColor];
        _fpsLab.textAlignment = NSTextAlignmentCenter;
    }
    return _fpsLab;
}

@end
