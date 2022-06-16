//
//  LBLoadAndInitializeSubClassController+Test4.m
//  LBUIProject
//
//  Created by liu bin on 2022/1/6.
//

#import "LBLoadAndInitializeSubClassController+Test4.h"

@implementation LBLoadAndInitializeSubClassController (Test4)

+ (void)load{
    NSLog(@"LBlog subClass44 load ========");
}

+ (void)initialize{
    NSLog(@"LBlog subClass44 initialize ========");
}

- (void)test{
    NSLog(@"LBlog test33");
}

@end
