//
//  TBCityIconFont.m
//  iCoupon
//
//  Created by John Wong on 10/12/14.
//  Copyright (c) 2014 Taodiandian. All rights reserved.
//

#import "TBCityIconFont.h"
#import <CoreText/CoreText.h>

@implementation TBCityIconFont

static NSString *_fontName;

+ (void)registerFontWithURL:(NSURL *)url {
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:[url path]], @"Font file doesn't exist");
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)url);
    CGFontRef newFont = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(newFont, nil);
    CGFontRelease(newFont);
}

+ (UIFont *)fontWithSize:(CGFloat)size {
    UIFont *font = [UIFont fontWithName:[self fontName] size:size];
    if (font == nil) {
        NSString *fontfileName = [self fontName];
        NSString *mainBundlePath = [NSBundle mainBundle].bundlePath;
        NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"BLTIconFonts" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        if (bundle == nil) {
            bundlePath = [NSString stringWithFormat:@"%@/%@",mainBundlePath,@"Frameworks/BLTIconFont.framework/BLTIconFonts.bundle"];
            bundle = [NSBundle bundleWithPath:bundlePath];
        }
        NSString *resourcePath = [NSString stringWithFormat:@"%@/%@.ttf",bundle.bundlePath,fontfileName];
        NSURL *fontFileUrl = [NSURL fileURLWithPath:resourcePath];
        [self registerFontWithURL: fontFileUrl];
        font = [UIFont fontWithName:[self fontName] size:size];
        NSAssert(font, @"UIFont object should not be nil, check if the font file is added to the application bundle and you're using the correct font name.");
    }
    return font;
}

+ (UIFont *)fontWithSize: (CGFloat)size withFontName:(NSString*)fontName
{
    UIFont *font = [UIFont fontWithName:fontName size:size];
    if (font == nil) {
        NSString *fontfileName = fontName;
        NSString *mainBundlePath = [NSBundle mainBundle].bundlePath;
        NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"BLTIconFonts" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        if (bundle == nil) {
            bundlePath = [NSString stringWithFormat:@"%@/%@",mainBundlePath,@"Frameworks/BLTIconFont.framework/BLTIconFonts.bundle"];
            bundle = [NSBundle bundleWithPath:bundlePath];
        }
        NSString *resourcePath = [NSString stringWithFormat:@"%@/%@.ttf",bundle.bundlePath,fontfileName];
        NSURL *fontFileUrl = [NSURL fileURLWithPath:resourcePath];
        [self registerFontWithURL: fontFileUrl];
        font = [UIFont fontWithName:fontName size:size];
        NSAssert(font, @"UIFont object should not be nil, check if the font file is added to the application bundle and you're using the correct font name.");
    }
    return font;
}

+ (void)setFontName:(NSString *)fontName {
    _fontName = fontName;
}

+ (NSString *)fontName {
    return _fontName ? : @"iconfont";
}

@end
