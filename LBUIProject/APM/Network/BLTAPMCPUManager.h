//
//  BLTAPMCPUManager.h
//  chugefang
//
//  Created by liu bin on 2021/3/23.
//  Copyright © 2021 baletu123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//监控cpu的
@interface BLTAPMCPUManager : NSObject

+ (CGFloat)cpuPercent;

@end

NS_ASSUME_NONNULL_END
