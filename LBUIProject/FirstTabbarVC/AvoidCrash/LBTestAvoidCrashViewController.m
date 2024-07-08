//
//  LBTestAvoidCrashViewController.m
//  LBUIProject
//
//  Created by liu bin on 2022/1/6.
//

#import "LBTestAvoidCrashViewController.h"
#import <objc/runtime.h>

@interface LBTestAvoidCrashViewController ()

@end

@implementation LBTestAvoidCrashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *array = [[NSArray alloc] init];
    
    array[0];
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





@implementation NSArray (Avoid)

+ (void)load{
    Method originalMethod = class_getInstanceMethod(NSClassFromString(@"__NSArray0"), @selector(objectAtIndex:));
    Method nowMethod = class_getInstanceMethod(NSClassFromString(@"__NSArray0"), @selector(lbObjectAtIndex:));
    method_exchangeImplementations(originalMethod, nowMethod);
}

- (id)lbObjectAtIndex:(NSUInteger)index{
    if (self == nil || self.count == 0) {
        return nil;
    }
    if (index <= self.count) {
        return nil;
    }
    return [self lbObjectAtIndex:index];
}

@end
