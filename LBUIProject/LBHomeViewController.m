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
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <LBCombineFramewrok/LBCombineFramewrok.h>
#import <LBCombineFramewrok/LBCombineFramewrok-Swift.h>
#import "StreamTextProcessor.h"

@interface LBHomeViewController ()<UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray *dataSources;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) UIImageView *headerIV;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, strong) AVQueuePlayer *avPlayer;

@property (nonatomic, strong) UIView *menuView;

@end

@implementation LBHomeViewController

+ (void)testClassFunc{
    NSLog(@"LBLog %@ -----------", NSStringFromSelector(_cmd));
}

- (void)testInstanceFunc{
    NSLog(@"LBLog %@ -----------", NSStringFromSelector(_cmd));
}

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

- (void)testFramework{
    LBOCPerson *person = [LBOCPerson new];
    [person testName];
    [person callSwiftMethod];
    
    LBSwiftClass *swiftClass = [LBSwiftClass new];
    [swiftClass printClassName];
    
    [LBSwiftSchool printSchoolClass];
}

- (void)testSlipt{
    // 创建处理器
    StreamTextProcessor *processor = [[StreamTextProcessor alloc] init];

    // 模拟流式输入（实际使用时是一个字一个字输入）
    
    NSString *longText = @"中国银行2025年一季度财务表现深度分析#### 核心财务指标呈现\"营收微增、利润下滑\"的分化态势\
根据\"[中国银行执行董事刘进任职资格获批 该行2025年Q1净利润同比下降2%-雪球](https://xueqiu.com/2566964535/337787680)\"和\"[中国银行(601988.SH)：2025年一季报净利润为543.64亿元、同比较去年同期下降2.90%-搜狐网](https://m.sohu.com/a/890679155_223785/?pvid=000115_3w_a)\"披露的数据，中国银行在2025年第一季度呈现出营收与净利润走势分化的特征。集团实现营业收入1649.29亿元，同比增长2.56%，这一增长主要得益于非利息收入的强劲表现；但同期净利润却同比下降2.22%至586.44亿元（归母净利润543.64亿元，同比下降2.90%）。这种分化反映了当前银行业面临的特殊经营环境：一方面通过业务结构调整实现了收入增长，另一方面却受制于成本压力和税收因素导致利润收缩。\
值得注意的是，\"[业绩欠佳-中国银行2025年一季度财报点评-百家号](https://baijiahao.baidu.com/s?id=1833330688111504899)\"指出，非利息收入同比增长18.91%成为关键亮点，其中手续费及佣金收入结束了自2024年以来的连续负增长，同比增长2.09%，这可能是金融服务收费政策调整后的积极信号。但同时，净利息收入同比下降4.42%，反映出传统利差业务仍面临严峻挑战。\
    \
#### 资产负债结构呈现\"贷款扩张、存款承压\"的行业共性\
资产负债方面，中国银行在2025年第一季度展现出积极的规模扩张态势。根据雪球和百家号的数据，集团总资产达到359,871.47亿元，较上年末增长2.64%。其中贷款总额226,087.48亿元，增长4.70%，显示出在政策引导下持续加大信贷投放力度。特别值得注意的是公司贷款增长6.57%，远高于个人贷款0.72%的增速，这与\"[中国银行(601988)非息支撑营收改善 质量稳健经营|查股网](http://www.chaguwang.cn/report/601988/202505010012.html)\"中提到的\"信贷投放和金融投资依旧是企业规模增长的主要动能\"相印证，表明其业务重心正在向对公领域倾斜。\
然而，负债端面临结构性压力。虽然吸收存款总额增长5.82%至256,104.99亿元，但\"[业绩欠佳-中国银行2025年一季度财报点评-百家号](https://baijiahao.baidu.com/s?id=1833330688111504899)\"分析指出，存款同比增速(6.24%)低于贷款同比增速(8.26%)，导致银行不得不加大同业负债配置力度（同比增长8.93%）。这种存贷增速剪刀差可能持续推高资金成本，为后续净息差表现埋下隐患。\
#### 净息差持续收窄成为盈利主要拖累\
多个来源([来源1](https://baijiahao.baidu.com/s?id=1833330688111504899)、[来源2](http://www.chaguwang.cn/report/601988/202505010012.html))证实，净息差收窄是中国银行利润下滑的核心因素。2025年一季度净息差录得1.29%，同比下滑15个基点，环比下降11个基点。深度分析显示，这一结果源于资产收益率同比下降45个基点，远超负债成本率32个基点的降幅。查股网的研报特别指出，2024年LPR多次调整导致的贷款重定价是主要原因，这也解释了为何在生息资产同比增长7.2%的情况下，净利息收入仍同比下降4.42%。\
值得注意的是，东方财富网数据显示经营活动现金流净额转为-404.63亿元，同比大幅减少437.03亿元，这可能与资产端收益率下降情况下资金运用效率降低有关，进一步印证了息差收窄对整体经营质量的冲击。\
#### 资产质量保持稳定但需关注潜在风险\
资产质量方面呈现\"总体可控、隐忧初现\"的特征。根据搜狐和查股网的数据，不良贷款率维持在1.25%的水平，拨备覆盖率198%，满足监管要求且风险抵补能力充足。但细读\"[业绩欠佳-中国银行2025年一季度财报点评-百家号](https://baijiahao.baidu.com/s?id=1833330688111504899)\"可发现，拨备覆盖率较2024年末下降2.63个百分点，同时该行计提减值准备同比减少27亿元，这些迹象可能预示着资产质量边际承压。特别是考虑到贷款规模快速扩张（尤其是对公贷款增长11.23%）而经济复苏基础尚不牢固，未来不良贷款生成情况值得密切关注。\
    \
#### 管理架构调整与战略布局\
人事方面，根据雪球报道，原副行长刘进在2025年6月正式就任执行董事，并进入董事会战略发展委员会。这位具有国家开发银行工作背景的高管上任，可能预示着中国银行将强化在政策性金融、对公业务等领域的布局，这与前述贷款结构向公司贷款倾斜的趋势相互印证。这种人事安排或许是为应对当前\"对公贷款驱动增长\"的业务模式而进行的战略配套。\
#### 市场估值反映投资者谨慎预期\"[中国银行：2025年一季度净利润543.64亿元-东方财富网](https://wap.eastmoney.com/a/202505023395538898.html)\"提供的市场数据显示，截至报告期末中国银行市盈率(TTM)约7.1倍，市净率(LF)约0.59倍，显著低于行业平均水平。这种估值折价既反映了对净息差持续收窄的担忧，也包含了对资产质量可能恶化的预期。特别是0.59倍的市净率，表明市场认为其净资产收益率(一季度年化ROE约9.08%)难以持续提升。\
#### 前瞻性观察要点\
综合各渠道信息，中国银行2025年后续表现需重点关注：1）净息差能否在LPR企稳后逐步见底；2）非利息收入增长势头是否可持续；3）快速扩张的对公贷款资产质量变化；4）存款成本管控成效。这些因素将共同决定其能否在营收微增的基础上实现利润回暖，也是评估中国银行业整体复苏态势的重要窗口。";
    for (NSInteger i = 0; i < longText.length; i++) {
        NSString *character = [longText substringWithRange:NSMakeRange(i, 1)];
        [processor processCharacter:character];
    }

    // 获取最终结果
    NSArray *result = processor.resultArray;
    [result enumerateObjectsUsingBlock:^(NSString  * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"分割结果obj length: %@", @(obj.length));
    }];
    NSLog(@"分割结果: %@", result);

    // 验证是否能拼回原字符串
    NSString *reconstructed = [result componentsJoinedByString:@""];
    NSLog(@"重建后的字符串: %@", reconstructed);
    NSLog(@"是否匹配: %@", [reconstructed isEqualToString:longText] ? @"YES" : @"NO");
}

