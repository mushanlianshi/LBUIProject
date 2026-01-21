//
//  StreamTextProcessor.h
//  LBUIProject
//
//  Created by liu bin on 2025/8/18.
//

#import <Foundation/Foundation.h>

@interface StreamTextProcessor : NSObject

@property (nonatomic, strong) NSMutableString *buffer;
@property (nonatomic, strong) NSMutableArray *resultArray;
@property (nonatomic, assign) BOOL shouldCheckSeparator; // 标记是否应该查找分隔符

- (instancetype)init;
- (void)processCharacter:(NSString *)character;
- (NSArray *)getFinalResult;

@end
