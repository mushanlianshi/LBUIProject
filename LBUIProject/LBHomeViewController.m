//
//  ViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/5/27.
//

#import "LBHomeViewController.h"
#import "LBSafirController.h"
#import <BLTUIKitProject/BLTUI.h>
#import "LBUIProject-Swift.h"
#import "Masonry.h"
#import <YYKit/YYKit.h>
#import <CoreTelephony/CTCellularData.h>
#import <CoreLocation/CoreLocation.h>
#import "BLTAPMFPSManager.h"
#import <IJKMediaFramework/IJKMediaFramework.h>

@interface LBHomeViewController ()<UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray *dataSources;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) UIImageView *headerIV;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation LBHomeViewController

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.headerIV];
    [self.headerIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(200);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.mas_offset(-60);
    }];
    [self getNetworkAuth];
    [self testSemaphore];
}

- (void)getNetworkAuth{
    CTCellularData *cellularData = [[CTCellularData alloc]init];
    
//    CTCellularDataRestrictedState state = cellularData.restrictedState;
//    NSLog(@"LBLog state is %@",@(state));
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state){
    //状态改变时进行相关操作
        NSLog(@"LBLog state update %@", @(state));
    };
    
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"LBLog viewwillappear  before ==========");
    [super viewWillAppear:animated];
    NSLog(@"LBLog viewwillappear  after ==========");
}

