//
//  LBChatTableViewController.m
//  LBUIProject
//
//  Created by liu bin on 2025/12/4.
//

#import "LBChatTableViewController.h"
#import "HXStreamContentParser.h"
#import "HXSimpleStreamParser.h"
#import "HXRealTimeStreamParser.h"

@interface LBChatTableViewController ()<HXRealTimeStreamParserDelegate>


@end

@implementation LBChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self testRealTimeParsing];
}

- (void)testRealTimeParsing{
    HXRealTimeStreamParser *parser = [[HXRealTimeStreamParser alloc] init];
    parser.delegate = self;
    // 模拟流式输入
    NSString *streamOutput = @"以下是为您实时搜索到的结果：\n\n"
                            "由于当前搜索结果未提供具体的黄金金价数据表格或相关分析内容，我将基于一般金融分析框架为您梳理黄金价格的影响因素及常见分析方法，并附上结构化解读建议：\n\n"
                            "---\n\n"
                            "### **黄金金价分析框架（表格建议）**\n\n"
                            "| 分析维度       | 关键指标/因素                  | 说明与数据来源建议                  |\n"
                            "|----------------|-------------------------------|-----------------------------------|\n"
                            "| **历史价格走势** | 1年/5年/10年波动曲线          | 建议从伦敦金（XAU）或纽约COMEX期货获取日线/周线数据 |\n"
                            "| **短期驱动因素** | - 美元指数(DXY)反向关系<br>- 地缘政治风险指数<br>- 美联储利率决议 | 通常美元走弱时金价上涨，需关注CPI数据发布节点 |\n"
                            "| **供需基本面**  | - 全球央行购金量（如中国、土耳其）<br>- 黄金ETF持仓量变化 | 世界黄金协会(WGC)季度报告提供官方数据 |\n"
                            "| **技术指标**    | - 200日均线突破情况<br>- RSI超买/超卖信号 | 常用分析工具：MACD、布林带通道 |\n"
                            "---\n\n"
                            "### **深度分析要点**\n\n"
                            "1. **跨市场联动性**  \n\n"
                            "   - 黄金与比特币、美债的实际收益率（TIPs）存在相关性，2023年以来避险资产轮动加速\n"
                            "   - 示例：若美国10年期国债收益率突破4.5%，金价可能承压\n"
                            "2. **季节性规律**  \n"
                            "   - 传统旺季（如中国春节、印度婚季）通常支撑Q4-Q1价格\n"
                            "   - 近5年统计显示12月平均涨幅达3.2%（需验证当年数据）\n"
                            "3. **极端情景推演**  \n"
                            "   - 黑天鹅事件（如银行危机）可能导致单日涨幅超5%（参考2023年硅谷银行事件）\n"
                            "   - 通胀预期若回升至3%上方，或触发对冲买盘\n"
                            "---\n"
                            "如需具体数值分析，建议提供：  \n"
                            "- 目标时间段（如近1个月/1年）  \n"
                            "- 特定市场（上海金交所AU9999/国际现货黄金等）  \n"
                            "- 分析用途（投资决策/学术研究等）  \n"
                            "（注：以上为通用分析模型，实际数据需通过彭博、路透或金十数据等专业平台获取实时验证）";
    
    NSLog(@"开始流式解析...\n");
    
    // 逐字模拟流式输入
    for (NSInteger i = 0; i < streamOutput.length; i++) {
        unichar character = [streamOutput characterAtIndex:i];
        [parser appendCharacter:character];
        // 模拟网络延迟
        [NSThread sleepForTimeInterval:0.01];
        if (i == streamOutput.length - 1) {
            NSLog(@"LBLog list is %@", parser.allElements);
        }
    }
    
    // 完成解析
    [parser finalize];
}

#pragma mark - 代理方法
// 新元素创建
- (void)parser:(HXRealTimeStreamParser *)parser didCreateElement:(HXRealTimeContentElement *)element{
    NSLog(@"LBLog 🆕 创建新元素: %@", parser.allElements);
}
// 元素内容更新
- (void)parser:(HXRealTimeStreamParser *)parser didUpdateElement:(HXRealTimeContentElement *)element{
    NSLog(@"LBLog 更新元素: %@", parser.allElements);
}
// 元素完成（段落/表格结束）
- (void)parser:(HXRealTimeStreamParser *)parser didCompleteElement:(HXRealTimeContentElement *)element{
    NSLog(@"LBLog 元素完成: %@", parser.allElements);
}


