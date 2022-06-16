//
//  BLTAlertAction.h
//  BLTUIKit
//
//  Created by liu bin on 2020/3/2.
//  Copyright © 2020 liu bin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
/** 和系统的样式保持一致 目前UI只有两种样式  */
typedef NS_ENUM(NSInteger, BLTAlertActionStyle){
    BLTAlertActionStyleDefault = 0,
    BLTAlertActionStyleCancel,
    BLTAlertActionStyleDestructive,     //对alert样式 是红色标题的   对feedAlert样式的弹框是渐变式的样式的
};

@class BLTAlertAction;
@protocol BLTAlertActionDelegate <NSObject>

- (void)alertActionDidClicked:(BLTAlertAction *)alertAction;

@end

@interface BLTAlertAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title style:(BLTAlertActionStyle)style handler:(void(^) (BLTAlertAction *action))handler;

@property (nullable, nonatomic, readonly) NSString *title;

@property (nonatomic, assign, readonly) BLTAlertActionStyle style;

@property (nonatomic, strong) UIButton *actionButton;

@property (nonatomic, copy) void(^handler)(BLTAlertAction *action);

@property (nonatomic, weak) id<BLTAlertActionDelegate> delegate;

@end


NS_ASSUME_NONNULL_END
