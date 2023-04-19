//
//  BLTTextView.h
//  BLTUIKit
//
//  Created by liu bin on 2020/3/2.
//  Copyright © 2020 liu bin. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BLTTextField;

@interface BLTTextFieldView : UIView

/** textView前面的提示文案的 */
@property (nonatomic, copy) NSString *tipTitle;

/** textView的placeHolder */
@property (nonatomic, copy) NSString *placeHolder;

/** 单位的 */
@property (nonatomic, copy) NSString *unitString;

/**内容的间距 */
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/** tiptitle 和 textView的间距 */
@property (nonatomic, assign) CGFloat tipTitleSpacing;

/** @{NSForegroundColorAttributeName:BLT_HEXCOLOR(0x999999),
 NSFontAttributeName:UIFontPFFontSize(14)
 }; */
@property (nonatomic, copy) NSDictionary <NSString *, id> *placeHolderAttributes;

@property (nonatomic, copy) NSDictionary <NSString *, id> *tipTitleAttributes;

@property (nonatomic, copy) NSDictionary <NSString *, id> *unitStringAttributes;

@property (nonatomic, copy) NSDictionary <NSString *, id> *textViewAttributes;

@property (nonatomic, strong) UIColor *textViewBackgroudColor;

/** 一些富文本的处理  上面满足不了的才使用下面的方法 和上面的placeHolderAttributes等 互斥*/
@property (nonatomic, copy) NSAttributedString *tipTitleAttributeString;

@property (nonatomic, copy) NSAttributedString *unitAttributeString;

@property (nonatomic, copy) NSAttributedString *placeHolderAttributeString;

@property (nonatomic, strong) BLTTextField *textField;

@property (nonatomic, assign) UIEdgeInsets textFieldContentInsets;

@end

@interface BLTTextFieldView (Appearance)

+ (instancetype)appearance;

@end



@interface BLTTextField : UITextField

/** 内容的间距 */
@property (nonatomic, assign) UIEdgeInsets contentInsets;

@end
