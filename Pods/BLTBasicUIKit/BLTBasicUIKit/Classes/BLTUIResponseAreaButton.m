//
//  BLTResponseAreaButton.m
//  BLTUIKit
//
//  Created by liu bin on 2020/3/3.
//  Copyright © 2020 liu bin. All rights reserved.
//

#import "BLTUIResponseAreaButton.h"
#import "BLTUIKitFrameHeader.h"

@implementation BLTUIResponseAreaButton

- (instancetype)initWithResponseArea:(UIEdgeInsets)responseArea{
    self = [super init];
    if (self) {
        self.responseAreaInsets = responseArea;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if (UIEdgeInsetsEqualToEdgeInsets(self.responseAreaInsets, UIEdgeInsetsZero)) {
        return [super pointInside:point withEvent:event];
    }else{
        CGRect nowFrame = CGRectFromUIEdgeInsets(self.bounds, self.responseAreaInsets);
        return CGRectContainsPoint(nowFrame, point);
    }
}

@end
