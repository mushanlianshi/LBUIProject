//
//  LBBaseResponseChain.h
//  LBUIProject
//
//  Created by liu bin on 2022/7/25.
//

#import <Foundation/Foundation.h>

@protocol LBResponseChainProtocol <NSObject>

//处理数据 抛出或则终止任务链的
- (void)receiveData:(id)data throwDataBlock:(void(^)(id data))throwDataBlock;

@end

@interface LBResponseChainResultData : NSObject

@property (nonatomic, copy) NSString *type;

@end



@interface LBResponseChainAAA : NSObject<LBResponseChainProtocol>

@end


@interface LBResponseChainBBB : NSObject<LBResponseChainProtocol>

@end




@interface LBResponseChainCCC : NSObject<LBResponseChainProtocol>

@end


@interface LBResponseChainDDD : NSObject<LBResponseChainProtocol>

@end
