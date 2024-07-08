//
//  LBChainElement.h
//  LBUIProject
//
//  Created by liu bin on 2021/8/27.
//

#import <Foundation/Foundation.h>



@class LBChainElement;

//定义一个block根据传入的element返回一个element  链式调用用的
typedef LBChainElement* (^Then)(LBChainElement *element);

@interface LBChainElement : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier executeTask:(void(^)(LBChainElement *promise))executeTask;

//用来记录数据用的
@property (nonatomic, strong) id data;

@property (nonatomic, copy) NSString *identifier;

//链式调用用的  根据传入的element 记录后  在返回elment  等任务执行完之后调用用的
@property (nonatomic, copy, readonly) Then then;

//任务执行完 调用的block
- (instancetype)dispose:(dispatch_block_t)dispose;
//捕获到error的处理
- (instancetype)catchError:(void(^)(NSError *error))catchError;
//正确执行完后调用的
- (instancetype)subscribe:(dispatch_block_t)subscribe;

//开始执行任务
- (void)start;

//任务执行完了  发送next执行下一个的
- (void)next;
//抛出一个异常用的
- (void)throwError:(NSError *)error;

@end


