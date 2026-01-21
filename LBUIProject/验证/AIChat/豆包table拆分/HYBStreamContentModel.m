#import <Foundation/Foundation.h>
#import "HYBStreamContentModel.h"

@implementation HYBStreamContentModel
- (instancetype)initWithType:(HYBStreamContentType)type {
    self = [super init];
    if (self) {
        _type = type;
        _completed = NO;
    }
    return self;
}
@end




@implementation HYBStreamTextModel
- (instancetype)init {
    self = [super initWithType:HYBStreamContentTypeText];
    return self;
}

- (void)appendText:(NSString *)text {
    if (!text.length) return;
    self.content = self.content ? [self.content stringByAppendingString:text] : text;
}


@end


@implementation HYBStreamTableModel
- (instancetype)initWithHeader:(NSArray<NSString *> *)header
              columnAlignments:(NSArray<NSNumber *> *)columnAlignments {
    self = [super initWithType:HYBStreamContentTypeTable];
    if (self) {
        _header = header.copy;
        _columnAlignments = columnAlignments.copy;
        _rows = [NSMutableArray array];
        self.content = header.copy ?: @"";
    }
    return self;
}

- (void)appendRow:(NSArray<NSString *> *)row {
    if (row.count == self.header.count) {
        [self.rows addObject:row.copy];
    }
    
    for (NSString *text in row) {
        self.content = [self.content stringByAppendingString:text];
    }
}

- (void)markAsCompleted {
    self.completed = YES;
}


@end
