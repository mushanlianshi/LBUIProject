//
//  HXContentElement.h
//  LBUIProject
//
//  Created by liu bin on 2025/12/4.
//

#import <Foundation/Foundation.h>

// HXContentElement.h
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HXContentType) {
    HXContentTypeText,      // 普通文本
    HXContentTypeTable,     // 表格
    HXContentTypeList,      // 列表
    HXContentTypeSection,   // 章节标题
};

@interface HXContentElement : NSObject

@property (nonatomic, assign) HXContentType type;
@property (nonatomic, strong) NSMutableString *content; // 完整的文本内容
@property (nonatomic, copy) NSDictionary *metadata; // 元数据
@property(nonatomic, assign) BOOL needRefreshLastMessage;

+ (instancetype)elementWithType:(HXContentType)type content:(NSString *)content;
+ (instancetype)textElementWithContent:(NSString *)content;
+ (instancetype)tableElementWithContent:(NSString *)content;
+ (instancetype)listElementWithContent:(NSString *)content;

@end
