//
//  BLTBaseLabel.h
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/25.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLTBaseLabel : UILabel

- (instancetype)initWithContentInsets:(UIEdgeInsets)insets;

/** 内容的区域 */
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;

@end


