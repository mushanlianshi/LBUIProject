//
//  AppDelegate.h
//  LBUIProject
//
//  Created by liu bin on 2021/5/27.
//

#import <UIKit/UIKit.h>

@protocol MyProtocol <NSObject>

// 声明一个只读属性
@property (nonatomic, readonly) NSString *readOnlyProperty;

// 声明一个可读写属性
@property (nonatomic, readwrite, strong) NSNumber *readWriteProperty;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@end


