//
//  LBLoadAndInitializeController.h
//  LBUIProject
//
//  Created by liu bin on 2021/11/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//3.类方法load和initialize 方法
//load方法在程序加载的时候调用，在main函数之前，先调用父类的load方法  在调用子类的load方法,然后在调用子类分类的方法。load方法不是走的objec_messageSend消息转发流程，所以分类的方法不会覆盖类的load方法，
// 1.分类的load方法执行顺序和build phases里面的编译的顺序有关， 前面的优先调用。方法在编译的时候就加载到了内存中，执行的时候到内存中查找执行。
// 2.分类中不是load的方法  执行的情况是build phases里面最后编译分类的方法会被调用  前面的同名方法在方法列表中会靠后，导致调用不到，如果一定要确保类的方法被调用，不会被覆盖，可以用runtime获取方法列表  倒叙查找第一个方法执行
//
//initialize方法会先调用父类的方法，在调用自身的initialize方法。走的是objc_messageSend，如果有分类重写了initialize方法会覆盖类的initialize方法，因为消息查找到了method就执行了不会再查找(这也是为啥交换方法写在load方法里，防止别的分类重写了被覆盖了)。 如果子类的intialize方法没有实现  会调用父类的 会导致initialize方法可能会被多次调用
//我们在load方法中交换 为什么要dispatch_once保护，防止误手动调用导致交换方法失效， 为什么不在intialize方法中交换，防止有人分类重写了这个方法导致被覆盖掉无效
@interface LBLoadAndInitializeController : UIViewController

@end


@interface LBLoadAndInitializeSubClassController : LBLoadAndInitializeController

@end


@interface LBLoadAndInitializeSubClassController (Test1)

@end


@interface LBLoadAndInitializeSubClassController (Test2)

@end


@interface LBLoadAndInitializeSubClassController22 : LBLoadAndInitializeController

@end
NS_ASSUME_NONNULL_END
