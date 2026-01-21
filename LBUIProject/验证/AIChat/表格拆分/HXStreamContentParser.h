//
//  HXStreamContentParser.h
//  LBUIProject
//
//  Created by liu bin on 2025/12/4.
//

#import <Foundation/Foundation.h>

// HXStreamContentParser.h
#import <Foundation/Foundation.h>
#import "HXContentElement.h"

@interface HXStreamContentParser : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<HXContentElement *> *parsedElements;
@property (nonatomic, copy, readonly) NSString *currentTextBuffer;
@property (nonatomic, assign, readonly) BOOL isInTable;
@property (nonatomic, assign, readonly) BOOL isInList;

// 逐字添加
- (void)appendCharacter:(unichar)character;
// 添加字符串块
- (void)appendString:(NSString *)string;
// 完成解析，处理剩余缓冲区
- (void)finalize;
// 重置解析器
- (void)reset;

@end
