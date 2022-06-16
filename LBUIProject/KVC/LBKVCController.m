//
//  LBKVCController.m
//  LBUIProject
//
//  Created by liu bin on 2021/11/16.
//

#import "LBKVCController.h"

@interface LBKVCController ()

@end

@implementation LBKVCController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    LBKVCTestObject *obj = [[LBKVCTestObject alloc] init];
//    obj.name = @"LBLog name";
//    NSString *name = NSStringFromSelector(@selector(name));
//    NSString *value = [obj valueForKey:name];
    [obj setValue:@"123 name" forKey:@"name"];
    NSLog(@"LBLog value is %@",[obj valueForKey:@"name"]);
    
    [obj setValue:@(true) forKey:@"object"];
    
    NSLog(@"LBLog value is %@",[obj valueForKey:@"object"]);
    
//    NSLog(@"LBLog value is %@",[obj valueForKey:@"haha"]);
}

- (void)dealloc
{
    NSLog(@"LBLog %@ dealloc =================",NSStringFromClass([self class]));
}

@end


@interface LBKVCTestObject (){
    NSString *_name;
    BOOL isObject;
}

//@property (nonatomic, copy) NSString *name;

@end



@implementation LBKVCTestObject

//允不允许访问实例变量
+ (BOOL)accessInstanceVariablesDirectly{
    return true;
}


@end
