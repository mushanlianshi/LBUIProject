//
//  LBReponseChainManager.m
//  LBUIProject
//
//  Created by liu bin on 2022/7/25.
//

#import "LBResponseChainManager.h"
#import "NSObject+LBResponseChain.h"


@interface LBResponseChainManager ()

@property (nonatomic, strong) id data;

@property (nonatomic, strong) NSMutableArray <id<LBResponseChainProtocol>>*chainList;

//当前处理的责任链
@property (nonatomic, strong) id<LBResponseChainProtocol> currentChain;

@end

@implementation LBResponseChainManager

//添加数据源
- (LBResponseChainManager *(^)(id data))addData{
    
    return ^(id data){
        self.data = data;
        return self;
    };
}

//添加责任链  block返回链式调用  设置责任链下一个触发的
- (LBResponseChainManager *(^)(id<LBResponseChainProtocol> chain))addChain{
    return ^(id<LBResponseChainProtocol> chain){
        if (chain) {
            [self.chainList addObject:chain];
            
            if (self.currentChain) {
                NSObject *curObj = (NSObject *)self.currentChain;
                curObj.lb_nextChain = chain;
            }
            self.currentChain = chain;
        }
        return self;
    };
}

- (void)setThrowDataBlock:(void (^)(id _Nonnull))throwDataBlock{
    _throwDataBlock = throwDataBlock;
    [self handleData];
}

- (void)handleData{
    [self currentChain:self.chainList.firstObject resultData:self.data];
}

- (void)currentChain:(id<LBResponseChainProtocol>)currentChain resultData:(id)resultData{
    if (currentChain == nil) {
        return;
    }
    [currentChain receiveData:resultData throwDataBlock:^(id data) {
        NSObject *curObj = currentChain;
        if (curObj.lb_nextChain) {
            [self currentChain:curObj.lb_nextChain resultData:resultData];
        }else if(self.throwDataBlock){
            self.throwDataBlock(data);
        }
    }];
}

- (NSMutableArray<id<LBResponseChainProtocol>> *)chainList{
    if (!_chainList) {
        _chainList = [[NSMutableArray alloc] init];
    }
    return _chainList;
}

@end
