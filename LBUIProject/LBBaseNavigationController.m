//
//  LBBaseNavigationController.m
//  LBUIProject
//
//  Created by liu bin on 2022/6/23.
//

#import "LBBaseNavigationController.h"

@interface LBBaseNavigationController ()

@end

@implementation LBBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIViewController *)childViewControllerForStatusBarStyle{
    return  self.topViewController;
}

@end
