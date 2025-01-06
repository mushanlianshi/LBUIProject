//
//  LBMultipleDelegates.h
//  LBUIProject
//
//  Created by liu bin on 2022/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//实现多代理的容器   利用消息转发来实现多代理
@interface LBMultipleDelegatesContainer : NSObject

//若引用delegate的容器
+ (instancetype)weakDelegates;
//强引用delegate的容器
+ (instancetype)strongDelegates;

//获取所有的delegate 只读
@property (nonatomic, strong, readonly) NSPointerArray *delegates;

- (void)addDelegate:(id)delegate;

- (BOOL)removeDelegate:(id)delegate;

- (void)removeAllDelegates;

- (BOOL)containDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
