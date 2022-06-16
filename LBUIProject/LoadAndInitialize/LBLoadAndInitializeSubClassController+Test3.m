//
//  LBLoadAndInitializeSubClassController+Test3.m
//  LBUIProject
//
//  Created by liu bin on 2022/1/6.
//

#import "LBLoadAndInitializeSubClassController+Test3.h"

@implementation LBLoadAndInitializeSubClassController (Test3)

+ (void)load{
    NSLog(@"LBlog subClass33 load ========");
}

+ (void)initialize{
    NSLog(@"LBlog subClass33 initialize ========");
}

- (void)test{
    NSLog(@"LBlog test33");
}

@end
