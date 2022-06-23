//
//  main.m
//  LBUIProject
//
//  Created by liu bin on 2021/5/27.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

//xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m

int main(int argc, char * argv[]) {
    printf("LBLog main ==============");
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
