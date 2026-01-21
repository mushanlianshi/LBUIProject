#import "HYBStreamMarkdownController.h"
#import "HYBStreamMarkdownParser.h"

@interface HYBStreamMarkdownController ()
@property (nonatomic, strong) HYBStreamMarkdownParser *parser;
@end

@implementation HYBStreamMarkdownController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 1. 初始化解析器
    self.parser = [[HYBStreamMarkdownParser alloc] init];
    
    // 2. 设置数组更新回调（实时监听变化，可选）
    __weak typeof(self) weakSelf = self;
    self.parser.contentUpdateBlock = ^(NSArray<HYBStreamContentModel *> *updatedModels) {
        [weakSelf _printUpdatedContentModels:updatedModels];
    };
    
    // 3. 模拟流式数据块（含：普通文本→表格→普通文本）
    [self _simulateStreamDataChunks];
}

/**
 模拟流式数据块（真实场景从网络逐块接收）
 */
- (void)_simulateStreamDataChunks {
    NSArray<NSString *> *streamChunks = @[
        // 块1：前面的普通文本
        @"这是前面的流式内容，接下来展示表格：\n\n",
        // 块2：表格表头
        @"| 产品 | 价格 | 库存 |\n",
        // 块3：表格分隔行（带对齐）
        @"| :--- | :---: | ---: |\n",
        // 块4：表格内容行1（部分）
        @"| iPhone 15 | 5999 | 12",
        // 块5：表格内容行1补全 + 内容行2
        @"0 |\n| iPad Pro | 7999 | 85 |\n",
        // 块6：表格内容行3 + 后面的普通文本
        @"| Macbook Air | 9499 | 50 |\n\n表格结束，这是后面的流式内容～"
    ];
    
    // 逐块发送（模拟网络延迟，每0.6秒一块）
    for (NSUInteger i = 0; i < streamChunks.count; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *chunk = streamChunks[i];
            NSLog(@"🔹 收到流式数据块：%@", chunk);
            [self.parser processStreamDataChunk:chunk];
            
            // 可选：主动访问数组（无需block，直接获取最新数据）
            NSLog(@"📊 当前数组长度：%ld\n", self.parser.contentModels.count);
        });
    }
}

/**
 打印更新后的模型数组（外部使用时，可替换为UI渲染逻辑）
 */
- (void)_printUpdatedContentModels:(NSArray<HYBStreamContentModel *> *)models {
    for (HYBStreamContentModel *model in models) {
        if (model.type == HYBStreamContentTypeText) {
            // 普通文本模型：获取文本内容
            HYBStreamTextModel *textModel = (HYBStreamTextModel *)model;
            NSLog(@"📝 文本模型：%@", textModel.content);
        } else if (model.type == HYBStreamContentTypeTable) {
            // 表格模型：获取表头、行数据（实时增量更新）
            HYBStreamTableModel *tableModel = (HYBStreamTableModel *)model;
            NSLog(@"📋 表格模型：");
            NSLog(@"  - 表头：%@", tableModel.header);
            NSLog(@"  - 对齐方式：%@", tableModel.columnAlignments);
            NSLog(@"  - 行数据（共%ld行）：%@", tableModel.rows.count, tableModel.rows);
            NSLog(@"  - 表格状态：%@", tableModel.isCompleted ? @"已完成" : @"解析中");
        }
    }
    NSLog(@"----------------------------------------\n");
}

@end
