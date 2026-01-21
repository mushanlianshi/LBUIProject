//
//  LBTextSplitter.h
//  LBUIProject
//
//  Created by liu bin on 2025/8/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBTextSplitter : NSObject

/// 按大约指定长度后的换行符分割文本
/// @param text 要分割的文本
/// @param approximateLength 大约的长度
+ (NSArray<NSString *> *)splitText:(NSString *)text
            afterApproximateLength:(NSUInteger)approximateLength;


@end

NS_ASSUME_NONNULL_END
