#import <Foundation/Foundation.h>

// 内容类型枚举
typedef NS_ENUM(NSInteger, HYBStreamContentType) {
    HYBStreamContentTypeText,  // 普通文本
    HYBStreamContentTypeTable  // 表格
};

// 表格列对齐方式（复用之前的枚举，统一管理）
typedef NS_ENUM(NSInteger, HYBStreamTableColumnAlignment) {
    HYBStreamTableColumnAlignmentLeft,
    HYBStreamTableColumnAlignmentCenter,
    HYBStreamTableColumnAlignmentRight
};

#pragma mark - 基类：统一内容模型
@interface HYBStreamContentModel : NSObject
/// 内容类型（用于外部区分 Text/Table）
@property (nonatomic, assign, readonly) HYBStreamContentType type;
/// 是否已完成（Table 专属：标记表格是否解析结束）
@property (nonatomic, assign, getter=isCompleted) BOOL completed;

- (instancetype)initWithType:(HYBStreamContentType)type;

@property(nonatomic, copy) NSString *content;

@end


#pragma mark - 子类1：普通文本模型
@interface HYBStreamTextModel : HYBStreamContentModel

/// 追加文本（内部使用，解析器调用）
- (void)appendText:(NSString *)text;

@end


#pragma mark - 子类2：表格模型
@interface HYBStreamTableModel : HYBStreamContentModel
/// 表头数组（如 @[@"姓名", @"年龄", @"城市"]）
@property (nonatomic, strong, readonly) NSArray<NSString *> *header;
/// 每列对齐方式（与表头顺序一致）
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *columnAlignments;
/// 表格行数据（包含分隔行，如 @[@[@"-", @"-", @"-"], @[@"张三", @"25", @"上海"]]）
@property (nonatomic, strong, readonly) NSMutableArray<NSArray<NSString *> *> *rows;

/// 初始化表格模型（内部使用）
- (instancetype)initWithHeader:(NSArray<NSString *> *)header
              columnAlignments:(NSArray<NSNumber *> *)columnAlignments;
/// 追加表格行（内部使用，解析器调用）
- (void)appendRow:(NSArray<NSString *> *)row;
/// 标记表格完成（内部使用）
- (void)markAsCompleted;
@end
