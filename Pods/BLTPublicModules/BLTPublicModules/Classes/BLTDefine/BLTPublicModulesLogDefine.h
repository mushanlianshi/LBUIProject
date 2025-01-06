//
//  OARLogDefine.h
//  blt_realtorwell
//
//  Created by yinxing on 2020/7/31.
//  Copyright © 2020 baletu123. All rights reserved.
//

#ifndef BLTPublicModulesLogDefine_h
#define BLTPublicModulesLogDefine_h

// 打印日志(http)
#ifdef DEBUG
    # define BLTHTTP_DEBUG(fmt, ...) NSLog((@"\n[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
    # define BLTHTTP_DEBUG(...) {}
#endif

#ifdef DEBUG
# define DEF_DEBUG(fmt, ...) NSLog((@"\n[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DEF_String_VAR(VARNAME) [NSString stringWithFormat:@"%@",@#VARNAME]

#else
# define DEF_DEBUG(...) {}
#endif

#endif /* OARLogDefine_h */