- (void)tapClicked{
    NSLog(@"LBLog tapClicked ------ ");
}

- (void)addLeftMenuAndPanGesture{
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(-250, 0, 250, self.view.bounds.size.height)];
    self.menuView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
    [self.view addSubview:self.menuView];
    UIScreenEdgePanGestureRecognizer *edgePan =
        [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgePan:)];
    edgePan.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:edgePan];
}

- (void)handleLeftEdgePan:(UIScreenEdgePanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    CGFloat offsetX = MIN(MAX(translation.x, 0), 250);  // 限制范围 0 ~ 250
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        self.menuView.frame = CGRectMake(-250 + offsetX, 0, 250, self.view.bounds.size.height);
    }
    else if (gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateCancelled) {
         
        if (offsetX > 100) { // 超过一半，打开
            [self openMenu];
        } else {             // 否则，关闭
            [self closeMenu];
        }
    }
}

- (void)openMenu {
    [self.view bringSubviewToFront:self.menuView];
    [UIView animateWithDuration:0.25 animations:^{
        self.menuView.frame = CGRectMake(0, 0, 250, self.view.bounds.size.height);
    }];
}

- (void)closeMenu {
    [UIView animateWithDuration:0.25 animations:^{
        self.menuView.frame = CGRectMake(-250, 0, 250, self.view.bounds.size.height);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addLeftMenuAndPanGesture];
    [self.view addSubview:self.headerIV];
    [self.headerIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(200);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClicked)];
    tap.cancelsTouchesInView = false;
    [self.tableView addGestureRecognizer:tap];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.top.right.equalTo(self.view);
    }];
    [self getNetworkAuth];
    [self testSemaphore];

    LBHomeViewController *vc;
    NSLog(@"LBLog vc count is %@",@(vc.count));
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        [self testSyncSerialQueue];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        [self testSyncSerialQueue];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        [self testSyncSerialQueue];
    });
    [self testInvalidJsonStr];
    [self testFramework];
    [self testSlipt];
}