// 使用示例
- (void)testStreamParsing {
    HXSimpleStreamParser *parser = [[HXSimpleStreamParser alloc] init];
    
    // 模拟流式输入
    NSString *streamOutput = @"以下是为您实时搜索到的结果：\n"
                            "由于当前搜索结果未提供具体的黄金金价数据表格或相关分析内容，我将基于一般金融分析框架为您梳理黄金价格的影响因素及常见分析方法，并附上结构化解读建议：\n"
                            "---\n"
                            "### **黄金金价分析框架（表格建议）**\n"
                            "| 分析维度       | 关键指标/因素                  | 说明与数据来源建议                  |\n"
                            "|----------------|-------------------------------|-----------------------------------|\n"
                            "| **历史价格走势** | 1年/5年/10年波动曲线          | 建议从伦敦金（XAU）或纽约COMEX期货获取日线/周线数据 |\n"
                            "| **短期驱动因素** | - 美元指数(DXY)反向关系<br>- 地缘政治风险指数<br>- 美联储利率决议 | 通常美元走弱时金价上涨，需关注CPI数据发布节点 |\n"
                            "| **供需基本面**  | - 全球央行购金量（如中国、土耳其）<br>- 黄金ETF持仓量变化 | 世界黄金协会(WGC)季度报告提供官方数据 |\n"
                            "| **技术指标**    | - 200日均线突破情况<br>- RSI超买/超卖信号 | 常用分析工具：MACD、布林带通道 |\n"
                            "---\n"
                            "### **深度分析要点**\n"
                            "1. **跨市场联动性**  \n"
                            "   - 黄金与比特币、美债的实际收益率（TIPs）存在相关性，2023年以来避险资产轮动加速\n"
                            "   - 示例：若美国10年期国债收益率突破4.5%，金价可能承压\n"
                            "2. **季节性规律**  \n"
                            "   - 传统旺季（如中国春节、印度婚季）通常支撑Q4-Q1价格\n"
                            "   - 近5年统计显示12月平均涨幅达3.2%（需验证当年数据）\n"
                            "3. **极端情景推演**  \n"
                            "   - 黑天鹅事件（如银行危机）可能导致单日涨幅超5%（参考2023年硅谷银行事件）\n"
                            "   - 通胀预期若回升至3%上方，或触发对冲买盘\n"
                            "---\n"
                            "如需具体数值分析，建议提供：  \n"
                            "- 目标时间段（如近1个月/1年）  \n"
                            "- 特定市场（上海金交所AU9999/国际现货黄金等）  \n"
                            "- 分析用途（投资决策/学术研究等）  \n"
                            "（注：以上为通用分析模型，实际数据需通过彭博、路透或金十数据等专业平台获取实时验证）";
    
    NSLog(@"开始流式解析...\n");
    
    // 逐字模拟流式输入
    for (NSInteger i = 0; i < streamOutput.length; i++) {
        unichar character = [streamOutput characterAtIndex:i];
        [parser appendCharacter:character];
        
        // 可以实时查看解析状态
        if (i % 10 == 0 || i == streamOutput.length - 1) {
//            NSLog(@"已解析 %ld/%ld 字符, 当前状态: %@",
//                  (long)i + 1, (long)streamOutput.length,
//                  parser.isInTable ? @"表格中" : parser.isInList ? @"列表中" : @"文本中");
            
            // 实时显示已解析的元素
            NSArray *elements = [parser.parsedElements copy];
            for (HXContentElement *element in elements) {
                NSLog(@"元素: %@", element);
            }
        }
    }
    
    // 完成解析
    [parser finalize];
    
    // 输出最终结果
    NSLog(@"\n解析完成，共 %ld 个元素:", parser.parsedElements.count);
    for (HXContentElement *element in parser.parsedElements) {
        NSString *typeStr;
        switch (element.type) {
            case HXContentTypeText: typeStr = @"文本"; break;
            case HXContentTypeTable: typeStr = @"表格"; break;
            case HXContentTypeList: typeStr = @"列表"; break;
            case HXContentTypeSection: typeStr = @"章节"; break;
        }
        NSLog(@"类型: %@, 长度: %ld", typeStr, (long)element.content.length);
    }
}

// 测试代码
- (void)testIncrementally {
    HXStreamContentParser *parser = [[HXStreamContentParser alloc] init];
    
    // 模拟从网络流逐块接收
    NSArray *chunks = @[
        @"以下是为您实时搜索到的结果：\n",
        @"由于当前搜索结果未提供具体的黄金金价数据表格或相关分析内容，我将基于一般金融分析框架为您梳理黄金价格的影响因素及常见分析方法，并附上结构化解读建议：\n",
        @"---\n",
        @"### **黄金金价分析框架（表格建议）**\n",
        @"| 分析维度       | 关键指标/因素                  | 说明与数据来源建议                  |\n",
        @"|----------------|-------------------------------|-----------------------------------|\n",
        @"| **历史价格走势** | 1年/5年/10年波动曲线          | 建议从伦敦金（XAU）或纽约COMEX期货获取日线/周线数据 |\n",
        @"| **短期驱动因素** | - 美元指数(DXY)反向关系<br>- 地缘政治风险指数<br>- 美联储利率决议 | 通常美元走弱时金价上涨，需关注CPI数据发布节点 |\n",
        @"| **供需基本面**  | - 全球央行购金量（如中国、土耳其）<br>- 黄金ETF持仓量变化 | 世界黄金协会(WGC)季度报告提供官方数据 |\n",
        @"| **技术指标**    | - 200日均线突破情况<br>- RSI超买/超卖信号 | 常用分析工具：MACD、布林带通道 |\n",
        @"---\n"
    ];
    
    for (NSString *chunk in chunks) {
        NSLog(@"接收块: %@", [chunk substringToIndex:MIN(20, chunk.length)]);
        [parser appendString:chunk];
        
        // 显示实时解析结果
        if (parser.parsedElements.count > 0) {
            HXContentElement *lastElement = parser.parsedElements.lastObject;
            NSLog(@"最新元素: %@", lastElement);
        }
    }
    
    [parser finalize];
    NSLog(@"最终解析出 %ld 个元素", parser.parsedElements.count);
}


@end
