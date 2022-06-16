//
//  BLTBaseLabel.m
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/25.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import "BLTBaseLabel.h"

@implementation BLTBaseLabel

- (instancetype)initWithContentInsets:(UIEdgeInsets)insets{
    self = [super init];
    if (self) {
        self.contentEdgeInsets = insets;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.contentEdgeInsets)];
}

@end
