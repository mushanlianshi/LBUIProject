//
//  LBRuntime.h
//  LBUIProject
//
//  Created by liu bin on 2022/6/23.
//

#ifndef LBRuntime_h
#define LBRuntime_h

#import <Foundation/Foundation.h>
#import "NSString+LBExtension.h"

CG_INLINE SEL setSelectorFromGetter(SEL getter){
    NSString *getterString = NSStringFromSelector(getter);
    NSString *setterString = [NSString stringWithFormat:@"set%@:",[getterString firstCapital]];
    return NSSelectorFromString(setterString);
}

CG_INLINE SEL newSetSelectorFromGetter(SEL getter, NSString *prefix){
    NSString *oldGetterString = NSStringFromSelector(setSelectorFromGetter(getter));
    NSString *customPrefix = prefix.length > 0 ? prefix : @"lb";
    NSString *newSetterString = [NSString stringWithFormat:@"%@_%@",customPrefix, oldGetterString];
    return NSSelectorFromString(newSetterString);
}

#endif /* LBRuntime_h */
