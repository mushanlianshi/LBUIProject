//
//  LBBaseResponseChain.m
//  LBUIProject
//
//  Created by liu bin on 2022/7/25.
//

#import "LBResponseChain.h"

@implementation LBResponseChainResultData


@end

@implementation LBResponseChainAAA

- (void)receiveData:(id)data throwDataBlock:(void (^)(id))throwDataBlock{
    NSLog(@"LBLog LBResponseChainAAA receive data");
    if ([data isKindOfClass:[LBResponseChainResultData class]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([((LBResponseChainResultData *)data).type isEqualToString:@"1"]) {
                NSLog(@"LBLog LBResponseChainAAA process type is %@",((LBResponseChainResultData *)data).type);
                if(throwDataBlock != nil){
                    throwDataBlock(@"LBResponseChainAAA process");
                }
            }else{
                if(throwDataBlock != nil){
                    throwDataBlock(@"LBResponseChainAAA not match");
                }
            }
        });
    }else if(throwDataBlock != nil){
        throwDataBlock(@"LBResponseChainAAA cannot process");
    }
}

@end



@implementation LBResponseChainBBB

- (void)receiveData:(id)data throwDataBlock:(void (^)(id))throwDataBlock{
    NSLog(@"LBLog LBResponseChainBBB receive data");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([data isKindOfClass:[LBResponseChainResultData class]]) {
            if ([((LBResponseChainResultData *)data).type isEqualToString:@"2"]) {
                NSLog(@"LBLog LBResponseChainBBB process type is %@",((LBResponseChainResultData *)data).type);
                if(throwDataBlock != nil){
                    throwDataBlock(@"LBResponseChainBBB process");
                }
            }else{
                if(throwDataBlock != nil){
                    throwDataBlock(@"LBResponseChainBBB not match");
                }
            }
        }else if(throwDataBlock != nil){
            throwDataBlock(@"LBResponseChainBBB cannot process");
        }
    });
}

@end


@implementation LBResponseChainCCC

- (void)receiveData:(id)data throwDataBlock:(void (^)(id))throwDataBlock{
    NSLog(@"LBLog LBResponseChainCCC receive data");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([data isKindOfClass:[LBResponseChainResultData class]]) {
            if ([((LBResponseChainResultData *)data).type isEqualToString:@"3"]) {
//                捕获到数据  不在抛出  让下面的责任链执行不下去
                NSLog(@"LBLog LBResponseChainCCC process type is %@",((LBResponseChainResultData *)data).type);
                NSLog(@"LBLog LBResponseChainCCC break throw");
//                if(throwDataBlock != nil){
//                    throwDataBlock(@"LBResponseChainCCC process");
//                }
            }else{
                if(throwDataBlock != nil){
                    throwDataBlock(@"LBResponseChainCCC not match");
                }
            }
        }else if(throwDataBlock != nil){
            throwDataBlock(@"LBResponseChainCCC cannot process");
        }
    });
}

@end

@implementation LBResponseChainDDD

- (void)receiveData:(id)data throwDataBlock:(void (^)(id))throwDataBlock{
    NSLog(@"LBLog LBResponseChainDDD receive data");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([data isKindOfClass:[LBResponseChainResultData class]]) {
            if ([((LBResponseChainResultData *)data).type isEqualToString:@"3"]) {
                NSLog(@"LBLog LBResponseChainDDD process type is %@",((LBResponseChainResultData *)data).type);
                NSLog(@"LBLog LBResponseChainDDD break throw");
                if(throwDataBlock != nil){
                    throwDataBlock(@"LBResponseChainDDD process");
                }
            }else{
                if(throwDataBlock != nil){
                    throwDataBlock(@"LBResponseChainDDD not match");
                }
            }
        }else if(throwDataBlock != nil){
            throwDataBlock(@"LBResponseChainDDD cannot process");
        }
    });
}

@end
