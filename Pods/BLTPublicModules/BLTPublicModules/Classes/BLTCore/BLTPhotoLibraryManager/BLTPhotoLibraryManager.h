//
//  BLTPhotoLibraryManager.h
//  Baletu
//
//  Created by Baletoo on 2020/9/17.
//  Copyright © 2020 Baletu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLTPhotoLibraryManager : NSObject

+ (instancetype)sharedManager;

- (void)savePhoto:(UIImage *)photo
    completeBlock:(void(^)(BOOL success, NSError *error))completeBlock;

@end

NS_ASSUME_NONNULL_END
