//
//  StreamTextProcessor.m
//  LBUIProject
//
//  Created by liu bin on 2025/8/18.
//
#import "StreamTextProcessor.h"

@implementation StreamTextProcessor

- (instancetype)init {
    self = [super init];
    if (self) {
        _buffer = [NSMutableString string];
        _resultArray = [NSMutableArray array];
        _shouldCheckSeparator = NO;
    }
    return self;
}

- (void)processCharacter:(NSString *)character {
    [self.buffer appendString:character];
    
    // 检查是否达到350个字符需要开始查找分隔符 避免分割的太细
    if (!self.shouldCheckSeparator && self.buffer.length >= 350) {
        self.shouldCheckSeparator = YES;
    }
    
    // 如果需要查找分隔符
    if (self.shouldCheckSeparator) {
        // 查找最近的"。\n"或"。"
        NSRange searchRange = NSMakeRange(350, self.buffer.length - 350);
        NSRange separatorRange = [self.buffer rangeOfString:@"###" options:0 range:searchRange];
//        
//        if (separatorRange.location == NSNotFound) {
//            separatorRange = [self.buffer rangeOfString:@"。" options:0 range:searchRange];
//        }
        
        if (separatorRange.location != NSNotFound) {
            // 找到分隔符，进行分割
//            NSRange splitRange = NSMakeRange(0, separatorRange.location + separatorRange.length);
            // 把富文本留给下个字符串。 句号分给上个
            NSRange splitRange = NSMakeRange(0, separatorRange.location);
            NSString *completeSegment = [self.buffer substringWithRange:splitRange];
            
            if (self.resultArray.count > 0) {
                [self.resultArray replaceObjectAtIndex:self.resultArray.count-1 withObject:completeSegment];
            } else {
                [self.resultArray addObject:completeSegment];
            }
            
            // 移除已分割部分
            [self.buffer deleteCharactersInRange:splitRange];
            
            // 添加新的临时元素
            [self.resultArray addObject:[self.buffer copy]];
            
            // 重置检查状态
            self.shouldCheckSeparator = NO;
        }
    }
    
    // 更新最后一个元素
    if (self.resultArray.count > 0) {
        [self.resultArray replaceObjectAtIndex:self.resultArray.count-1 withObject:[self.buffer copy]];
    } else {
        [self.resultArray addObject:[self.buffer copy]];
    }
}

- (NSArray *)getFinalResult {
    // 处理最后剩余内容
    if (self.buffer.length > 0) {
        if (self.resultArray.count > 0) {
            [self.resultArray replaceObjectAtIndex:self.resultArray.count-1 withObject:[self.buffer copy]];
        } else {
            [self.resultArray addObject:[self.buffer copy]];
        }
    }
    
    return [self.resultArray copy];
}
@end
