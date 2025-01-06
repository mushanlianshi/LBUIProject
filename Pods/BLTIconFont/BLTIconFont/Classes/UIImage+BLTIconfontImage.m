//
//  UIImage+BLTIconfontImage.m
//  Baletu
//
//  Created by 尹星 on 2020/2/18.
//  Copyright © 2020 朱 亮亮. All rights reserved.
//

#import "UIImage+BLTIconfontImage.h"
#import "BLTIconFontModel.h"
#import "HQFontImage.h"

@implementation UIImage (BLTIconfontImage)

+ (UIImage *)blt_imageWithCodeString:(NSString *)string
{
    if ([string containsString:@"://"]) {
        // 自定义url转换  BLTGeneralIconfont://name=@""&size=10&hexColor=@""&backgroundColor=@""&inset=@""&padding=@""
        BLTIconFontModel *model = [BLTIconFontModel conversionUrlString:string];
        UIImage *image;
        // 通用iconfont
        if (model.defaultAspectRatio) {
            image = [NSClassFromString(model.iconfontClassName) iconDefaultAspectRatioWithName:model.name fontSize:model.fontSize color:model.color inset:model.inset withBackgroundColor:model.backgroundColor];
        }else {
            image = [NSClassFromString(model.iconfontClassName) iconWithName:model.name fontSize:model.fontSize color:model.color inset:model.inset withBackgroundColor:model.backgroundColor];
        }
        return image;
    }else {
        return [self imageNamed:string];
    }
}

@end
