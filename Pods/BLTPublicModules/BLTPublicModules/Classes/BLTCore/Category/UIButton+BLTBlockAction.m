//
//  UIButton+BLTBlockAction.m
//  Baletu
//
//  Created by Baletoo on 2019/7/22.
//  Copyright © 2019年 朱 亮亮. All rights reserved.
//

#import "UIButton+BLTBlockAction.h"
#import <objc/runtime.h>

static const char *BLTBlockActionHandlerKey;

@implementation UIButton (BLTBlockAction)

- (void)addClickBlock:(dispatch_block_t)block
{
    [self addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(self, &BLTBlockActionHandlerKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)clickAction:(UIButton *)sender
{
    dispatch_block_t block = objc_getAssociatedObject(self, &BLTBlockActionHandlerKey);
    if (block) {
        block();
    }
}

@end
