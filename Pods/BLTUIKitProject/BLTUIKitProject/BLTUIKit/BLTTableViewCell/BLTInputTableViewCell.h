//
//  BLTInputTableViewCell.h
//  BLTUIKitProject_Example
//
//  Created by Baletoo on 2020/10/23.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import "BLTNormalTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLTInputTableViewCell : BLTNormalTableViewCell

@property (nonatomic, strong, readonly) UITextField *textField;

@property (nonatomic, copy) void(^textFieldDidEndEditBlock)(UITextField *textField, NSString *result);

@property (nonatomic, copy) BOOL(^textFieldshouldChangeCharactersBlock)(UITextField *textField, NSRange range, NSString *replaceString);

@end

NS_ASSUME_NONNULL_END
