//
//  LBTestAvoidCrashViewController.m
//  LBUIProject
//
//  Created by liu bin on 2022/1/6.
//

#import "LBTestAvoidCrashViewController.h"
#import <objc/runtime.h>

@interface LBTestAfterBlock: NSObject

- (void)executeBlock:(dispatch_block_t)block;

@end


@implementation LBTestAfterBlock

- (void)executeBlock:(dispatch_block_t)block{
    
}

@end

@interface LBTestAvoidCrashViewController ()

@end

@implementation LBTestAvoidCrashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *array = [[NSArray alloc] init];
    
//    array[0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.title = @"ewfwf";
        NSLog(@"LBLog LBTestAvoidCrashViewController execute ----");
    });
    
}


- (void)dealloc
{
    NSLog(@"LBLog LBTestAvoidCrashViewController dealloc ----");
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
