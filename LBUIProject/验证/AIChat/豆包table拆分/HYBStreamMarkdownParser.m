//
//  HYBStreamMarkdownParser.m
//  LBUIProject
//
//  Created by liu bin on 2025/12/23.
//

#import "HYBStreamMarkdownParser.h"

// 解析器状态机（内部使用，不对外暴露）
typedef NS_ENUM(NSInteger, HYBParserInternalState) {
    HYBParserInternalStatePlainText,    // 普通文本状态
    HYBParserStatePendingTable,         // 疑似表格状态
    HYBParserInternalStateInTable       // 表格中状态
};

@implementation HYBStreamMarkdownParser {
    HYBParserInternalState _currentState;
    NSString *_unfinishedLine;
    NSArray<NSString *> *_pendingTableHeader;
    HYBStreamTextModel *_currentTextModel;
    HYBStreamTableModel *_currentTableModel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resetParser];
    }
    return self;
}

- (void)resetParser {
    _currentState = HYBParserInternalStatePlainText;
    _unfinishedLine = @"";
    _pendingTableHeader = nil;
    _contentModels = [NSMutableArray array];
    _currentTextModel = nil;
    _currentTableModel = nil;
}

- (void)processStreamDataChunk:(NSString *)dataChunk {
    if (!dataChunk.length) return;
    
    // 1. 拼接未完成行，拆分完整行（保留原始换行，避免空格丢失）
    NSString *fullText = [_unfinishedLine stringByAppendingString:dataChunk];
    _unfinishedLine = @"";
    NSArray<NSString *> *lines = [fullText componentsSeparatedByString:@"\n"];
    NSUInteger lineCount = lines.count;
    
    for (NSUInteger i = 0; i < lineCount; i++) {
        // 保留行内原始空格，仅去除首尾空白（关键：兼容带空格的表格行）
        NSString *line = [lines[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        BOOL isLastLine = (i == lineCount - 1);
        
        if (isLastLine && line.length > 0) {
            _unfinishedLine = line;
            continue;
        }
        
        [self _processSingleLine:line];
    }
    
    // 触发更新回调
    if (self.contentUpdateBlock) {
        self.contentUpdateBlock(self.contentModels.copy);
    }
}

#pragma mark - 核心修复：逐行处理逻辑
- (void)_processSingleLine:(NSString *)line {
    switch (_currentState) {
        case HYBParserInternalStatePlainText:
            [self _handlePlainTextLine:line];
            break;
        case HYBParserStatePendingTable:
            [self _handlePendingTableLine:line];
            break;
        case HYBParserInternalStateInTable:
            [self _handleInTableLine:line];
            break;
    }
}

#pragma mark - 状态1：普通文本行（优化表头识别容错）
- (void)_handlePlainTextLine:(NSString *)line {
    if (!_currentTextModel) {
        _currentTextModel = [[HYBStreamTextModel alloc] init];
        [self.contentModels addObject:_currentTextModel];
    }
    
    if (line.length == 0) {
        [_currentTextModel appendText:@"\n"];
        return;
    }
    
    // 修复1：兼容「行首/行尾缺|」的表头行（只要|数量≥2就算疑似表头）
    if ([self _isPotentialTableLine:line]) {
        _pendingTableHeader = [self _parseTableCellsFromLine:line];
        _currentState = HYBParserStatePendingTable;
        return;
    }
    
    [_currentTextModel appendText:[NSString stringWithFormat:@"%@\n", line]];
}

#pragma mark - 状态2：疑似表格行（优化分隔行识别）
- (void)_handlePendingTableLine:(NSString *)line {
    if (line.length == 0) {
        [_currentTextModel appendText:[NSString stringWithFormat:@"%@\n\n", [_pendingTableHeader componentsJoinedByString:@"|"]]];
        _pendingTableHeader = nil;
        _currentState = HYBParserInternalStatePlainText;
        return;
    }
    
    // 修复2：分隔行识别兼容空格（如 ":---|:---:|---: " 末尾空格）
    if ([self _isSeparatorLine:line headerCount:_pendingTableHeader.count]) {
        NSArray<NSNumber *> *alignments = [self _parseAlignmentsFromSeparatorLine:line];
        _currentTableModel = [[HYBStreamTableModel alloc] initWithHeader:_pendingTableHeader columnAlignments:alignments];
        [self.contentModels addObject:_currentTableModel];
        [_currentTableModel appendRow:[self _generateSeparatorRowWithCount:_pendingTableHeader.count]];
        _currentState = HYBParserInternalStateInTable;
        _pendingTableHeader = nil;
        _currentTextModel = nil;
        return;
    }
    
    [_currentTextModel appendText:[NSString stringWithFormat:@"%@\n%@\n", [_pendingTableHeader componentsJoinedByString:@"|"], line]];
    _pendingTableHeader = nil;
    _currentState = HYBParserInternalStatePlainText;
}

#pragma mark - 状态3：表格中行（优化内容行解析容错）
- (void)_handleInTableLine:(NSString *)line {
    // 修复3：表格结束条件优化（空行或连续2行非表格行才结束）
    BOOL isTableLine = [self _isPotentialTableLine:line] &&
                       [self _parseTableCellsFromLine:line].count >= _currentTableModel.header.count - 1;
    
    if (line.length == 0 || !isTableLine) {
        [_currentTableModel markAsCompleted];
        _currentState = HYBParserInternalStatePlainText;
        _currentTableModel = nil;
        
        if (line.length > 0) {
            _currentTextModel = [[HYBStreamTextModel alloc] init];
            [self.contentModels addObject:_currentTextModel];
            [_currentTextModel appendText:[NSString stringWithFormat:@"%@\n", line]];
        } else if (_currentTextModel) {
            [_currentTextModel appendText:@"\n"];
        }
        return;
    }
    
    // 修复4：解析内容行时兼容空格和缺|的情况
    NSArray<NSString *> *cellData = [self _parseTableCellsFromLine:line];
    [_currentTableModel appendRow:cellData];
}

#pragma mark - 核心修复：工具方法优化
/**
 修复：判断是否为潜在表格行（只要|数量≥2，不管首尾是否有|）
 */
- (BOOL)_isPotentialTableLine:(NSString *)line {
    NSInteger pipeCount = [line componentsSeparatedByString:@"|"].count - 1;
    return pipeCount >= 2;
}

/**
 修复：分隔行识别兼容空格和多余字符
 */
- (BOOL)_isSeparatorLine:(NSString *)line headerCount:(NSInteger)headerCount {
    // 过滤 |、-、:、空格 后，若为空则是分隔行
    NSString *filteredLine = [line stringByReplacingOccurrencesOfString:@"|" withString:@""];
    filteredLine = [filteredLine stringByReplacingOccurrencesOfString:@"-" withString:@""];
    filteredLine = [filteredLine stringByReplacingOccurrencesOfString:@":" withString:@""];
    filteredLine = [filteredLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (filteredLine.length > 0) return NO;
    
    // |数量兼容：表头列数n → 分隔行|数量可以是n或n+1（兼容缺|的情况）
    NSInteger pipeCount = [line componentsSeparatedByString:@"|"].count - 1;
    return (pipeCount == headerCount) || (pipeCount == headerCount + 1);
}

/**
 修复：解析单元格时过滤多余空格，兼容首尾缺|
 */
- (NSArray<NSString *> *)_parseTableCellsFromLine:(NSString *)line {
    NSMutableArray *cells = [NSMutableArray array];
    NSArray<NSString *> *parts = [line componentsSeparatedByString:@"|"];
    
    for (NSString *part in parts) {
        // 去除单元格内的多余空格（关键：如 " iPad Pro " → "iPad Pro"）
        NSString *cell = [part stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (cell.length > 0 || cells.count > 0) { // 允许空单元格（避免表头列数不匹配）
            [cells addObject:cell];
        }
    }
    
    // 若最后一个元素是空字符串（因行尾有|），移除
    if (cells.count > 0 && [[cells lastObject] isEqualToString:@""]) {
        [cells removeLastObject];
    }
    
    return cells.copy;
}

/**
 修复：对齐规则提取兼容空格
 */
- (NSArray<NSNumber *> *)_parseAlignmentsFromSeparatorLine:(NSString *)line {
    NSMutableArray *alignments = [NSMutableArray array];
    NSArray<NSString *> *parts = [line componentsSeparatedByString:@"|"];
    
    // 遍历有效部分（跳过首尾空元素）
    for (NSUInteger i = 0; i < parts.count; i++) {
        NSString *part = [parts[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (part.length == 0) continue;
        
        BOOL hasLeftColon = [part hasPrefix:@":"];
        BOOL hasRightColon = [part hasSuffix:@":"];
        
        if (hasLeftColon && hasRightColon) {
            [alignments addObject:@(HYBStreamTableColumnAlignmentCenter)];
        } else if (hasRightColon) {
            [alignments addObject:@(HYBStreamTableColumnAlignmentRight)];
        } else {
            [alignments addObject:@(HYBStreamTableColumnAlignmentLeft)];
        }
    }
    
    // 对齐规则数量与表头不一致时，补默认左对齐
    while (alignments.count < _pendingTableHeader.count) {
        [alignments addObject:@(HYBStreamTableColumnAlignmentLeft)];
    }
    
    return alignments.copy;
}

- (NSArray<NSString *> *)_generateSeparatorRowWithCount:(NSInteger)count {
    NSMutableArray *separatorCells = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        [separatorCells addObject:@"-"];
    }
    return separatorCells.copy;
}

@end
