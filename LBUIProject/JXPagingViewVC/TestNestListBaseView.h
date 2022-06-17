//
//  TestNestListBaseView.h
//  JXPagerViewExample-OC
//
//  Created by jiaxin on 2018/10/26.
//  Copyright © 2018 jiaxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JXCategoryView/JXCategoryView.h>

@interface TestNestListBaseView : UIView <JXCategoryListContentViewDelegate>

@property (nonatomic, copy) void(^scrollCallback)(UIScrollView *scrollView);
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <NSString *> *dataSource;

@end

