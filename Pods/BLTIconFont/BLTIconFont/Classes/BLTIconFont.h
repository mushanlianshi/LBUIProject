//
//  BLTIconFont.h
//  Pods
//
//  Created by yinxing on 2020/5/8.
//

#ifndef BLTIconFont_h
#define BLTIconFont_h

#import "HQFontImage.h"
#import "UIImage+BLTIconfontImage.h"

typedef NSString *kBLTCustomIconfont NS_STRING_ENUM;

// 租客App
static kBLTCustomIconfont const kBLTCustomIconfontGen = @"BLTGenIconfontImage";
static kBLTCustomIconfont const kBLTCustomIconfontBus = @"BLTBusIconfontImage";
static kBLTCustomIconfont const kBLTCustomIconfontGeneral = @"BLTGeneralIconfontImage";
static kBLTCustomIconfont const kBLTCustomIconfontBusiness = @"BLTBusinessIconfontImage";

// 出个房App
static kBLTCustomIconfont const kOARCustomIconfontBusiness = @"OARBusinessIconfontImage";


// 功能型iconfont
CG_INLINE UIImage *BLTMakeIconfontImage(kBLTCustomIconfont fontName, NSString *name, CGFloat fontSize, UIColor *color, BOOL defaultAspectRatio) {
    if (defaultAspectRatio) {
        return [NSClassFromString(fontName) iconDefaultAspectRatioWithName:name fontSize:fontSize color:color];
    }
    return [NSClassFromString(fontName) iconWithName:name fontSize:fontSize color:color];
}

CG_INLINE UIImage *BLTMakeIconfontImagePadding(kBLTCustomIconfont fontName, NSString *name, CGFloat fontSize, UIColor *color, CGFloat padding, BOOL defaultAspectRatio) {
    if (defaultAspectRatio) {
        return [NSClassFromString(fontName) iconDefaultAspectRatioWithName:name fontSize:fontSize color:color padding:padding];
    }
    return [NSClassFromString(fontName) iconWithName:name fontSize:fontSize color:color padding:padding];
}

CG_INLINE UIImage *BLTMakeIconfontImageInset(kBLTCustomIconfont fontName, NSString *name, CGFloat fontSize, UIColor *color, UIEdgeInsets inset, BOOL defaultAspectRatio) {
    if (defaultAspectRatio) {
        return [NSClassFromString(fontName) iconDefaultAspectRatioWithName:name fontSize:fontSize color:color inset:inset];
    }
    return [NSClassFromString(fontName) iconWithName:name fontSize:fontSize color:color inset:inset];
}

CG_INLINE UIImage *BLTMakeIconfontImageBackgroundColor(kBLTCustomIconfont fontName, NSString *name, CGFloat fontSize, UIColor *color, UIColor *backgroundColor, BOOL defaultAspectRatio) {
    if (defaultAspectRatio) {
        return [NSClassFromString(fontName) iconDefaultAspectRatioWithName:name fontSize:fontSize color:color withBackgroundColor:backgroundColor];
    }
    return [NSClassFromString(fontName) iconWithName:name fontSize:fontSize color:color withBackgroundColor:backgroundColor];
}

CG_INLINE UIImage *BLTMakeIconfontImagePaddingBackgroundColor(kBLTCustomIconfont fontName, NSString *name, CGFloat fontSize, UIColor *color, CGFloat padding, UIColor *backgroundColor, BOOL defaultAspectRatio) {
    if (defaultAspectRatio) {
        return [NSClassFromString(fontName) iconDefaultAspectRatioWithName:name fontSize:fontSize color:color padding:padding withBackgroundColor:backgroundColor];
    }
    return [NSClassFromString(fontName) iconWithName:name fontSize:fontSize color:color padding:padding withBackgroundColor:backgroundColor];
}

CG_INLINE UIImage *BLTMakeIconfontImageMain(kBLTCustomIconfont fontName, NSString *name, CGFloat fontSize, UIColor *color, UIEdgeInsets inset, UIColor *backgroundColor, BOOL defaultAspectRatio) {
    if (defaultAspectRatio) {
        return [NSClassFromString(fontName) iconDefaultAspectRatioWithName:name fontSize:fontSize color:color inset:inset withBackgroundColor:backgroundColor];
    }
    return [NSClassFromString(fontName) iconWithName:name fontSize:fontSize color:color inset:inset withBackgroundColor:backgroundColor];
}

// 功能型iconfont
CG_INLINE NSString *BLTIconfontImageCustomUrlString(kBLTCustomIconfont fontName, NSString *name, CGFloat fontSize, UIColor *color, BOOL defaultAspectRatio) {
    return [NSClassFromString(fontName) codeStringWithName:name fontSize:fontSize color:color defaultAspectRatio:defaultAspectRatio];
}

CG_INLINE NSString *BLTIconfontImageCustomUrlStringPadding(kBLTCustomIconfont fontName, NSString *name, CGFloat fontSize, UIColor *color, CGFloat padding, BOOL defaultAspectRatio) {
    return [NSClassFromString(fontName) codeStringWithName:name fontSize:fontSize color:color padding:padding defaultAspectRatio:defaultAspectRatio];
}

CG_INLINE NSString *BLTIconfontImageCustomUrlStringInset(kBLTCustomIconfont fontName, NSString *name, CGFloat fontSize, UIColor *color, UIEdgeInsets inset, BOOL defaultAspectRatio) {
    return [NSClassFromString(fontName) codeStringWithName:name fontSize:fontSize color:color inset:inset defaultAspectRatio:defaultAspectRatio];
}

CG_INLINE NSString *BLTIconfontImageCustomUrlStringBackgroundColor(kBLTCustomIconfont fontName, NSString *name, CGFloat fontSize, UIColor *color, UIColor *backgroundColor, BOOL defaultAspectRatio) {
    return [NSClassFromString(fontName) codeStringWithName:name fontSize:fontSize color:color withBackgroundColor:backgroundColor defaultAspectRatio:defaultAspectRatio];
}

CG_INLINE NSString *BLTIconfontImageCustomUrlStringPaddingBackgroundColor(kBLTCustomIconfont fontName, NSString *name, CGFloat fontSize, UIColor *color, CGFloat padding, UIColor *backgroundColor, BOOL defaultAspectRatio) {
    return [NSClassFromString(fontName) codeStringWithName:name fontSize:fontSize color:color padding:padding withBackgroundColor:backgroundColor defaultAspectRatio:defaultAspectRatio];
}

CG_INLINE NSString *BLTIconfontImageCustomUrlStringMain(kBLTCustomIconfont fontName, NSString *name, CGFloat fontSize, UIColor *color, UIEdgeInsets inset, UIColor *backgroundColor, BOOL defaultAspectRatio) {
    return [NSClassFromString(fontName) codeStringWithName:name fontSize:fontSize color:color inset:inset withBackgroundColor:backgroundColor defaultAspectRatio:defaultAspectRatio];
}

#endif /* BLTIconFont_h */
