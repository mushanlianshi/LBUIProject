//
//  LBTextSplitter.m
//  LBUIProject
//
//  Created by liu bin on 2025/8/6.
//

#import "LBTextSplitter.h"

@implementation LBTextSplitter

+ (NSArray<NSString *> *)splitText:(NSString *)text
          afterApproximateLength:(NSUInteger)approximateLength {
    
    if (!text || text.length == 0) {
        return @[];
    }
    
    NSMutableArray<NSString *> *result = [NSMutableArray array];
    NSUInteger currentPosition = 0;
    NSUInteger totalLength = text.length;
    
    while (currentPosition < totalLength) {
        // 计算起始查找位置（当前位置 + 大约长度）
        NSUInteger searchStart = currentPosition + approximateLength;
        
        // 确保查找位置不超过文本长度
        if (searchStart >= totalLength) {
            // 剩余内容作为最后一段
            NSString *lastSegment = [text substringFromIndex:currentPosition];
            [result addObject:lastSegment];
            break;
        }
        
        // 从查找起始位置开始向后寻找换行符
        NSUInteger nextNewline = NSNotFound;
        for (NSUInteger i = searchStart; i < totalLength; i++) {
            unichar c = [text characterAtIndex:i];
            if (c == '\n' || c == '\r') { // 同时处理\n和\r换行符
                nextNewline = i;
                break;
            }
        }
        
        NSUInteger endPosition;
        if (nextNewline != NSNotFound) {
            // 找到换行符，分割到换行符之后（跳过换行符）
            endPosition = nextNewline + 1;
        } else {
            // 没找到换行符，直接取到文本末尾
            endPosition = totalLength;
        }
        
        // 截取当前段
        NSString *segment = [text substringWithRange:NSMakeRange(currentPosition, endPosition - currentPosition)];
        [result addObject:segment];
        
        // 更新当前位置
        currentPosition = endPosition;
    }
    
    return result;
}

@end
