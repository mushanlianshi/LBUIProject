//
//  HXContentElement.m
//  LBUIProject
//
//  Created by liu bin on 2025/12/4.
//

// HXContentElement.m
#import "HXContentElement.h"

@implementation HXContentElement

+ (instancetype)elementWithType:(HXContentType)type content:(NSString *)content {
    HXContentElement *element = [[HXContentElement alloc] init];
    element.type = type;
    element.content = [content mutableCopy];
    return element;
}

+ (instancetype)textElementWithContent:(NSString *)content {
    return [self elementWithType:HXContentTypeText content:content];
}

+ (instancetype)tableElementWithContent:(NSString *)content {
    return [self elementWithType:HXContentTypeTable content:content];
}

+ (instancetype)listElementWithContent:(NSString *)content {
    return [self elementWithType:HXContentTypeList content:content];
}

- (NSString *)description {
    NSArray *typeNames = @[@"Text", @"Table", @"List", @"Section"];
    NSString *preview = self.content.length > 30 ?
        [[self.content substringToIndex:30] stringByAppendingString:@"..."] : self.content;
    return [NSString stringWithFormat:@"<HXContentElement type=%@ content=\"%@\">",
            typeNames[self.type], preview];
}

- (NSMutableString *)content{
    if (!_content) {
        _content = [NSMutableString new];
    }
    return _content;
}

@end
