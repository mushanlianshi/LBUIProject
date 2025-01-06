//
//  BLTImagePreviewNaviBar.h
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/27.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLTImagePreviewNaviBar;
@protocol BLTImagePreviewNaviBarDelegate <NSObject>

@optional
- (void)navibarDidClickBack:(BLTImagePreviewNaviBar *)naviBar;

- (void)navibarDidClickDelete:(BLTImagePreviewNaviBar *)navibar;

@end

@interface BLTImagePreviewNaviBar : UIView

@property (nonatomic, strong) UIImage *backImage;

//默认为YES
@property (nonatomic, weak)id <BLTImagePreviewNaviBarDelegate> delegate;

@property (nonatomic, copy) dispatch_block_t backBlock;

- (void)refreshNaviBarUIConfig:(void(^)(UIButton *deleteButton, UILabel *titleLab, UIButton *backButton))config;

@end


