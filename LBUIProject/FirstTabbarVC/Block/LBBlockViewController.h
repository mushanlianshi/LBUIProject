//
//  LBBlockViewController.h
//  LBUIProject
//
//  Created by liu bin on 2021/8/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//全局，不访问外部任何变量，copy后仍是全局block；
//栈，block里有访问外部变量，函数返回后立即销毁，即使后面strong和copy都会crash；
//堆，有栈block拷贝过来，就和OC对象一样，可访问外部变量；
@interface LBBlockViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
