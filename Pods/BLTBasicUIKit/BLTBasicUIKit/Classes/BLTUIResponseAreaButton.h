//
//  BLTResponseAreaButton.h
//  BLTUIKit
//
//  Created by liu bin on 2020/3/3.
//  Copyright © 2020 liu bin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 扩大按钮的响应区域的按钮
 */
@interface BLTUIResponseAreaButton : UIButton

- (instancetype)initWithResponseArea:(UIEdgeInsets)responseArea;

@property (nonatomic, assign) UIEdgeInsets responseAreaInsets;

@end

NS_ASSUME_NONNULL_END
