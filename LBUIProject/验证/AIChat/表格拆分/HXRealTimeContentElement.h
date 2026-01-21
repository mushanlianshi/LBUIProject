//
//  HXRealTimeContentElement.h
//  LBUIProject
//
//  Created by liu bin on 2025/12/4.
//

#import <Foundation/Foundation.h>
#import "HXContentElement.h"

@interface HXRealTimeContentElement : NSObject

@property (nonatomic, assign, readonly) HXContentType type;
@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, copy) NSDate *lastUpdateTime;

// 实时更新方法
- (void)appendContent:(NSString *)content;
- (void)appendCharacter:(unichar)character;

- (void)deleteContent:(NSString *)content;

// 创建方法
+ (instancetype)elementWithType:(HXContentType)type;
+ (instancetype)textElement;
+ (instancetype)tableElement;

@end
