//
//  HXRealTimeStreamParser.m
//  LBUIProject
//
//  Created by liu bin on 2025/12/4.
//

#import "HXRealTimeStreamParser.h"

// HXRealTimeStreamParser.m
#import "HXRealTimeStreamParser.h"

@interface HXRealTimeStreamParser() {
    NSMutableArray<HXRealTimeContentElement *> *_allElements;
    HXRealTimeContentElement *_currentElement;
    
    // 当前行缓冲区
    NSMutableString *_currentLine;
    
    // 表格状态
    BOOL _isInTable;
    NSInteger _tableLineCount;
    BOOL _tableHasSeparator;
}

@end

@implementation HXRealTimeStreamParser

- (instancetype)init {
    self = [super init];
    if (self) {
        _allElements = [NSMutableArray array];
        _currentLine = [NSMutableString string];
        _isInTable = NO;
        _tableLineCount = 0;
        _tableHasSeparator = NO;
    }
    return self;
}

#pragma mark - 公开接口

- (void)appendCharacter:(unichar)character {
    // 添加到当前行
    [_currentLine appendFormat:@"%C", character];
    
    // 如果当前没有元素，创建文本元素
    if (!_currentElement) {
        _currentElement = [HXRealTimeContentElement textElement];
        [_allElements addObject:_currentElement];
        
        // 通知代理
        if ([self.delegate respondsToSelector:@selector(parser:didCreateElement:)]) {
            [self.delegate parser:self didCreateElement:_currentElement];
        }
    }
    
    // 更新当前元素
    [_currentElement appendCharacter:character];
    
    // 通知更新
    if ([self.delegate respondsToSelector:@selector(parser:didUpdateElement:)]) {
        [self.delegate parser:self didUpdateElement:_currentElement];
    }
    
    // 处理换行符
    if (character == '\n') {
        [self processLineCompletion];
    }
}

- (void)appendString:(NSString *)string {
    for (NSInteger i = 0; i < string.length; i++) {
        unichar character = [string characterAtIndex:i];
        [self appendCharacter:character];
    }
}

- (void)processLineCompletion {
    NSString *line = [_currentLine copy];
    [_currentLine setString:@""];
    
    // 移除换行符
    line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 检测表格开始
    if (!_isInTable && [self shouldStartTable:line]) {
        [self startNewTableWithLine:line];
        return;
    }
    
    // 表格行处理
    if (_isInTable) {
        [self processTableLine:line];
        return;
    }
    
//    // 文本段落结束检测（空行）
//    if (line.length == 0 && _currentElement.type == HXContentTypeText) {
//        NSString *content = _currentElement.content;
//        if ([content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
//            [self completeCurrentElement];
//        }
//    }
}

#pragma mark - 表格检测

- (BOOL)shouldStartTable:(NSString *)line {
    // 简化表格检测：包含 | 字符，且看起来不像分隔线
    if (![line containsString:@"|"]) return NO;
    
    // 检查是否有足够的 | 字符
    NSArray *parts = [line componentsSeparatedByString:@"|"];
    NSInteger validParts = 0;
    for (NSString *part in parts) {
        if ([[part stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
            validParts++;
        }
    }
    
    // 至少有2个有效列
    if (validParts < 2) return NO;
    
    // 不是分隔线
    if ([self isTableSeparatorLine:line]) return NO;
    
    return YES;
}

- (BOOL)isTableSeparatorLine:(NSString *)line {
    NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 检查是否主要是 - 和 |
    NSInteger dashCount = 0;
    NSInteger pipeCount = 0;
    
    for (NSInteger i = 0; i < trimmed.length; i++) {
        unichar c = [trimmed characterAtIndex:i];
        if (c == '-') dashCount++;
        if (c == '|') pipeCount++;
    }
    
    // 分隔行有很多 - 和少量 |
    return (dashCount > 3 && pipeCount >= 2);
}

- (void)startNewTableWithLine:(NSString *)line {
    // 完成当前元素（如果是文本）
    if (_currentElement && _currentElement.type == HXContentTypeText) {
        [_currentElement deleteContent:line];
        [self completeCurrentElement];
    }
    
    // 创建表格元素
    _currentElement = [HXRealTimeContentElement tableElement];
    [_allElements addObject:_currentElement];
    _isInTable = YES;
    _tableLineCount = 1;
    _tableHasSeparator = NO;
    
    // 添加第一行
    [_currentElement appendContent:[line stringByAppendingString:@"\n"]];
    
    // 通知
    if ([self.delegate respondsToSelector:@selector(parser:didCreateElement:)]) {
        [self.delegate parser:self didCreateElement:_currentElement];
    }
}

- (void)processTableLine:(NSString *)line {
    NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 检查是否还是表格行
    if ([self isTableRow:trimmed]) {
        
    } else {
        // 表格结束 把上面最后一行替换掉，创建一个新的
        [self finalizeTable:line];
    }
}

- (void)finalizeTable:(NSString *)line{
    // 完成当前元素（如果是文本）
    if (_currentElement && _currentElement.type == HXContentTypeTable) {
        [_currentElement deleteContent:line];
        [self completeCurrentElement];
    }
    
    // 创建表格元素
    _currentElement = [HXRealTimeContentElement textElement];
    [_allElements addObject:_currentElement];
    _isInTable = false;
    _tableLineCount = 0;
    _tableHasSeparator = NO;
    // 通知
    if ([self.delegate respondsToSelector:@selector(parser:didCreateElement:)]) {
        [self.delegate parser:self didCreateElement:_currentElement];
    }
}

- (BOOL)isTableRow:(NSString *)line {
    // 简单的检查：包含 | 字符
    if (![line containsString:@"|"]) {
        return NO;
    }
    
    // 检查 | 的数量
    NSArray *components = [line componentsSeparatedByString:@"|"];
    if (components.count < 2) {
        return NO;
    }
    
    return YES;
}

- (BOOL)shouldEndTable:(NSString *)line {
    // 空行且表格至少有3行（表头+分隔+数据）
    if (line.length == 0 && _tableLineCount >= 3) {
        return YES;
    }
    
    // 非表格行且已经有分隔行
    if (![line containsString:@"|"] && line.length > 0 && _tableHasSeparator) {
        return YES;
    }
    
    // 新的表格开始（如果已经有完整表格）
    if ([self shouldStartTable:line] && _tableLineCount >= 3) {
        return YES;
    }
    
    return NO;
}

#pragma mark - 元素管理

- (void)completeCurrentElement {
    if (!_currentElement) return;
    
    // 通知完成
    if ([self.delegate respondsToSelector:@selector(parser:didCompleteElement:)]) {
        [self.delegate parser:self didCompleteElement:_currentElement];
    }
    
    // 重置当前元素（但元素仍然在 allElements 中）
    _currentElement = nil;
}

- (void)finalize {
    // 完成最后一个元素
    if (_currentElement) {
        [self completeCurrentElement];
    }
    
    _isInTable = NO;
    _tableLineCount = 0;
    _tableHasSeparator = NO;
}

#pragma mark - 只读属性

- (NSArray<HXRealTimeContentElement *> *)allElements {
    return [_allElements copy];
}

- (HXRealTimeContentElement *)currentElement {
    return _currentElement;
}

@end
