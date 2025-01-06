//
//  BLTIconFontModel.m
//  Baletu
//
//  Created by 尹星 on 2020/2/18.
//  Copyright © 2020 朱 亮亮. All rights reserved.
//

#import "BLTIconFontModel.h"

@implementation BLTIconFontModel

+ (BLTIconFontModel *)conversionUrlString:(NSString *)urlString
{
    BLTIconFontModel *model = [[BLTIconFontModel alloc] init];
    NSRange range = [urlString rangeOfString:@"://"];
    // 不存在://返回空model
    if (range.length == 0) {
        return model;
    }
    NSString *iconfontFontFamily = [urlString substringWithRange:NSMakeRange(0, range.location)];
    NSString *paramsStr = [urlString substringFromIndex:range.location + range.length];
    
    // 将url参数分割
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    NSArray *urlParamsArray = [paramsStr componentsSeparatedByString:@"&"];
    [urlParamsArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // @“=”切割参数，获取key和value
        if ([obj rangeOfString:@"="].length != 0) {
            NSArray *array = [obj componentsSeparatedByString:@"="];
            if (array.count == 2) {
                [paramsDic setObject:array[1] forKey:array[0]];
            }
        }
    }];
    
    model.iconfontClassName = iconfontFontFamily;
    model.name = paramsDic[@"name"];
    model.fontSize = [paramsDic[@"fontSize"] floatValue];
    if (paramsDic[@"hexColor"]) {
        model.color = [self hexColorWithLong:[self hexStringFromString:paramsDic[@"hexColor"]]];
    }else if (paramsDic[@"redColor"] && paramsDic[@"greenColor"] && paramsDic[@"blueColor"]) {
        CGFloat alpha = [(paramsDic[@"colorAlpha"] ? : @"1") floatValue];
        model.color = [UIColor colorWithRed:[paramsDic[@"redColor"] floatValue] / 255.0 green:[paramsDic[@"greenColor"] floatValue] / 255.0 blue:[paramsDic[@"blueColor"] floatValue] / 255.0 alpha:alpha];
    }
    
    if (paramsDic[@"inset"]) {
        model.inset = UIEdgeInsetsFromString(paramsDic[@"inset"]);
    }else if (paramsDic[@"padding"]) {
        CGFloat padding = [paramsDic[@"padding"] floatValue] * [paramsDic[@"fontSize"] floatValue];
        model.inset = UIEdgeInsetsMake(padding, padding, padding, padding);
    }
    if (paramsDic[@"hexBackgroundColor"]) {
        model.backgroundColor = [self hexColorWithLong:[self hexStringFromString:paramsDic[@"hexBackgroundColor"]]];
    }else if (paramsDic[@"redBackgroundColor"] && paramsDic[@"greenBackgroundColor"] && paramsDic[@"blueBackgroundColor"]) {
        CGFloat alpha = [(paramsDic[@"backgroundColorAlpha"] ? : @"1") floatValue];
        model.backgroundColor = [UIColor colorWithRed:[paramsDic[@"redBackgroundColor"] floatValue] / 255.0 green:[paramsDic[@"greenBackgroundColor"] floatValue] / 255.0 blue:[paramsDic[@"blueBackgroundColor"] floatValue] / 255.0 alpha:alpha];
    }
    model.defaultAspectRatio = [paramsDic[@"defaultAspectRatio"] boolValue];
    return model;
}

+ (long)hexStringFromString:(NSString *)string
{
    NSMutableString *hexString = [string mutableCopy];
    // 如果hexString包含#，则将#替换成0x
    if ([hexString containsString:@"#"]) {
        [hexString replaceCharactersInRange:[hexString rangeOfString:@"#" ] withString:@"0x"];
    }else if (![hexString containsString:@"0x"]) { // 如果hexString没有#也没有0x，则拼接0x
        [hexString appendFormat:@"0x%@",hexString];
    }
    long color = strtoul([hexString cStringUsingEncoding:NSUTF8StringEncoding], 0, 16);
    return color;
}

+ (UIColor *)hexColorWithLong:(long)rgbValue
{
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0
                           green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0
                            blue:((float)(rgbValue & 0xFF)) / 255.0
                           alpha:1.0];
}

@end
