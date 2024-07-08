//
//  NSObject+LBResponseChain.h
//  LBUIProject
//
//  Created by liu bin on 2022/7/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LBResponseChain)

@property (nonatomic, strong) id lb_nextChain;

@end

NS_ASSUME_NONNULL_END
