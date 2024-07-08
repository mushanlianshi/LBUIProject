//
//  LBReponseChainManager.h
//  LBUIProject
//
//  Created by liu bin on 2022/7/25.
//

#import <Foundation/Foundation.h>
#import "LBResponseChain.h"

NS_ASSUME_NONNULL_BEGIN

//添加 管理责任链的
@interface LBResponseChainManager : NSObject

//添加数据源 
- (LBResponseChainManager *(^)(id data))addData;

//添加责任链  block返回链式调用
- (LBResponseChainManager *(^)(id<LBResponseChainProtocol> chain))addChain;

//设置异常block  开始执行任务
@property (nonatomic, copy) void(^throwDataBlock)(id data);

@end

NS_ASSUME_NONNULL_END
