//
//  LBTestRunloopViewController.h
//  LBUIProject
//
//  Created by liu bin on 2022/5/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//1.线程和runloop一一对应的    key value形式的存储的  key是线程  value是runloop
//CFDictionarySetValue(dic, thread, runloop)
//线程保活   我们持有thread只能保持线程不会dealloc  但会休眠  不在执行任务  需要runloop来进行保活（没有source和timer就会休眠，所以可以给source1添加个MachPort来进行存活，不会被销毁休眠）主线程不一样，主线程什么都不需要
// source0处理手动触发事件  触摸 点击事件等 和 source1基于系统内核port的事件，可以主动唤醒runloop
@interface LBTestRunloopViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
