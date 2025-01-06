//
//  BLTModulesCoreConfigDelegate.h
//  BLTPublicModules
//
//  Created by zhaojh on 2022/4/12.
//

#import <UIKit/UIKit.h>

@protocol BLTModuleMediatorConfigDelegate <NSObject>

@required
-(void)bltMediatorWillReturnObject:(id _Nullable )returnObject paramas:( NSDictionary* _Nullable )paramas;

-(NSDictionary* _Nullable)bltMediatorSwiftModuleParamasWithTarget:(NSString* _Nullable)target action:(NSString* _Nullable)action paramas:( NSDictionary* _Nullable )paramas;


@end
