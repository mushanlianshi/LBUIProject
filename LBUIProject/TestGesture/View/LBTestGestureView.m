//
//  LBTestGestureView.m
//  LBUIProject
//
//  Created by liu bin on 2021/7/19.
//

#import "LBTestGestureView.h"
#import "Masonry.h"

@interface LBTestGestureView ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *testButton;

@property (nonatomic, strong) LBTestGestureTableView *tableView;

@property (nonatomic, copy) NSArray *dataSources;

@end

@implementation LBTestGestureView



- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
     
        [self addSubview:self.testButton];
        [self addSubview:self.tableView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClicked)];
        //1.默认父view添加了gesture  tableview的cell点击事件就不走了  第一种设置cancelsTouchesInView = false；这样手势识别后不会取消touch事件传递  tableviewcell的点击事件就走了，但这相当于父控件的点击事件也触发了，如果不需要刻意设置gesture delegate  - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch 如果点击在tableview内返回false  不识别手势 不在tableview内才会识别
//       2.对于子控件是button的点击事件   UIControl的点击事件优先级默认比手势高，会优先触发button的点击事件 不触发手势识别
//        tapGesture.cancelsTouchesInView = false;
//        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        [self.testButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(100);
            make.top.mas_offset(30);
            make.centerX.mas_equalTo(self);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.testButton.mas_bottom).mas_offset(30);
            make.left.right.bottom.mas_equalTo(self);
        }];
    }
    return self;
}


- (void)tapGestureClicked{
    NSLog(@"LBLog tapGestureClicked ========= hahha");
}

- (void)buttonClicked{
    NSLog(@"LBlog tableview clicked =======");
}


#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",self.dataSources[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"LBLog tableview didSelectRowAtIndexPath %@",indexPath);
}


#pragma mark - gesture delegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    //    如果点击的view是collectionview的子视图  则不响应手势  这样collectionview的点击事件就走了
//    if ([touch.view isDescendantOfView:self.tableView]) {
//        return NO;
//    }
//    return YES;
//}

#pragma mark - touch event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"LBLog gesture touchesBegan ======");
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"LBLog gesture touchesEnded ======");
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"LBLog gesture touchesMoved ======");
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"LBLog gesture touchesCancelled ======");
    [super touchesCancelled:touches withEvent:event];
}

- (UIButton *)testButton{
    if (!_testButton) {
        _testButton = [[UIButton alloc] init];
        [_testButton setTitle:@"click" forState:UIControlStateNormal];
        _testButton.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        [_testButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _testButton;
}


- (LBTestGestureTableView *)tableView{
    if (!_tableView) {
        _tableView = [[LBTestGestureTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSArray *)dataSources{
    if (!_dataSources) {
        NSMutableArray *tmpArray = @[].mutableCopy;
        for (int i = 0; i < 100; i++) {
            [tmpArray addObject:@(i)];
        }
        _dataSources = tmpArray.copy;
    }
    return _dataSources;
}

@end






@implementation LBTestGestureTableView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"LBLog LBTestGestureTableView touchesBegan ======");
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"LBLog LBTestGestureTableView touchesEnded ======");
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"LBLog LBTestGestureTableView touchesMoved ======");
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"LBLog LBTestGestureTableView touchesCancelled ======");
    [super touchesCancelled:touches withEvent:event];
}


@end