- (void)testSyncSerialQueue{
    dispatch_queue_t queue = dispatch_queue_create("LBLog custom serial", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queue, ^{
        NSLog(@"LBLog current thread is %@", [NSThread currentThread]);
        sleep(12);
        NSLog(@"LBLog current thread is %@", [NSThread currentThread]);
    });
    NSLog(@"LBLog current thread is main thread --------- %@", [NSThread currentThread]);
}

- (void)playMusic{
//    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"11111" ofType:@"flac"];
//        SystemSoundID soundID;
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundPath], &soundID);
//        AudioServicesPlaySystemSound(soundID);
    
//    NSURL *url = [NSURL URLWithString:@"https://www.geektang.cn/alist/d/aliyun2/%E8%AE%B8%E5%B5%A9/%E4%B9%A6%E9%A6%99%E5%B9%B4%E5%8D%8E%20-%20%E8%AE%B8%E5%B5%A9%26%E5%AD%99%E6%B6%9B.flac?sign=a8DlMPnexmA0Vj2w4K7ZzLeNmwXbbG5w0YY9sExyGyA=:0"];
//    _avPlayer = [[AVQueuePlayer alloc] initWithURL:url];
//    [_avPlayer play];
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
    [super viewWillAppear:animated];
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
        }else if ([vcName isEqualToString:@"LBTestScrollVerticalHorizontalController2"]){
            vc = [LBTestScrollVerticalHorizontalController2 new];
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
        _tableView.rowHeight = 55;
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
            @{@"title" : @"上下左右滚动2", @"vcName" : @"LBTestScrollVerticalHorizontalController2"},
            @{@"title" : @"测试struct and class", @"vcName" : @"LBTestStructAndClassController"},
            @{@"title" : @"表格拆分器", @"vcName" : @"LBChatTableViewController"},
            @{@"title" : @"表格模拟展示", @"vcName" : @"LBDownTableWebViewController"},
            @{@"title" : @"豆包拆分表格", @"vcName" : @"HYBStreamMarkdownController"},
            @{@"title" : @"DDTextView展示表格", @"vcName" : @"LBMarkdownTableViewController"}
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

- (void)testInvalidJsonStr{
    // 示例 1: 缺少闭合括号
    NSString *brokenJSON1 = @"{\"name\":\"John\", \"age\":30, \"data\": [1, 2,";
    NSString *tt = @"{\"locale\":\"zh-CN\",\"thought\":\"用户的需求是深入研究如何在行内网文和资讯平台结合互联网搜索处理复杂问题并提供报告的服务，并了解当前市场的认可度和喜好程度。需要收集相关的市场数据、平台信息、用户反馈以及技术实现方法。\",\"plan_title\": \"行内网文与资讯平台";
    
    
    NSError *error;
    NSDictionary *parsed1 = [self fixIncompleteJSON2:tt];
    NSLog(@"修复后: %@", parsed1); // 输出: {name: "John", age: 30, data: [1, 2]}

    // 示例 2: 缺少引号
    NSString *brokenJSON2 = @"{\"name\":\"John\", \"age\":30}";
    NSString *ss = @"{\"locale\": \"zh-CN\",\"thought\":\"用户的需求是深入研究如何在行内网文和资讯平台结合互联网搜索处理复杂问题并提供报告的服务，并了解当前市场的认可度和喜好程度。需要收集相关的市场数据、平台信息、用户反馈以及技术实现方法。\",\"plan_title\":\"行内网文与资讯平台结合互联网搜索处理复杂问题的研究报告计划\",\"steps\": [{\"step_number\": 1,\"title\":\"调研行内";
    NSDictionary *parsed2 = [self fixIncompleteJSON2:ss];
    NSLog(@"修复后: %@", parsed2); // 输出: {name: "John", age: 30}

    // 示例 3: 极端不完整
    NSString *brokenJSON3 = @"{\"name\":\"Alice\", \"list\": [1, 2,";
    NSDictionary *parsed3 = [self fixIncompleteJSON2:brokenJSON3];
    NSLog(@"修复后: %@", parsed3); // 输出: {name: "Alice", list: [1, 2]}
}

- (NSDictionary *)fixIncompleteJSON2:(NSString *)incompleteJSON {
    if (!incompleteJSON.length) return nil;
    
    NSMutableString *fixedJSON = [incompleteJSON mutableCopy];
    NSMutableArray *stack = [NSMutableArray array];
    BOOL inString = NO;
    BOOL escapeNext = NO;
    
    // 1. 分析 JSON 结构，检测缺失符号
    for (NSInteger i = 0; i < incompleteJSON.length; i++) {
        unichar c = [incompleteJSON characterAtIndex:i];
        
        if (escapeNext) {
            escapeNext = NO;
            continue;
        }
        
        switch (c) {
            case '\\':
                escapeNext = YES; // 下一个字符是转义字符
                break;
            case '"':
                if (!escapeNext) {
                    inString = !inString; // 切换字符串状态
                }
                break;
            case '{':
            case '[':
                if (!inString) [stack addObject:@(c)];
                break;
            case '}':
                if (!inString) {
                    if (stack.count > 0 && [stack.lastObject isEqual:@('{')]) {
                        [stack removeLastObject];
                    }
                }
                break;
            case ']':
                if (!inString) {
                    if (stack.count > 0 && [stack.lastObject isEqual:@('[')]) {
                        [stack removeLastObject];
                    }
                }
                break;
        }
    }
    
    // 3. 补全未闭合的字符串（仅在未转义的情况下）
    if (inString && !escapeNext) {
        [fixedJSON appendString:@"\""];
    }
    
    // 2. 补全缺失符号
    while (stack.count > 0) {
        unichar lastChar = [stack.lastObject unsignedShortValue];
        [stack removeLastObject];
        
        switch (lastChar) {
            case '{':
                [fixedJSON appendString:@"}"];
                break;
            case '[':
                [fixedJSON appendString:@"]"];
                break;
        }
    }
    
    
    
    return [self dictionaryWithJsonString:fixedJSON];
}

- (NSDictionary *)fixIncompleteJSON:(NSString *)incompleteJSON {
    if (!incompleteJSON.length) return incompleteJSON;
    
    NSMutableString *fixedJSON = [incompleteJSON mutableCopy];
    NSMutableArray *stack = [NSMutableArray array];
    BOOL inString = NO;
    BOOL escapeNext = NO;
    
    // 1. 分析 JSON 结构，检测缺失符号
    for (NSInteger i = 0; i < incompleteJSON.length; i++) {
        unichar c = [incompleteJSON characterAtIndex:i];
        
        if (escapeNext) {
            escapeNext = NO;
            continue;
        }
        
        switch (c) {
            case '\\':
                escapeNext = YES;
                break;
            case '"':
                inString = !inString;
                break;
            case '{':
            case '[':
                if (!inString) [stack addObject:@(c)];
                break;
            case '}':
                if (!inString) {
                    if (stack.count > 0 && [stack.lastObject isEqual:@('{')]) {
                        [stack removeLastObject];
                    }
                }
                break;
            case ']':
                if (!inString) {
                    if (stack.count > 0 && [stack.lastObject isEqual:@('[')]) {
                        [stack removeLastObject];
                    }
                }
                break;
        }
    }
    
    // 2. 补全缺失符号
    while (stack.count > 0) {
        unichar lastChar = [stack.lastObject unsignedShortValue];
        [stack removeLastObject];
        
        switch (lastChar) {
            case '{':
                [fixedJSON appendString:@"}"];
                break;
            case '[':
                [fixedJSON appendString:@"]"];
                break;
        }
    }
    
    // 3. 补全未闭合的字符串
    if (inString) {
        [fixedJSON appendString:@"\""];
    }
    
    return [self dictionaryWithJsonString:fixedJSON];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
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
