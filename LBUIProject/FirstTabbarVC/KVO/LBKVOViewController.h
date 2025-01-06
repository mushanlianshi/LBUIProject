//
//  LBKVOViewController.h
//  LBUIProject
//
//  Created by liu bin on 2021/11/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//在运行时如果有observer，类的isa指针会指向NSKVONotifying_开头的一个衍生子类， 在set方法中插入，调用willChangeValueForKey和didChangeValueForKey方法来实现通知观察者。重写类的set方法不会阻止kvo的触发，因为运行时的时候isa指针已经变了，不在指向这个类，这个类是set方法指针也已经变了，会指向_NSSetObjectValueAndNotify一个C语言方法
//。重写didChangeValueForKey 不掉super方法  可以阻止kvo的发生。
@interface LBKVOViewController : UIViewController

@end


@interface LBKVOObject : NSObject

@property (nonatomic, copy) NSString *age;

@end

NS_ASSUME_NONNULL_END
