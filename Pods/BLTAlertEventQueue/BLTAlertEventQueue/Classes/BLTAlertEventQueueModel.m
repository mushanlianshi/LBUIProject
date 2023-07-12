//
//  BLTAlertEventQueueModel.m
//  Baletu
//
//  Created by 尹星 on 2019/11/5.
//  Copyright © 2019 朱 亮亮. All rights reserved.
//

#import "BLTAlertEventQueueModel.h"

@implementation BLTAlertEventQueueModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.alertLevel = INT_MAX;
    }
    return self;
}

@end
