//
//  HXRealTimeContentElement.m
//  LBUIProject
//
//  Created by liu bin on 2025/12/4.
//

#import "HXRealTimeContentElement.h"

@interface HXRealTimeContentElement()
@property (nonatomic, assign) HXContentType type;
@property (nonatomic, strong) NSMutableString *contentBuffer;
@end

@implementation HXRealTimeContentElement

- (instancetype)initWithType:(HXContentType)type {
    self = [super init];
    if (self) {
        _type = type;
        _contentBuffer = [NSMutableString string];
        _lastUpdateTime = [NSDate date];
    }
    return self;
}

+ (instancetype)elementWithType:(HXContentType)type {
    return [[self alloc] initWithType:type];
}

+ (instancetype)textElement {
    return [self elementWithType:HXContentTypeText];
}

+ (instancetype)tableElement {
    return [self elementWithType:HXContentTypeTable];
}

- (void)appendContent:(NSString *)content {
    if (content.length > 0) {
        @synchronized (self.contentBuffer) {
            [_contentBuffer appendString:content];
            _lastUpdateTime = [NSDate date];
        }
    }
}

- (void)deleteContent:(NSString *)content{
    if (content.length > 0) {
        @synchronized (self.contentBuffer) {
            _contentBuffer = [_contentBuffer stringByReplacingOccurrencesOfString:content withString:@""].mutableCopy;
            _lastUpdateTime = [NSDate date];
        }
    }
}

- (void)appendCharacter:(unichar)character {
    @synchronized (self.contentBuffer) {
        [_contentBuffer appendFormat:@"%C", character];
        _lastUpdateTime = [NSDate date];
    }
}

- (NSString *)content {
    @synchronized (self.contentBuffer) {
        return [_contentBuffer copy];
    }
}

- (NSString *)description {
    NSString *preview = self.content.length > 30 ?
        [[self.content substringToIndex:30] stringByAppendingString:@"..."] : self.content;
    return [NSString stringWithFormat:@"<HXRealTimeContentElement type=%ld content=\"%@\">",
            (long)_type, self.content];
}

@end
