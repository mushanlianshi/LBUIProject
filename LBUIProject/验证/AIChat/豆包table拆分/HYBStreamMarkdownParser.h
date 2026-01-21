//
//  HYBStreamMarkdownParser.h
//  LBUIProject
//
//  Created by liu bin on 2025/12/23.
//

#import <Foundation/Foundation.h>
#import "HYBStreamContentModel.h"

// 数组更新回调（外部监听模型数组变化）
typedef void(^HYBStreamContentUpdateBlock)(NSArray<HYBStreamContentModel *> *updatedModels);

@interface HYBStreamMarkdownParser : NSObject

/// 实时结构化内容数组（外部可直接访问，元素为 HYBStreamTextModel/HYBStreamTableModel）
@property (nonatomic, strong, readonly) NSMutableArray<HYBStreamContentModel *> *contentModels;

/// 数组更新回调（可选：数组变化时触发，比主动访问更高效）
@property (nonatomic, copy) HYBStreamContentUpdateBlock contentUpdateBlock;

/// 重置解析状态（新对话/新流式请求时调用）
- (void)resetParser;

/**
 处理流式数据块（核心方法）
 @param dataChunk 流式数据块（如网络逐块接收的字符串）
 */
- (void)processStreamDataChunk:(NSString *)dataChunk;

@end
