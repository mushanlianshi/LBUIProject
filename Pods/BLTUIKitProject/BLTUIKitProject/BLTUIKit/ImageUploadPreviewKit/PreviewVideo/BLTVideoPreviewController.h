//
//  BLTVideoPreviewController.h
//  AliyunOSSiOS
//
//  Created by liu bin on 2020/10/30.
//

#import <UIKit/UIKit.h>



@interface BLTVideoPreviewController : UIViewController<UIAppearance>

- (instancetype)initWithVideoUrl:(NSString *)videoUrl;

@property (nonatomic, copy) void(^customSensorDataBlock) (BLTVideoPreviewController *videoVC, UIButton *backButton) UI_APPEARANCE_SELECTOR;

@end

