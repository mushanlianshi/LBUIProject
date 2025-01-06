//
//  OARColorDefine.h
//  blt_realtorwell
//
//  Created by yinxing on 2020/7/29.
//  Copyright © 2020 baletu123. All rights reserved.
//

#ifndef BLTPublicModulesColorDefine_h
#define BLTPublicModulesColorDefine_h

#define BLTRGBCOLOR(r,g,b) BLTRGBCOLORA(r,g,b,1)
#define BLTRGBCOLORA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]

#define BLTHEXCOLOR(rgbValue) BLTHEXCOLORA(rgbValue, 1.0)

#define BLTHEXCOLORA(rgbValue,a)                                                                                             \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
alpha:a]

/**
 *  分割线色值
 */
#define BLTLineColor [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1]

/**
*  主色调色值
*/
#define Main_Color(a) BLTHEXCOLORA(0xF7323F, a)

/** 色值1C1C1C */
#define UIColorOneCBlackTitleColor BLTHEXCOLOR(0x1C1C1C)

/**  色值3A3B3C */
#define UIColorThreeABlackTextColor BLTHEXCOLOR(0x3A3B3C)
/** 色值333333的颜色 */
#define UIColorThreeThreeBlackTextColor BLTHEXCOLOR(0x333333)
/**  色值666666的 **/
#define UIColorSixBlackTextColor BLTHEXCOLOR(0x666666)
/**  色值7A7979的 **/
#define UIColorSevenABlackTextColor BLTHEXCOLOR(0x7A7979)
/**  色值999999的 **/
#define UIColorNineLightTextColor BLTHEXCOLOR(0x999999)

/**  色值F7323F的 **/
#define UIColorFSevenRedTextColor BLTHEXCOLOR(0xF7323F)

/**  色值EEEEEE的 **/
#define UIColorSeparatorLineColor BLTHEXCOLOR(0xEEEEEE)

#define UIColorCCPleaceHolderColor BLTHEXCOLOR(0xCCCCCC)


#endif /* OARColorDefine_h */
