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
}

//设置  子controller自使用statusbar  不用navigationController的
- (UIViewController *)childViewControllerForStatusBarStyle{
    return  self.topViewController;
}

//push时隐藏tabbar
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
            viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
    // 修改tabBra的frame
    CGRect frame = self.tabBarController.tabBar.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
    self.tabBarController.tabBar.frame = frame;
    
    
    id array = [NSMutableArray new];
    dispatch_block_t blk = [^(){
            [array addObject:@"11"];
            NSLog(@"array count = %ld",[array count]);
    } copy];
    
//    id array2 = [NSMutableArray new];
//    UINavigationItem *item = self.navigationItem;
//    dispatch_block_t blk2 = [^(){
//        item.title = @"";
//        item = [UINavigationItem new];
//        [array2 = [NSMutableArray new];
//            NSLog(@"array count = %ld",[array count]);
//    } copy];
}

//set的时候隐藏tabbar
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated{
    [super setViewControllers:viewControllers animated:animated];
    if (viewControllers.count > 1) {
        viewControllers.lastObject.hidesBottomBarWhenPushed = true;
    }
}

- (BOOL)shouldAutorotate{
    return [self.visibleViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.visibleViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}

@end
