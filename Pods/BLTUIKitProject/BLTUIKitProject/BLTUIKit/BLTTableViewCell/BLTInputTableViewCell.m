//
//  BLTInputTableViewCell.m
//  BLTUIKitProject_Example
//
//  Created by Baletoo on 2020/10/23.
//  Copyright © 2020 mushanlianshi. All rights reserved.
//

#import "BLTInputTableViewCell.h"
#import <Masonry/Masonry.h>

@interface BLTInputTableViewCell () <UITextFieldDelegate>

@property (nonatomic, strong, readwrite) UITextField *textField;

@end

@implementation BLTInputTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.additionalAccessoryView = self.textField;
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.offset(0);
        }];
    }
    return self;
}

#pragma mark - UITextField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.textFieldDidEndEditBlock) {
        self.textFieldDidEndEditBlock(textField, textField.text);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.textFieldshouldChangeCharactersBlock) {
        return self.textFieldshouldChangeCharactersBlock(textField, range, string);
    }
    else {
        return YES;
    }
}

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.font = [UIFont systemFontOfSize:16.0f];
        _textField.textColor = [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.textAlignment = NSTextAlignmentRight;
        _textField.delegate = self;
    }
    return _textField;
}

@end
