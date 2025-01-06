//
//  OARFontDefine.h
//  blt_realtorwell
//
//  Created by yinxing on 2020/7/29.
//  Copyright © 2020 baletu123. All rights reserved.
//

#ifndef BLTPublicModulesFontDefine_h
#define BLTPublicModulesFontDefine_h

#define FontSize(x) [UIFont fontWithName:systemFont size:x]

#define FontBoldSize(x) [UIFont boldSystemFontOfSize:x]

#define systemFont [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 ? @"PingFangSC-Regular" : @"Helvetica"
#define systemBoldFont [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 ? @"PingFangSC-Semibold" : @"Helvetica"

CG_INLINE UIFont *PFFontSize(CGFloat x){
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:x] ? [UIFont fontWithName:@"PingFangSC-Regular" size:x] : FontSize(x);
    return font;
}

CG_INLINE UIFont *PFFontBoldSize(CGFloat x){
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Semibold" size:x] ? [UIFont fontWithName:@"PingFangSC-Semibold" size:x] : FontBoldSize(x);
    return font;
}

CG_INLINE UIFont *PFFontMediumSize(CGFloat x){
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Medium" size:x] ? [UIFont fontWithName:@"PingFangSC-Medium" size:x] : FontSize(x);
    return font;
}

CG_INLINE UIFont *DINAFontBoldSize(CGFloat x){
    UIFont *font = [UIFont fontWithName:@"DINAlternate-Bold" size:x] ? [UIFont fontWithName:@"DINAlternate-Bold" size:x] : FontSize(x);
    return font;
}

#endif 
