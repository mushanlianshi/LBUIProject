//
//  LBChainElement.m
//  LBUIProject
//
//  Created by liu bin on 2021/8/27.
//

#import "LBChainElement.h"

@interface LBChainElement ()

//记录下一个要执行的element的
@property (nonatomic, strong) LBChainElement *nextElement;

@property (nonatomic, copy) void(^executeBlock)(LBChainElement *element);

@property (nonatomic, copy) dispatch_block_t dispose;

@property (nonatomic, copy) void(^catchError)(NSError *error);

@property (nonatomic, copy) dispatch_block_t subscribe;

@end

@implementation LBChainElement

- (instancetype)initWithIdentifier:(NSString *)identifier executeTask:(void (^)(LBChainElement *))executeTask{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.executeBlock = executeTask;
    }
    return self;
}

- (Then)then{
    return ^(LBChainElement *element){
        self.nextElement = element;
        return element;
    };
}

//任务执行完 调用的block
- (instancetype)dispose:(dispatch_block_t)dispose{
    self.dispose = dispose;
    return self;
}
//捕获到error的处理
- (instancetype)catchError:(void(^)(NSError *error))catchError{
    self.catchError = catchError;
    return self;
}
//正确执行完后调用的
- (instancetype)subscribe:(dispatch_block_t)subscribe{
    self.subscribe = subscribe;
    return self;
}

//开始执行任务
- (void)start{
    if (self.executeBlock) {
        self.executeBlock(self);
    }
}

//任务执行完了  发送next执行下一个的
- (void)next{
    if (self.subscribe) {
        self.subscribe();
    }
    if (self.dispose) {
        self.dispose();
    }
    if (self.nextElement) {
        [self.nextElement start];
    }
}

- (void)throwError:(NSError *)error{
    if (self.catchError) {
        self.catchError(error);
    }
}

- (void)dealloc
{
    NSString *dealloc = [NSString stringWithFormat:@"LBLog %@ dealloc ==",self.identifier ?: NSStringFromClass([self class])];
    NSLog(@"%@", dealloc);
}

@end
