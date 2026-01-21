//
//  LBMarkdownWebCell.h
//  LBUIProject
//
//  Created by liu bin on 2025/12/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBMarkdownWebCell : UITableViewCell

@property(nonatomic, copy) void(^heightChangedBlock)(CGFloat height);

- (void)renderMarkdownHTML:(NSString *)html;

@end

NS_ASSUME_NONNULL_END
