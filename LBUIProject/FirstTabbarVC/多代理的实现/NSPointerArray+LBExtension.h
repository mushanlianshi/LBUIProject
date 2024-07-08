//
//  NSPointerArray+LBExtension.h
//  LBUIProject
//
//  Created by liu bin on 2022/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//NSPointerArray的分类  来实现是否包含  查找索引等功能
//弱引用集合中的对象  对象释放了 会从集合中移除
@interface NSPointerArray (LBExtension)

- (BOOL)lb_containsPointer:(void *)pointer;

- (NSUInteger)lb_indexOfPointer:(void *)pointer;

@end

NS_ASSUME_NONNULL_END