//访问野指针是没有问题的   使用的时候会crash
- (void)testYezhizhen{
//    __unsafe_unretained UIView *testView = [[UIView alloc] init];
//    NSLog(@"LBLog testView 指针指向的的地址 %p, 指针本身的地址 %p", testView, &testView);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"LBLog testView 指针指向的的地址 %@, 指针本身的地址 %p", testView, &testView);
//    });
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
//    self.tableView.frame = self.view.bounds;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSources.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    LBCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    if (!cell) {
        cell = [[LBCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    NSDictionary *dic = self.dataSources[indexPath.row];
    cell.textLabel.text = dic[@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dataSources[indexPath.row];
    if ([dic[@"vcName"] isEqualToString:@"LBSafirController"]) {
        LBSafirController *vc = [[LBSafirController alloc] initWithURL:[NSURL URLWithString:@"http://cdn.baletoo.cn/Uploads/protocol_file/0/yDxZyUEHzsCUy0fKyKy4NsSRk6W9KvsR/yDxZyUEHzsCUy0fKyKy4NsSRk6W9KvsR.pdf"]];
        [self presentViewController:vc animated:YES completion:nil];
//        [self.navigationController pushViewController:vc animated:YES];
    }else{
        UIViewController *vc = [[NSClassFromString(dic[@"vcName"]) alloc] init];
        NSString *vcName = dic[@"vcName"];
        if ([vcName isEqualToString:@"LBTestTableViewSelectViewController"]) {
            vc = [[LBTestTableViewSelectViewController alloc] init];
        }else if([vcName isEqualToString:@"LLDoubleScrollViewPinController"]){
            vc = [[LLDoubleScrollViewPinController1 alloc] init];
        }else if ([vcName isEqualToString:@"LBNavigatorAlphaChangeController"]){
            vc = [[LBNavigatorAlphaChangeController alloc] init];
        }else if ([vcName isEqualToString:@"LBNavigatorScrollHiddenController"]){
            vc = [[LBNavigatorScrollHiddenController alloc] init];
        }else if ([vcName isEqualToString:@"LBDragDownNextPageViewController"]){
            vc = [[LBDragDownNextPageViewController alloc] init];
        }else if ([vcName isEqualToString:@"LBSkeletonViewController"]){
            vc = [[LBSkeletonViewController alloc] init];
        }else if ([vcName isEqualToString:@"LLTransitionAnimationController"]){
            vc = [[LLTransitionAnimationController alloc] init];
        }else if ([vcName isEqualToString:@"LBThirdPartAnimationController"]){
            vc = [[LBThirdPartAnimationController alloc] init];
        }else if ([vcName isEqualToString:@"LBCustomPageViewController"]){
            vc = [[LBCustomPageViewController alloc] init];
        }else if ([vcName isEqualToString:@"LBWatchDogController"]){
            vc = [[LBWatchDogController alloc] init];
        }else if ([vcName isEqualToString:@"LBGrayViewController"]){
            vc = [[LBGrayViewController alloc] init];
        }else if ([vcName isEqualToString:@"LBTestCacheViewController"]){
            vc = [LBTestCacheViewController new];
        }else if ([vcName isEqualToString:@"LBRxSwiftViewController"]){
            vc = [LBRxSwiftViewController new];
        }else if ([vcName isEqualToString:@"LBTestHitViewController"]){
            vc = [LBTestHitViewController new];
        }else if ([vcName isEqualToString:@"LBTestScrollVerticalHorizontalController"]){
            vc = [LBTestScrollVerticalHorizontalController new];
        }else if ([vcName isEqualToString:@"LBTestStructAndClassController"]){
            vc = [LBTestStructAndClassController new];
        }
        vc.view.backgroundColor = [UIColor whiteColor];
        vc.navigationItem.title = dic[@"title"];
//        [self.navigationController pushViewController:[UIViewController new] animated:NO];
//        [self.navigationController pushViewController:vc animated:YES];
//        [self.navigationController pushViewController:[UIViewController new] animated:YES];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    NSLog(@"LBLog cellheight %@",@(cell.bounds.size.height));
//}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 60;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.contentInset = UIEdgeInsetsMake(200, 0, 0, 0);
        _tableView.contentOffset = CGPointMake(0, -200);
        if (@available(iOS 15.0, *)) {
            _tableView.prefetchingEnabled = true;
        } else {
            // Fallback on earlier versions
        }
        [_tableView registerClass:[LBCustomTableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (NSArray *)dataSources{
    if (!_dataSources) {
        _dataSources = @[
            @{@"title" : @"UIStackView",@"vcName":@"LBTestStackViewViewController"},
            @{@"title" : @"autoLayout",@"vcName":@"LBTestAutoLayoutViewController"},
            @{@"title" : @"gesture",@"vcName":@"LBTestGestureViewController"},
            @{@"title" : @"离屏渲染",@"vcName":@"LBTestOffScreenController"},
            @{@"title" : @"plain没有悬停效果处理",@"vcName":@"LBTableViewNoStickyStyleController"},
            @{@"title" : @"圆角、阴影、mask效果",@"vcName":@"LBShadowRaduisViewController"},
            @{@"title" : @"人脸检测", @"vcName" : @"LBTestFaceAwareController"},
            @{@"title" : @"safir浏览器", @"vcName" : @"LBSafirController"},
            @{@"title" : @"实例对象缓存方法", @"vcName" : @"LBTestClassCacheMethodViewController"},
            @{@"title" : @"调试LLDB", @"vcName" : @"LBTestLLDBViewController"},
            @{@"title" : @"分段式滑动", @"vcName" : @"LBSegemtnScrollViewController"},
            @{@"title" : @"识别图中文字", @"vcName" : @"LBTextRecogineViewController"},
            @{@"title" : @"识别图中物品", @"vcName" : @"LBImageRecogineViewController"},
            @{@"title" : @"多线程", @"vcName" : @"LBGCDViewController"},
            @{@"title" : @"拉伸图片", @"vcName" : @"LBStretchImageViewController"},
            @{@"title" : @"anchorPoint时钟动画", @"vcName" : @"LBClockViewController"},
            @{@"title" : @"AffineTransform变换", @"vcName" : @"LBAffineTransformController"},
            @{@"title" : @"动画", @"vcName" : @"LBAnimationViewController"},
            @{@"title" : @"block", @"vcName" : @"LBBlockViewController"},
            @{@"title" : @"KVO", @"vcName" : @"LBKVOViewController"},
            @{@"title" : @"loadAndInitialize", @"vcName" : @"LBLoadAndInitializeSubClassController"},
            @{@"title" : @"KVC", @"vcName" : @"LBKVCController"},
            @{@"title" : @"图片内存测试", @"vcName" : @"_TtC11LBUIProject23LBImageMemoryController"},
            @{@"title" : @"AvoidCrash", @"vcName" : @"LBTestAvoidCrashViewController"},
            @{@"title" : @"策略模式代替if-else", @"vcName" : @"LBStrategyModeController"},
            @{@"title" : @"链式调用", @"vcName" : @"LBTestChainViewController"},
            @{@"title" : @"runloop切换model避免崩溃", @"vcName" : @"LBTestRunloopViewController"},
            @{@"title" : @"消息转发", @"vcName" : @"LBTestUnrecognizeSelectorViewController"},
            @{@"title" : @"cell选中", @"vcName" : @"LBTestTableViewSelectViewController"},
            @{@"title" : @"scrollView嵌套吸顶的", @"vcName" : @"LLDoubleScrollViewPinController"},
            @{@"title" : @"collectionView装饰视图", @"vcName" : @"LBCollectionDecoratoViewController"},
            @{@"title" : @"pageViewController", @"vcName" : @"PagingNestCategoryViewController"},
            @{@"title" : @"按钮防止多次点击的", @"vcName" : @"LBPreventRepeatTouchUpInsideController"},
            @{@"title" : @"导航栏渐变色", @"vcName" : @"LBNavigatorAlphaChangeController"},
            @{@"title" : @"滚动隐藏导航栏", @"vcName" : @"LBNavigatorScrollHiddenController"},
            @{@"title" : @"多代理", @"vcName" : @"LBMultipleDelegatesController"},
            @{@"title" : @"下拉翻页的", @"vcName" : @"LBDragDownNextPageViewController"},
            @{@"title" : @"骨架屏", @"vcName" : @"LBSkeletonViewController"},
            @{@"title" : @"转场动画", @"vcName" : @"LLTransitionAnimationController"},
            @{@"title" : @"动画", @"vcName" : @"LBThirdPartAnimationController"},
            @{@"title" : @"轮播图", @"vcName" : @"LBCustomPageViewController"},
            @{@"title" : @"检测卡顿", @"vcName" : @"LBWatchDogController"},
            @{@"title" : @"页面或则控件置灰", @"vcName" : @"LBGrayViewController"},
            @{@"title" : @"测试NSCache", @"vcName" : @"LBTestCacheViewController"},
            @{@"title" : @"测试RxSwift", @"vcName" : @"LBRxSwiftViewController"},
            @{@"title" : @"测试响应链", @"vcName" : @"LBTestHitViewController"},
            @{@"title" : @"上下左右滚动", @"vcName" : @"LBTestScrollVerticalHorizontalController"},
            @{@"title" : @"测试struct and class", @"vcName" : @"LBTestStructAndClassController"},
        ];
    }
    return _dataSources;
}


- (BOOL)prefersHomeIndicatorAutoHidden{
    return YES;
}

- (UIImageView *)headerIV{
    if (!_headerIV) {
        _headerIV = [[UIImageView alloc] init];
        _headerIV.image = UIImageNamed(@"pageView1");
        _headerIV.contentMode = UIViewContentModeScaleAspectFill;
        _headerIV.clipsToBounds = true;
    }
    return _headerIV;
}

- (void)testSemaphore{
//    [[BLTAPMFPSManager sharedInstance] startObserverFPSCallBack:^(NSDictionary * _Nonnull resultInfo) {
//
//    }];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[BLTAPMFPSManager sharedInstance] endObserver];
//    });
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        _semaphore = dispatch_semaphore_create(1);
//        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
//        NSLog(@"LBLog semaphore count > 0");
//    });
//
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        dispatch_semaphore_signal(_semaphore);
//    });
    
}

@end





@implementation LGPerson


@end




@interface LBCustomTableViewCell ()<CAAnimationDelegate>

@end


@implementation LBCustomTableViewCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
//    NSLog(@"LBLog cell hight %@",@(highlighted));
//    if (highlighted) {
        if ([self.contentView.layer animationForKey:@"animation"]) {
            return;
        }
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration = 0.2;
        animation.delegate = self;
        animation.values = @[@(0.98),@(1.02)];
        [self.contentView.layer addAnimation:animation forKey:@"animation"];
//    }else{
//        [self.contentView.layer removeAnimationForKey:@"animation"];
//    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
//    NSLog(@"LBLog animation %@",[self.contentView.layer animationForKey:@"animation"]);
}

@end
