//
//  ViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/5/27.
//

#import "ViewController.h"
#import "LBSafirController.h"
#import <BLTUIKitProject/BLTUI.h>
#import "LBUIProject-Swift.h"
#import "Masonry.h"
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray *dataSources;

@property (nonatomic, copy) NSString *name;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.mas_offset(-60);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UILabel *label = [[UILabel alloc] init];
        label.text = @"我念佛号玩覅和我划分为哈佛完返回我粉红晚饭后我饿哈佛我和佛号万佛湖万佛湖围殴回复沃尔夫后违法和我后方我发";
        label.numberOfLines = 0;
//        CGSize size = [label sizeThatFits:CGSizeMake(self.view.bounds.size.width, CGFLOAT_MAX)];
//        label.frame = CGRectMake(0, 0, size.width, size.height);
    //        [label systemLayoutSizeFittingSize:[UIView layoutFittingCompressedSize]]
        _tableView.tableHeaderView = label;
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(_tableView);
                make.left.right.equalTo(self.view);
    //            make.top.equalTo(self.view);
        }];
        NSLog(@"LBlog label before %@",@(label.frame));
        [label layoutIfNeeded];
        [_tableView reloadData];
        NSLog(@"LBlog label after %@",@(label.frame));
//        _tableView.tableHeaderView = label;
    });
    [self testYezhizhen];
//    NSString *string = @"**波)";
//    NSRange range = [string rangeOfString:@"^\\**[\u4E00-\u9FA5A-Za-z0-9_]\\)$" options:NSRegularExpressionSearch range:NSMakeRange(0, string.length) locale:nil];
//    NSLog(@"LBlog range %zd   %zd ",range.location, range.length);
//    NSLog(@"LBLog --- %@",[string substringWithRange:range]);
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self testStaticView:0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self testStaticView:2];
        });
    });
    

    
    dispatch_queue_t queue0 = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        blt_dispatch_main_sync_safe(^{
            NSLog(@"LBLog sync global thread 1111 %@",[NSThread currentThread]);
        });
//        并发队列  同步是可以开启新线程的
        dispatch_sync(queue0, ^{
            NSLog(@"LBLog sync global thread 00000 %@",[NSThread currentThread]);
        });
    });
    
    dispatch_queue_t queue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        NSLog(@"LBLog sync queue thread 2222 %@",[NSThread currentThread]);
        //虽然不会开启新线程  但可以执行   因为main_queue的主线程已经开启
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"LBLog sync queue thread 3333 %@",[NSThread currentThread]);
        });
        //串行队列 同步不会开启新线程  还是queue的线程
        dispatch_sync(queue2, ^{
            NSLog(@"LBLog sync queue thread 4444 %@",[NSThread currentThread]);
        });
        NSLog(@"LBLog sync queue thread 5555 %@",[NSThread currentThread]);
    });
    [self testMemberKindOfClass];
    
//    atomic会保证 set和get的原子性   不会crash
    NSLog(@"LBLog atomic ====================");
    for (int i = 0; i < 10000; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            self.name = [NSString stringWithFormat:@"的问候王宏伟和符合我饿后文化%d",i];
//            如果复制的是常量区的或则tagpointer类型的  也不会crash  不需要release旧值  retain新值
//            self.name = @"1";
            self.name = [NSString stringWithFormat:@"1%d",i];
        });
    }
}


- (void)testMemberKindOfClass{
    BOOL re1 = [(id)[NSObject class] isKindOfClass:[NSObject class]];
    BOOL re2 = [(id)[NSObject class] isMemberOfClass:[NSObject class]];
    BOOL re3 = [(id)[LGPerson class] isKindOfClass:[LGPerson class]];
    BOOL re4 = [(id)[LGPerson class] isMemberOfClass:[LGPerson class]];
    NSLog(@" re1 :%hhd\n re2 :%hhd\n re3 :%hhd\n re4 :%hhd\n",re1,re2,re3,re4);

    BOOL re5 = [(id)[NSObject alloc] isKindOfClass:[NSObject class]];
    BOOL re6 = [(id)[NSObject alloc] isMemberOfClass:[NSObject class]];
    BOOL re7 = [(id)[LGPerson alloc] isKindOfClass:[LGPerson class]];
    BOOL re8 = [(id)[LGPerson alloc] isMemberOfClass:[LGPerson class]];
    NSLog(@" re5 :%hhd\n re6 :%hhd\n re7 :%hhd\n re8 :%hhd\n",re5,re6,re7,re8);

}

static int  staticNum1;

- (void)testStaticView:(NSInteger)index{
    static int staticNum2;
    static UIView *view = nil;
    if (index == 0) {
        view = [[UIView alloc] init];
        staticNum1 = 1;
        staticNum2 = 1;
    }else{
        view = [[UIButton alloc] init];
        staticNum1 = 2;
        staticNum2 = 2;
    }
//    NSLog(@"LBLog view is %@ %d %d",view,staticNum1, staticNum2);
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
        if ([dic[@"vcName"] isEqualToString:@"LBTestTableViewSelectViewController"]) {
            vc = [[LBTestTableViewSelectViewController alloc] init];
        }else if([dic[@"vcName"] isEqualToString:@"LLDoubleScrollViewPinController"]){
            vc = [[LLDoubleScrollViewPinController1 alloc] init];
        }else if ([dic[@"vcName"] isEqualToString:@"LBNavigatorAlphaChangeController"]){
            vc = [[LBNavigatorAlphaChangeController alloc] init];
        }else if ([dic[@"vcName"] isEqualToString:@"LBNavigatorScrollHiddenController"]){
            vc = [[LBNavigatorScrollHiddenController alloc] init];
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    NSLog(@"LBLog cellheight %@",@(cell.bounds.size.height));
//}


- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 60;
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
        ];
    }
    return _dataSources;
}


- (BOOL)prefersHomeIndicatorAutoHidden{
    return YES;
}

@end





@implementation LGPerson


@end




@interface LBCustomTableViewCell ()<CAAnimationDelegate>

@end


@implementation LBCustomTableViewCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    NSLog(@"LBLog cell hight %@",@(highlighted));
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
    NSLog(@"LBLog animation %@",[self.contentView.layer animationForKey:@"animation"]);
}

@end
