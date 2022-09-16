//
//  LBHelper.h
//  LBUIProject
//
//  Created by liu bin on 2022/6/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

////可以用来处理一些方法交换的 不需要在load中就交换的  减少load方法影响启动事件的   比如按钮防止多次点击的  设置响应区域  tableview 点击元素内容采集的
@interface LBHelper : NSObject

+ (BOOL)executeBlock:(dispatch_block_t)closure onceIdentifier:(NSString *)onceIdentifier;

@end

NS_ASSUME_NONNULL_END
