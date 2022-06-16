//
//  BLTAPMMemoryManager.m
//  chugefang
//
//  Created by liu bin on 2021/3/23.
//  Copyright © 2021 baletu123. All rights reserved.
//

#import "BLTAPMMemoryManager.h"
#import <mach/mach.h>
#import <sys/sysctl.h>

@implementation BLTAPMMemoryManager

+ (uint64_t)getResidentMemory{
    int64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS) {
        memoryUsageInByte = (int64_t) vmInfo.phys_footprint;
    } else {
    }
    return memoryUsageInByte;
    
    //下面获取的和instrument的差距很大  不准
//    struct mach_task_basic_info info;
//    mach_msg_type_number_t count = MACH_TASK_BASIC_INFO_COUNT;
//    //获取当前的 Mach task
//    int r = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)& info, & count);
//    if (r == KERN_SUCCESS)
//    {
//        return info.resident_size;
//    }
//    else
//    {
//        return -1;
//    }
}

//获取所有的物理内存
+ (uint64_t)getDeviceTotalPhysicalMemory{
    return [NSProcessInfo processInfo].physicalMemory;
}

//获取当前设备使用的内容情况
+ (uint64_t)getDeviceUsedMemory{
    size_t length = 0;
        int mib[6] = {0};
        
        int pagesize = 0;
        mib[0] = CTL_HW;
        mib[1] = HW_PAGESIZE;
        length = sizeof(pagesize);
        if (sysctl(mib, 2, &pagesize, &length, NULL, 0) < 0)
        {
            return 0;
        }
        
        mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
        
        vm_statistics_data_t vmstat;
        
        if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS)
        {
            return 0;
        }
        
        int wireMem = vmstat.wire_count * pagesize;
        int activeMem = vmstat.active_count * pagesize;
        return wireMem + activeMem;
}

@end
