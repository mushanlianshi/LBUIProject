//
//  BLTModulesConfigManager.m
//  BLTPublicModules
//
//  Created by zhaojh on 2022/4/12.
//

#import "BLTModulesConfigManager.h"

static id<NSObject> _modulesConfig;

@implementation BLTModulesConfigManager

+(void)setupConfig:(id<NSObject>)config {
    _modulesConfig = config;
}

+(id<NSObject>)modulesConfig {
    return _modulesConfig;
}

@end
