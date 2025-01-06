//
//  UIButton+BLTBlockAction.h
//  Baletu
//
//  Created by Baletoo on 2019/7/22.
//  Copyright © 2019年 朱 亮亮. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (BLTBlockAction)


/**
 按钮点击事件block

 @param block block
 */
- (void)addClickBlock:(dispatch_block_t _Nullable)block;

@end

NS_ASSUME_NONNULL_END
