//
//  NotificationBarView.h
//  Baletu
//
//  Created by wangwenbo on 2020/2/19.
//  Copyright © 2020 朱 亮亮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotifcationBarStyle.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,NotificationBarViewType){
    NotificationBarViewTipNoticeType = 0,// 提示 公共 类型的(icon + 内容 + 移除按钮 滚动)
    NotificationBarViewTipNoticeHandleType,// 提示 带有操作按钮 类型的(内容+操作按钮 + 移除按钮)
    NotificationBarViewTipNoticeNewsType, // 提示 消息类型(可以查看d)
    NotificationBarViewWarningSingleType,// 警示 类型的
    NotificationBarViewWarningIllegalType,// 警示 违规类型的
    NotificationBarViewActivityContentType,// 活动 类型的(仅包含活动通知)
};
typedef void(^NotificationHandleBlock)(void);
typedef void(^NotificationRightBtnBlock)(void);
typedef void(^NotificationBarTouchBlock)(void);
typedef void(^NotificationAutoDismissBlock)(void);
@interface NotificationBarView : UIView


@property(nonatomic,copy)NotificationHandleBlock handleBlock;
@property(nonatomic,copy)NotificationRightBtnBlock rightBlock;
@property(nonatomic,copy)NotificationBarTouchBlock barTouchBlock;
@property(nonatomic,copy)NotificationAutoDismissBlock autoDismissBlock;


-(instancetype)initWithBarStyle:(NotifcationBarStyle *)barStyle;

-(instancetype)initWithAttributeShowContent:(NSMutableAttributedString *)attributeShowContent barType:(NotificationBarViewType)barType;

-(instancetype)initWithShowContent:(NSString *)showContent barType:(NotificationBarViewType)barType;
//  icon  showContent handleBtn  removeBtn
-(void)showWithIconImage:(UIImage * __nullable)iconImage showContent:(NSString *)showContent handleBtnTitle:(NSString *__nullable)handleBtnTitle removeButtonImage:(UIImage * __nullable)rightImage;
//需要使用自适应高度的时候 调用此方法 此方法会返回一个 计算出的高度 用来布局(需要传入用以约束的总宽度)
-(CGFloat)showWithIconImage:(UIImage * __nullable)iconImage showContent:(NSString *)showContent handleBtnTitle:(NSString *__nullable)handleBtnTitle removeButtonImage:(UIImage * __nullable)rightImage withTotalWidth:(CGFloat)totalWidth;
// 富文本
//  icon  showContent handleBtn  removeBtn
-(void)showWithIconImage:(UIImage * __nullable)iconImage ShowAttributeContent:(NSMutableAttributedString *)attributeContent handleBtnTitle:(NSString *__nullable)handleBtnTitle removeButtonImage:(UIImage * __nullable)rightImage;
// 需要使用自适应高度的时候 调用此方法 此方法会返回一个 计算出的高度 用来布局(需要传入用以约束的总宽度)
-(CGFloat)showWithIconImage:(UIImage * __nullable)iconImage attributeShowContent:(NSMutableAttributedString *)attributeShowContent handleBtnTitle:(NSString *__nullable)handleBtnTitle removeButtonImage:(UIImage * __nullable)rightImage withTotalWidth:(CGFloat)totalWidth;

@property (nonatomic, copy) void(^customUIAppearanceBlock)(UIView *contentView, UIView *touchView, UIButton *handleButton, UIButton *removeButton, UIImageView *iconImageView);

@end

NS_ASSUME_NONNULL_END
