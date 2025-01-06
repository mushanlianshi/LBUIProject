//
//  NSObject+AutoProperty.m
//  RuntimeDemo
//
//  Created by 邱学伟 on 16/9/8.
//  Copyright © 2016年 邱学伟. All rights reserved.
//

#import "NSObject+AutoProperty.h"
#import "objc/runtime.h"
#import "MBProgressHUD.h"
#import "BLTPublicModulesDefine.h"

@implementation NSObject (AutoProperty)
/**
 *  自动生成属性列表
 *
 *  @param dict JSON字典/模型字典
 */
+(void)printPropertyWithDict:(NSDictionary *)dict{
    NSMutableString *allPropertyCode = [[NSMutableString alloc]init];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *oneProperty = [[NSString alloc]init];
        if ([obj isKindOfClass:[NSString class]]) {
            oneProperty = [NSString stringWithFormat:@"@property (nonatomic, copy) NSString *%@;",key];
        }else if ([obj isKindOfClass:[NSNumber class]]){
            oneProperty = [NSString stringWithFormat:@"@property (nonatomic, assign) NSInteger %@;",key];
        }else if ([obj isKindOfClass:[NSArray class]]){
            oneProperty = [NSString stringWithFormat:@"@property (nonatomic, copy) NSArray *%@;",key];
        }else if ([obj isKindOfClass:[NSDictionary class]]){
            oneProperty = [NSString stringWithFormat:@"@property (nonatomic, copy) NSDictionary *%@;",key];
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFBoolean")]){
            oneProperty = [NSString stringWithFormat:@"@property (nonatomic, assign) BOOL %@;",key];
        }
        [allPropertyCode appendFormat:@"\n%@\n",oneProperty];
    }];
    NSLog(@"%@",allPropertyCode);
}

- (void)setCustomActionBlock:(void (^)(id, NSInteger))customActionBlock{
    objc_setAssociatedObject(self, @selector(customActionBlock), customActionBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(id, NSInteger))customActionBlock{
    return objc_getAssociatedObject(self, _cmd);
}




@end
