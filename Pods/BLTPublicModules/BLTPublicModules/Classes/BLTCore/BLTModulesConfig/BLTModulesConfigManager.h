//
//  BLTModulesConfigManager.h
//  BLTPublicModules
//
//  Created by zhaojh on 2022/4/12.
//

#import <Foundation/Foundation.h>

@interface BLTModulesConfigManager : NSObject

+(void)setupConfig:(id<NSObject>)config;

+(id<NSObject>)modulesConfig;

@end

