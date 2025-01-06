//
//  NSObject+AutoProperty.h
//  RuntimeDemo
//
//  Created by 邱学伟 on 16/9/8.
//  Copyright © 2016年 邱学伟. All rights reserved.
//  自动生成属性列表

#import <Foundation/Foundation.h>

@interface NSObject (AutoProperty)
/**
 *  自动生成属性列表
 *
 *  @param dict JSON字典/模型字典
 */
+(void)printPropertyWithDict:(NSDictionary *)dict;

#pragma mark -- 扩展事件传递block
/**事件外传递block*/
@property (nonatomic, copy) void (^customActionBlock)(id obj, NSInteger actionType);

@end

