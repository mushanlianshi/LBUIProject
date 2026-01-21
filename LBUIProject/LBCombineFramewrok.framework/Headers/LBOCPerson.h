//
//  LBOCPerson.h
//  LBCombineFramewrok
//
//  Created by liu bin on 2025/8/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBOCPerson : NSObject

@property(nonatomic, copy) NSString *testName;

- (void)printName;

- (void)callSwiftMethod;

@end

NS_ASSUME_NONNULL_END
