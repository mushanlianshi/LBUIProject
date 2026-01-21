//
//  HXRealTimeStreamParser.h
//  LBUIProject
//
//  Created by liu bin on 2025/12/4.
//

#import <Foundation/Foundation.h>
// HXRealTimeStreamParser.h
#import <Foundation/Foundation.h>
#import "HXRealTimeContentElement.h"

@class HXRealTimeStreamParser;

@protocol HXRealTimeStreamParserDelegate <NSObject>
@optional
// 新元素创建
- (void)parser:(HXRealTimeStreamParser *)parser didCreateElement:(HXRealTimeContentElement *)element;
// 元素内容更新
- (void)parser:(HXRealTimeStreamParser *)parser didUpdateElement:(HXRealTimeContentElement *)element;
// 元素完成（段落/表格结束）
- (void)parser:(HXRealTimeStreamParser *)parser didCompleteElement:(HXRealTimeContentElement *)element;
@end

@interface HXRealTimeStreamParser : NSObject

@property (nonatomic, weak) id<HXRealTimeStreamParserDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray<HXRealTimeContentElement *> *allElements;
@property (nonatomic, strong, readonly) HXRealTimeContentElement *currentElement;

// 流式输入
- (void)appendCharacter:(unichar)character;
- (void)appendString:(NSString *)string;

// 完成解析
- (void)finalize;

@end
