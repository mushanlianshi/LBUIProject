//
//  LLCustomImageTitleButton.h
//  Baletoo_landlord
//
//  Created by liu bin on 2019/5/14.
//  Copyright © 2019 com.wanjian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLTUIResponseAreaButton.h"

NS_ASSUME_NONNULL_BEGIN


/** 按钮的位置 */
typedef NS_ENUM(NSInteger, BLTCustomButtonImagePosition){
    BLTCustomButtonImagePositionDefault = 0,
    BLTCustomButtonImagePositionLeft = 1,
    BLTCustomButtonImagePositionTop,
    BLTCustomButtonImagePositionRight,
    BLTCustomButtonImagePositionBottom
};

/**
 * 自定义图片  文字的按钮
 */
@interface BLTCustomImageTitleButton : BLTUIResponseAreaButton

//文字在按钮中的位置
@property (nonatomic,assign) CGRect titleRect;
//图片在按钮中的位置
@property (nonatomic,assign) CGRect imageRect;

/** 目前只考虑contentHorizontalAlignment 和竖直方向都是默认的  center等暂时不考虑 */
@property (nonatomic, assign) BLTCustomButtonImagePosition imagePosition;
/** 图片和文字的内间距  配合imagePosition 一起使用的 */
@property (nonatomic, assign) CGFloat imageTitleInnerMargin;

@end

NS_ASSUME_NONNULL_END
