//
//  HXStreamContentParser.m
//  LBUIProject
//
//  Created by liu bin on 2025/12/4.
//

#import "HXStreamContentParser.h"

// HXStreamContentParser.m
#import "HXStreamContentParser.h"

@interface HXStreamContentParser() {
    NSMutableArray<HXContentElement *> *_parsedElements;
    NSMutableString *_currentTextBuffer;
    NSMutableString *_currentTableBuffer;
    NSMutableString *_currentListBuffer;
    
    // 状态管理
    BOOL _isInTable;
    BOOL _isInList;
    BOOL _isInSection;
    BOOL _tableStarted;
    
    // 表格检测辅助
    NSInteger _tableLineCount;
    BOOL _tableHasSeparator;
    
    // 缓冲区管理
    NSMutableArray<NSString *> *_lineBuffer;
}

@end

@implementation HXStreamContentParser

- (instancetype)init {
    self = [super init];
    if (self) {
        _parsedElements = [NSMutableArray array];
        _currentTextBuffer = [NSMutableString string];
        _currentTableBuffer = [NSMutableString string];
        _currentListBuffer = [NSMutableString string];
        _lineBuffer = [NSMutableArray array];
        _tableLineCount = 0;
        _tableHasSeparator = NO;
    }
    return self;
}

#pragma mark - 公开接口

- (void)appendCharacter:(unichar)character {
    // 将字符添加到当前行缓冲区
    NSString *charStr = [NSString stringWithCharacters:&character length:1];
    
    // 更新行缓冲区
    if (character == '\n' || character == '\r') {
        // 处理换行，检查行内容
        [self processCurrentLine];
        [_lineBuffer removeAllObjects];
    } else {
        [_lineBuffer addObject:charStr];
    }
    
    // 根据当前状态将字符添加到相应缓冲区
    if (_isInTable) {
        [self processCharacterForTable:character];
    } else if (_isInList) {
        [self processCharacterForList:character];
    } else {
        [self processCharacterForText:character];
    }
}

- (void)appendString:(NSString *)string {
    for (NSInteger i = 0; i < string.length; i++) {
        unichar character = [string characterAtIndex:i];
        [self appendCharacter:character];
    }
}

- (void)finalize {
    // 处理最后一行
    if (_lineBuffer.count > 0) {
        [self processCurrentLine];
    }
    
    // 处理剩余的缓冲区内容
    if (_isInTable && _currentTableBuffer.length > 0) {
        [self finalizeCurrentTable];
    } else if (_isInList && _currentListBuffer.length > 0) {
        [self finalizeCurrentList];
    } else if (_currentTextBuffer.length > 0) {
        [self finalizeCurrentText];
    }
    
    [self resetState];
}

- (void)reset {
    [_parsedElements removeAllObjects];
    [_currentTextBuffer setString:@""];
    [_currentTableBuffer setString:@""];
    [_currentListBuffer setString:@""];
    [_lineBuffer removeAllObjects];
    [self resetState];
}

#pragma mark - 状态管理

- (void)resetState {
    _isInTable = NO;
    _isInList = NO;
    _isInSection = NO;
    _tableStarted = NO;
    _tableLineCount = 0;
    _tableHasSeparator = NO;
}

#pragma mark - 行处理

- (void)processCurrentLine {
    if (_lineBuffer.count == 0) return;
    
    NSString *line = [_lineBuffer componentsJoinedByString:@""];
    
    // 检测表格开始
    if (!_isInTable && !_isInList) {
        if ([self isTableStartLine:line]) {
            // 先完成当前文本
            [self finalizeCurrentText];
            
            // 开始表格
            _isInTable = YES;
            _tableStarted = YES;
            _tableLineCount = 1;
            _tableHasSeparator = NO;
            [_currentTableBuffer appendString:line];
            [_currentTableBuffer appendString:@"\n"];
            return;
        }
        
        // 检测列表开始
        if ([self isListStartLine:line]) {
            [self finalizeCurrentText];
            _isInList = YES;
            [_currentListBuffer appendString:line];
            [_currentListBuffer appendString:@"\n"];
            return;
        }
    }
    
    // 处理表格行
    if (_isInTable) {
        [self processTableLine:line];
        return;
    }
    
    // 处理列表行
    if (_isInList) {
        [self processListLine:line];
        return;
    }
    
    // 普通文本行
    [_currentTextBuffer appendString:line];
    [_currentTextBuffer appendString:@"\n"];
}

