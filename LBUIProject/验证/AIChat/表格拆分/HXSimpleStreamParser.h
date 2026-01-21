//
//  HXSimpleStreamParser.h
//  LBUIProject
//
//  Created by liu bin on 2025/12/4.
//

#import <Foundation/Foundation.h>

// HXSimpleStreamParser.h
#import <Foundation/Foundation.h>
#import "HXContentElement.h"

@interface HXSimpleStreamParser : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<HXContentElement *> *parsedElements;

// 逐字添加
- (void)appendCharacter:(unichar)character;
// 完成解析
- (void)finalize;
// 重置
- (void)reset;

@end
