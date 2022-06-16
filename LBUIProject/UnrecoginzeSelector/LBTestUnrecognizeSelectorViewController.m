//
//  LBTestUnrecognizeSelectorViewController.m
//  LBUIProject
//
//  Created by liu bin on 2022/5/27.
//

#import "LBTestUnrecognizeSelectorViewController.h"
#import "Masonry.h"

@interface LBTestUnrecognizeSelectorViewController ()

@end

@implementation LBTestUnrecognizeSelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor blackColor];
    [button setTitle:@"unrecognize selector" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(unrecogizeSelectorClicked1212:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 60));
    }];
}

//消除编译  
- (void)unrecogizeSelectorClicked:(NSString *)test{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
