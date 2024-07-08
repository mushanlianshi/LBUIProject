//
//  NSObject+LBMultipleDelegate.h
//  LBUIProject
//
//  Created by liu bin on 2022/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//来实现是否支持多代理的分类
@interface NSObject (LBMultipleDelegate)

@property (nonatomic, assign) BOOL lb_multipleDelegatesEnable;

//处理交换delegate方法 也可以手动添加方法支持多代理  只默认delegate多代理
//- (void)lb_registerDelegateWithSelector:(SEL)selector;

- (void)lb_removeDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
