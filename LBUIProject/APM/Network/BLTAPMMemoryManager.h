//
//  BLTAPMMemoryManager.h
//  chugefang
//
//  Created by liu bin on 2021/3/23.
//  Copyright © 2021 baletu123. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 获取内存使用情况
@interface BLTAPMMemoryManager : NSObject

//获取当前应用的memory
+ (uint64_t)getResidentMemory;

//获取所有的物理内存
+ (uint64_t)getDeviceTotalPhysicalMemory;

//获取当前设备使用的内容情况
+ (uint64_t)getDeviceUsedMemory;

@end

NS_ASSUME_NONNULL_END