#pragma mark - 表格处理

// 修改表格检测方法
- (BOOL)isTableStartLine:(NSString *)line {
    NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 必须是 | 开头和结尾（标准的markdown表格）
    if (![trimmed hasPrefix:@"|"] || ![trimmed hasSuffix:@"|"]) {
        return NO;
    }
    
    // 检查是否有足够的 | 分隔符（至少3个：开头、中间、结尾）
    NSArray *components = [trimmed componentsSeparatedByString:@"|"];
    if (components.count < 3) {
        return NO;
    }
    
    // 表格应该包含文本内容，不是纯分隔符
    // 检查是否包含字母或数字，避免把分隔行误判为表头
    NSCharacterSet *alphanumericSet = [NSCharacterSet alphanumericCharacterSet];
    if ([trimmed rangeOfCharacterFromSet:alphanumericSet].location == NSNotFound) {
        return NO;
    }
    
    // 不是分隔线（不包含连续的 ---）
    if ([trimmed containsString:@"---"] || [trimmed containsString:@"==="]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isTableSeparatorLine:(NSString *)line {
    NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 必须是 | 开头和结尾
    if (![trimmed hasPrefix:@"|"] || ![trimmed hasSuffix:@"|"]) {
        return NO;
    }
    
    // 移除首尾的 |
    NSString *inner = [trimmed substringWithRange:NSMakeRange(1, trimmed.length - 2)];
    
    // 检查内部是否只包含 :、- 和空格
    NSCharacterSet *allowedChars = [NSCharacterSet characterSetWithCharactersInString:@":- "];
    NSCharacterSet *disallowedChars = [allowedChars invertedSet];
    
    if ([inner rangeOfCharacterFromSet:disallowedChars].location != NSNotFound) {
        return NO;
    }
    
    // 必须包含至少一个 -
    if (![inner containsString:@"-"]) {
        return NO;
    }
    
    // 标准格式：|---| 或 |:---:| 等
    // 检查格式是否符合表格分隔符
    NSArray *cells = [inner componentsSeparatedByString:@"|"];
    for (NSString *cell in cells) {
        NSString *cellTrimmed = [cell stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (cellTrimmed.length == 0) continue;
        
        // 有效的分隔符单元格应该只包含 - 或 :- 或 -: 或 :-:
        BOOL valid = NO;
        if ([cellTrimmed hasPrefix:@"-"] && [cellTrimmed hasSuffix:@"-"]) {
            // 纯 ---
            valid = YES;
        } else if ([cellTrimmed hasPrefix:@":-"] && [cellTrimmed hasSuffix:@"-"]) {
            // :---
            valid = YES;
        } else if ([cellTrimmed hasPrefix:@"-"] && [cellTrimmed hasSuffix:@":"]) {
            // ---:
            valid = YES;
        } else if ([cellTrimmed hasPrefix:@":-"] && [cellTrimmed hasSuffix:@":"]) {
            // :---:
            valid = YES;
        }
        
        if (!valid) {
            return NO;
        }
    }
    
    return YES;
}

- (void)processTableLine:(NSString *)line {
    [_currentTableBuffer appendString:line];
    [_currentTableBuffer appendString:@"\n"];
    _tableLineCount++;
    
    // 检查是否是表格分隔行
    if ([self isTableSeparatorLine:line]) {
        _tableHasSeparator = YES;
    }
    
    // 检查表格是否结束
    if ([self shouldEndTable:line]) {
        [self finalizeCurrentTable];
    }
}

- (BOOL)shouldEndTable:(NSString *)line {
    NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 空行且表格至少有表头、分隔行和一行数据
    if (trimmed.length == 0 && _tableHasSeparator && _tableLineCount >= 3) {
        return YES;
    }
    
    // 新的章节标题开始
    if ([trimmed hasPrefix:@"###"]) {
        return YES;
    }
    
    // 新的表格开始（检测到新的表头）
    if ([self isTableStartLine:line] && _tableLineCount > 1) {
        return YES;
    }
    
    // 检测到列表开始
    if ([self isListStartLine:line] && _tableHasSeparator) {
        return YES;
    }
    
    // 非表格行结束表格（如果已经有完整的表格结构）
    if (![trimmed containsString:@"|"] && trimmed.length > 0 && _tableHasSeparator && _tableLineCount >= 3) {
        return YES;
    }
    
    return NO;
}

- (void)finalizeCurrentTable {
    if (_currentTableBuffer.length == 0) return;
    
    NSString *tableContent = [_currentTableBuffer copy];
    HXContentElement *element = [HXContentElement tableElementWithContent:tableContent];
    [_parsedElements addObject:element];
    
    // 重置表格状态
    [_currentTableBuffer setString:@""];
    _isInTable = NO;
    _tableStarted = NO;
}

#pragma mark - 列表处理

- (BOOL)isListStartLine:(NSString *)line {
    NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 检测无序列表
    if ([trimmed hasPrefix:@"- "] || [trimmed hasPrefix:@"* "] || [trimmed hasPrefix:@"+ "]) {
        return YES;
    }
    
    // 检测有序列表
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d+\\.\\s+"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) return NO;
    
    NSRange range = [regex rangeOfFirstMatchInString:trimmed options:0 range:NSMakeRange(0, trimmed.length)];
    return range.location != NSNotFound;
}

- (void)processListLine:(NSString *)line {
    NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 检查是否还是列表项
    if ([self isListStartLine:trimmed]) {
        [_currentListBuffer appendString:line];
        [_currentListBuffer appendString:@"\n"];
    } else {
        // 列表结束
        [self finalizeCurrentList];
        
        // 将当前行作为普通文本处理
        [_currentTextBuffer appendString:line];
        [_currentTextBuffer appendString:@"\n"];
    }
}

- (void)finalizeCurrentList {
    if (_currentListBuffer.length == 0) return;
    
    NSString *listContent = [_currentListBuffer copy];
    HXContentElement *element = [HXContentElement listElementWithContent:listContent];
    [_parsedElements addObject:element];
    
    [_currentListBuffer setString:@""];
    _isInList = NO;
}

#pragma mark - 文本处理

- (void)processCharacterForText:(unichar)character {
    [_currentTextBuffer appendFormat:@"%C", character];
}

- (void)processCharacterForTable:(unichar)character {
    [_currentTableBuffer appendFormat:@"%C", character];
}

- (void)processCharacterForList:(unichar)character {
    [_currentListBuffer appendFormat:@"%C", character];
}

- (void)finalizeCurrentText {
    if (_currentTextBuffer.length == 0) return;
    
    NSString *textContent = [_currentTextBuffer copy];
    textContent = [textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (textContent.length > 0) {
        HXContentElement *element = [HXContentElement textElementWithContent:textContent];
        [_parsedElements addObject:element];
    }
    
    [_currentTextBuffer setString:@""];
}

#pragma mark - 只读属性访问

- (NSMutableArray<HXContentElement *> *)parsedElements {
    return _parsedElements;
}

- (NSString *)currentTextBuffer {
    return [_currentTextBuffer copy];
}

- (BOOL)isInTable {
    return _isInTable;
}

- (BOOL)isInList {
    return _isInList;
}

@end
