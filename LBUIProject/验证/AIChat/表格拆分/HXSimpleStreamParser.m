//
//  HXSimpleStreamParser.m
//  LBUIProject
//
//  Created by liu bin on 2025/12/4.
//

// HXSimpleStreamParser.m
#import "HXSimpleStreamParser.h"

@interface HXSimpleStreamParser() {
    NSMutableArray<HXContentElement *> *_parsedElements;
    NSMutableString *_currentBuffer;
    
    // 状态
    BOOL _isInTable;
    BOOL _tableStarted;
    NSMutableArray<NSString *> *_tableLines;
    
    // 行缓冲区
    NSMutableString *_currentLine;
    
    // 表格检测辅助
    BOOL _tableHasHeader;
    BOOL _tableHasSeparator;
    BOOL _tableHasData;
}

@end

@implementation HXSimpleStreamParser

- (instancetype)init {
    self = [super init];
    if (self) {
        _parsedElements = [NSMutableArray array];
        _currentBuffer = [NSMutableString string];
        _currentLine = [NSMutableString string];
        _tableLines = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 公开接口

- (void)appendCharacter:(unichar)character {
    NSString *charStr = [NSString stringWithCharacters:&character length:1];
    
    // 添加到当前行
    [_currentLine appendString:charStr];
    
    if (character == '\n') {
        // 处理完整的一行
        [self processLine:[_currentLine copy]];
        [_currentLine setString:@""];
    }
}

- (void)finalize {
    // 处理最后一行（如果没有换行符）
    if (_currentLine.length > 0) {
        [self processLine:[_currentLine copy]];
    }
    
    // 处理缓冲区中的剩余内容
    [self flushCurrentBuffer];
}

- (void)reset {
    [_parsedElements removeAllObjects];
    [_currentBuffer setString:@""];
    [_currentLine setString:@""];
    [_tableLines removeAllObjects];
    _isInTable = NO;
    _tableStarted = NO;
    _tableHasHeader = NO;
    _tableHasSeparator = NO;
    _tableHasData = NO;
}

#pragma mark - 行处理

- (void)processLine:(NSString *)line {
    // 如果是表格状态，处理表格行
    if (_isInTable) {
        [self processTableLine:line];
        return;
    }
    
    // 检查是否开始表格
    if ([self shouldStartTable:line]) {
        // 先刷新缓冲区中的文本
        [self flushCurrentBuffer];
        _tableHasHeader = true;
        // 开始表格
        _isInTable = YES;
        _tableStarted = YES;
        [_tableLines addObject:line];
        return;
    }
    
    // 普通文本行
    [_currentBuffer appendString:line];
}

- (void)processTableLine:(NSString *)line {
    NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 检查是否还是表格行
    if ([self isTableRow:trimmed]) {
        [_tableLines addObject:line];
        
        // 更新表格状态
        if (_tableLines.count == 1) {
            _tableHasHeader = YES;
        } else if ([self isTableSeparatorLine:trimmed]) {
            _tableHasSeparator = YES;
        } else if (_tableHasSeparator) {
            _tableHasData = YES;
        }
    } else {
        // 表格结束
        [self finalizeTable];
        
        // 将当前行作为普通文本处理
        [_currentBuffer appendString:line];
    }
}

#pragma mark - 表格检测

- (BOOL)shouldStartTable:(NSString *)line {
    // 已经开始了就不检查
    if (_isInTable) return NO;
    
    NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 检查是否是 markdown 表格行
    return [self isTableRow:trimmed] && ![self isTableSeparatorLine:trimmed];
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

- (BOOL)isTableSeparatorLine:(NSString *)line {
    NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // 必须是 | 开头和结尾
    if (![trimmed hasPrefix:@"|"] || ![trimmed hasSuffix:@"|"]) {
        return NO;
    }
    
    // 检查内部是否主要是 - 和 :
    NSString *inner = [trimmed substringWithRange:NSMakeRange(1, trimmed.length - 2)];
    
    // 移除空格
    NSString *noSpaces = [inner stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (noSpaces.length == 0) {
        return NO;
    }
    
    // 检查是否只包含 : 和 -
    NSCharacterSet *allowedChars = [NSCharacterSet characterSetWithCharactersInString:@"-|"];
    NSCharacterSet *disallowedChars = [allowedChars invertedSet];
    
    if ([noSpaces rangeOfCharacterFromSet:disallowedChars].location != NSNotFound) {
        return NO;
    }
    
    // 必须包含至少一个 -
    return [noSpaces containsString:@"-"];
}

#pragma mark - 完成处理

- (void)flushCurrentBuffer {
    if (_currentBuffer.length == 0) return;
    
    NSString *content = [_currentBuffer copy];
    content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (content.length > 0) {
        HXContentElement *element = [HXContentElement textElementWithContent:content];
        [_parsedElements addObject:element];
    }
    
    [_currentBuffer setString:@""];
}

- (void)finalizeTable {
    if (_tableLines.count == 0) return;
    
    // 检查是否是一个有效的表格
    // 需要：表头 + 分隔符 + 至少一行数据
    BOOL isValidTable = (_tableHasHeader && _tableHasSeparator && _tableHasData) ||
                       (_tableHasHeader && _tableLines.count >= 2); // 简单表格
    
    if (isValidTable) {
        // 合并所有表格行
        NSMutableString *tableContent = [NSMutableString string];
        for (NSString *line in _tableLines) {
            [tableContent appendString:line];
        }
        
        HXContentElement *element = [HXContentElement tableElementWithContent:[tableContent copy]];
        [_parsedElements addObject:element];
    } else {
        // 不是有效的表格，作为文本处理
        NSMutableString *textContent = [NSMutableString string];
        for (NSString *line in _tableLines) {
            [textContent appendString:line];
        }
        [_currentBuffer appendString:textContent];
        [self flushCurrentBuffer];
    }
    
    // 重置表格状态
    [_tableLines removeAllObjects];
    _isInTable = NO;
    _tableStarted = NO;
    _tableHasHeader = NO;
    _tableHasSeparator = NO;
    _tableHasData = NO;
}

#pragma mark - 只读属性

- (NSMutableArray<HXContentElement *> *)parsedElements {
    return _parsedElements;
}

@end
