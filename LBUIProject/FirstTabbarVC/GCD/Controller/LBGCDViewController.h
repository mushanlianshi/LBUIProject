//
//  LBGCDViewController.h
//  LBUIProject
//
//  Created by liu bin on 2021/7/19.
//

#import <UIKit/UIKit.h>

//多线程
//1.同步不具备开启新线程的能力，顺序执行
//2.当前串行队列 同步到当前串行队列执行任务  死锁
//同步到串行队列执行的意义： 比如在并发队列中同步到串行队列执行任务，很多三方库的实现方式，dispatch_sync 的价值，不在于“换线程”，而在于“将任务纳入串行控制 + 等待结果完成” 串行队列保证线程安全， 同步保证顺序执行
@interface LBGCDViewController : UIViewController

@end


