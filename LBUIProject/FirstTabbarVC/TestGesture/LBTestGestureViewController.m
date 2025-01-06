//
//  LBTestGestureViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/6/4.
//

#import "LBTestGestureViewController.h"
#import "Masonry.h"
#import "LBTestGestureView.h"
#import "LBTransmitView.h"


@interface LBTestGestureViewController ()

@property (nonatomic, strong) LBTestGestureView *gestureView;



@end

@implementation LBTestGestureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    LBTransmitView *transmitView = [[LBTransmitView alloc] init];
    [self.view addSubview:transmitView];
    [transmitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
//    [self.view addSubview:self.gestureView];
//
//    [self.gestureView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(self.view);
//    }];

}

- (LBTestGestureView *)gestureView{
    if (!_gestureView) {
        _gestureView = [[LBTestGestureView alloc] init];
    }
    return _gestureView;
}




@end
