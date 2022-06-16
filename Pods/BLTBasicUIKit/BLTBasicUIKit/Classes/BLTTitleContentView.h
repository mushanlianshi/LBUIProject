//
//  BLTTitleContentView.h
//  Baletu
//
//  Created by liu bin on 2021/2/19.
//  Copyright © 2021 Baletu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLTTitleContentView : UIView

- (void)refreshTitle:(NSString *)title content:(NSString *)content;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;


@property (nonatomic, strong) UIView *customTitleView;
@property (nonatomic, strong) UIView *customContentView;

@property (nonatomic, assign) BOOL showBottomLine;
@property (nonatomic, assign) UIEdgeInsets lineInsets;

@property (nonatomic, assign) UIStackViewDistribution distribution;

//自定义的情况下使用
@property (nonatomic, copy) void(^customTitleContentViewUIConfig) (UIStackView *stackView,UILabel *titleLab, UILabel *contentLab);

@property (nonatomic, strong) UIColor *titleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *contentColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *contentFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END
