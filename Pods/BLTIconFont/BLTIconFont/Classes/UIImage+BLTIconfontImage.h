//
//  UIImage+BLTIconfontImage.h
//  Baletu
//
//  Created by 尹星 on 2020/2/18.
//  Copyright © 2020 朱 亮亮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BLTIconfontImage)

/**
 iconfont转图片

 @param string 自定义图片url
 自定义url说明 （BLTGeneralIconfont://name=@"iconfont编码映射名称"&fontSize=10&hexColor=0xFFFFFF&hexBbackgroundColor=0x000000&inset=UIEdgeInsetsMake(10, 10, 10, 10)&padding=10）
 必要参数
 BLTGeneralIconfont： iconfont对应字体类型的文件名
 name：iconfont编码映射名称
 fontSize：字体大小
 // 字体颜色设置
 hexColor：十六进制字体颜色
 redColor：RGB颜色中的红色值，设置了hexColor无效
 greenColor：RGB颜色中的绿色值，设置了hexColor无效
 blueColor：RGB颜色中的蓝色值，设置了hexColor无效
 colorAlpha: RGB颜色中的透明度，设置了hexColor无效
 
 非必要参数
 // iconfont转图片，图片背景色
 hexBackgroundColor：iconfont转图片，图片背景十六进制字体色
 redBackgroundColor：RGB颜色中的红色值，设置了hexBackgroundColor无效
 greenBackgroundColor：RGB颜色中的绿色值，设置了hexBackgroundColor无效
 blueBackgroundColor：RGB颜色中的蓝色值，设置了hexBackgroundColor无效
 backgroundColorAlpha: RGB颜色中的透明度，设置了hexBackgroundColor无效
 
 padding：iconfont转图片，填充百分比
 inset：iconfont转图片，周边间距，传入字符串，如：@"UIEdgeInsetsMake(10, 10, 10, 10)"; inset和padding互斥，同时设置时，inset生效。
 
 defaultAspectRatio：iconfont转图片，图片是否按照iconfont文本大小比例设置（YES：图片宽高比和iconfont宽高比相同，NO：图片为正方形）
 @return image
 */
+ (UIImage *)blt_imageWithCodeString:(NSString *)string;

@end
