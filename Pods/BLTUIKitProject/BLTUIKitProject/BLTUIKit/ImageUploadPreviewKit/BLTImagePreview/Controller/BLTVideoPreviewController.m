//
//  BLTVideoPreviewController.m
//  AliyunOSSiOS
//
//  Created by liu bin on 2020/10/30.
//

#import "BLTVideoPreviewController.h"
#import "TZPhotoPreviewCell.h"
#import "TZAssetModel.h"
#import "UIView+TZLayout.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import <AVFoundation/AVFoundation.h>
#import "BLTUICommonDefines.h"

@interface BLTVideoPreviewController (){
    UIView *_naviBar;
    UIButton *_backButton;
}

@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, strong) TZVideoPreviewCell *previewVideoView;
@property (nonatomic, assign) BOOL isHideNaviBar;

@end

@implementation BLTVideoPreviewController

static BLTVideoPreviewController *previewVideoInstance;
+ (instancetype)appearance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        previewVideoInstance = [[BLTVideoPreviewController alloc] init];
    });
    return  previewVideoInstance;
}


- (instancetype)initWithVideoUrl:(NSString *)videoUrl{
    self = [super init];
    if (self) {
        self.videoUrl = videoUrl;
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize{
    self.customSensorDataBlock = previewVideoInstance.customSensorDataBlock;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _previewVideoView = [[TZVideoPreviewCell alloc] init];
    if ([self.videoUrl hasPrefix:@"http"]) {
        _previewVideoView.videoURL = [NSURL URLWithString:self.videoUrl];
    }else{
        _previewVideoView.videoURL = [NSURL fileURLWithPath:self.videoUrl];
    }
    BLT_WS(weakSelf);
    [_previewVideoView setSingleTapGestureBlock:^{
        [weakSelf didTapPreviewCell];
    }];
    [self.view addSubview:_previewVideoView];
    _naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BLT_DEF_SCREEN_WIDTH, BLT_SCREEN_NAVI_HEIGHT)];
    _naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:0.7];
    NSLog(@"LBlog is phonex %@ %@", @(BLT_IS_IPHONEX), @(BLT_SCREEN_NAVI_HEIGHT));
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, BLT_SCREEN_TOP_OFFSET, 44, 44)];
    [_backButton setImage:[UIImage tz_imageNamedFromMyBundle:@"navi_back"] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_naviBar];
    [_naviBar addSubview:_backButton];
    
    if (self.customSensorDataBlock) {
        self.customSensorDataBlock(self, _backButton);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.previewVideoView.frame = self.view.bounds;
}


- (void)backButtonClick {
    if (self.navigationController) {
        if (self.navigationController.childViewControllers.count < 2) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didTapPreviewCell {
    self.isHideNaviBar = !self.isHideNaviBar;
    _naviBar.hidden = self.isHideNaviBar;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
