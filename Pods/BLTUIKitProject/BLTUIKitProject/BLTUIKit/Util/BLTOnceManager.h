//
//  BLTOnceManager.h
//  Baletoo_landlord
//
//  Created by liu bin on 2022/9/5.
//  Copyright © 2022 com.wanjian. All rights reserved.
//

#import <Foundation/Foundation.h>

//只执行一次任务的manager
@interface BLTOnceManager : NSObject

+ (BOOL)executeBlock:(dispatch_block_t)block onceIdentifier:(NSString *)onceIdentifier;

@end

