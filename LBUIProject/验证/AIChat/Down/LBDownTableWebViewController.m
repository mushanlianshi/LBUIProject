//
//  LBDownTableWebViewController.m
//  LBUIProject
//
//  Created by liu bin on 2025/12/19.
//

#import "LBDownTableWebViewController.h"
#import "LBUIProject-Swift.h"
#import "LBMarkdownWebCell.h"

@interface LBDownTableWebViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIButton *sendButton;

// 数据源
@property (nonatomic, strong) NSMutableArray<NSString *> *htmlList;

// 高度缓存
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, NSNumber *> *heightCache;

// 模拟流式
@property (nonatomic, strong) NSTimer *streamTimer;
@property (nonatomic, assign) NSInteger streamIndex;
@property (nonatomic, strong) NSMutableString *streamBuffer;

@property( nonatomic, copy) NSString *fullStreamHTML;

@end

@implementation LBDownTableWebViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;

    self.htmlList = @[].mutableCopy;
    self.heightCache = @{}.mutableCopy;

    [self setupTableView];
    [self setupInputBar];
}

#pragma mark - UI

- (void)setupTableView {

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

    [self.tableView registerClass:LBMarkdownWebCell.class
           forCellReuseIdentifier:@"MarkdownWebCell"];

    [self.view addSubview:self.tableView];

    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    ]];
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(onTableTap)];
    tap.cancelsTouchesInView = NO; // 非常重要！

    [self.tableView addGestureRecognizer:tap];
}

- (void)onTableTap {
    [self.view endEditing:YES];
}

- (void)setupInputBar {

    UIView *bar = [[UIView alloc] init];
    bar.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];

    [self.view addSubview:bar];

    bar.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [bar.topAnchor constraintEqualToAnchor:self.tableView.bottomAnchor],
        [bar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [bar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [bar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [bar.heightAnchor constraintEqualToConstant:50]
    ]];

    self.inputField = [[UITextField alloc] init];
    self.inputField.placeholder = @"输入内容...";
    self.inputField.borderStyle = UITextBorderStyleRoundedRect;
    self.inputField.delegate = self;
    self.inputField.returnKeyType = UIReturnKeySend;

    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton addTarget:self
                        action:@selector(onSend)
              forControlEvents:UIControlEventTouchUpInside];

    [bar addSubview:self.inputField];
    [bar addSubview:self.sendButton];

    self.inputField.translatesAutoresizingMaskIntoConstraints = NO;
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [self.inputField.leadingAnchor constraintEqualToAnchor:bar.leadingAnchor constant:12],
        [self.inputField.centerYAnchor constraintEqualToAnchor:bar.centerYAnchor],
        [self.inputField.trailingAnchor constraintEqualToAnchor:self.sendButton.leadingAnchor constant:-8],
        [self.inputField.heightAnchor constraintEqualToConstant:34],

        [self.sendButton.trailingAnchor constraintEqualToAnchor:bar.trailingAnchor constant:-12],
        [self.sendButton.centerYAnchor constraintEqualToAnchor:bar.centerYAnchor],
        [self.sendButton.widthAnchor constraintEqualToConstant:60]
    ]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    if (textField.text.length > 0) {
        [self onSend];
    }
    // 不要默认换行
    return NO;
}

#pragma mark - Send Action

- (void)onSend {
    [self.view endEditing:YES];
    if (self.inputField.text.length == 0) return;

    // 用户输入直接展示
    NSString *userHTML =
    [NSString stringWithFormat:@"<p><b>用户：</b>%@</p>", self.inputField.text];

    [self appendHTML:userHTML];

    self.inputField.text = @"";

    // 模拟 AI 流式返回
    [self startMockStream];
}

#pragma mark - Stream Simulation

- (void)startMockStream{
    
    [self.streamTimer invalidate];
    self.streamTimer = nil;

    self.streamIndex = 0;
    self.streamBuffer = @"".mutableCopy;

    // ✅ 一次性准备完整内容
    self.fullStreamHTML =
    @"正在为你整理本次出差审批信息，请稍候 正在为你整理本次出差审批信息，请稍正在为你整理本次出差审批信息，请稍正在为你整理本次出差审批信息，请稍…\n\n"
    @"以下是当前填写的出差审批内容汇总以下是当前填写的出差审批内容汇以下是当前填写的出差审批内容汇以下是当前填写的出差审批内容汇：\n\n"
    @"| 📌 项目 | 📝 内容 | 🎚️ 状态/选择 |\n"
    @"|------|------|------|\n"
    @"| 🏢 出差审批 | 2025年GIAC峰会集中办公 | 🔵 已批准 ⚪ 驳回 |\n"
    @"| 🚆 交通工具 | 火车（二等座） | 🔘 飞机 🔘 高铁 🔴 火车 |\n"
    @"| 🔁 是否多次往返 | 北京⇄上海 | ✅ 是 ❎ 否 |\n"
    @"| ⚠️ 特殊事项 | 无 | 📌 下拉选项 |\n"
    @"| 📎 附件上传 | 通知邮件.jpg | 🖱️ 点击上传 |\n\n"
    @"请确认以上信息是否准确以下是当前填写的出差审批内容汇以下是当前填写的出差审批内容汇以下是当前填写的出差审批内容汇。\n\n"
    @"以上信息请核对无误后提交。";

    // 插入一个空 cell（AI 消息）
    [self.htmlList addObject:@""];
    NSInteger row = self.htmlList.count - 1;

    [self.tableView insertRowsAtIndexPaths:@[
        [NSIndexPath indexPathForRow:row inSection:0]
    ] withRowAnimation:UITableViewRowAnimationFade];

    self.streamTimer =
    [NSTimer scheduledTimerWithTimeInterval:0.05   // ⭐ 30ms 一个字
                                     target:self
                                   selector:@selector(onStreamTick)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)onStreamTick {
    
    if (self.streamIndex >= self.fullStreamHTML.length) {
        [self.streamTimer invalidate];
        self.streamTimer = nil;
        return;
    }

    // ⚠️ 按字符取（支持中文）
    unichar c = [self.fullStreamHTML characterAtIndex:self.streamIndex];
    [self.streamBuffer appendFormat:@"%C", c];
    self.streamIndex += 1;

    NSInteger lastRow = self.htmlList.count - 1;
    self.htmlList[lastRow] = self.streamBuffer.copy;

    NSIndexPath *indexPath =
    [NSIndexPath indexPathForRow:lastRow inSection:0];
    LBMarkdownWebCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    __weak __typeof(self)weakSelf = self;
    cell.heightChangedBlock = ^(CGFloat height) {
        NSLog(@"LBLog heightChangedBlock %@", @(height));
        weakSelf.heightCache[indexPath] = @(height);
        CGFloat lastHeight = [weakSelf.heightCache[indexPath] doubleValue];
//        if (ceil(lastHeight) == ceil(height)) {
//            return;
//        }
        [UIView setAnimationsEnabled:NO];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [UIView setAnimationsEnabled:YES];
        [self scrollToBottom];
    };
    [cell renderMarkdownHTML:self.htmlList[lastRow]];

    // 只刷新最后一行，不要动画
//    [UIView performWithoutAnimation:^{
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
//                              withRowAnimation:UITableViewRowAnimationNone];
//    }];
//
//    // 始终滚到底
//    [self.tableView scrollToRowAtIndexPath:indexPath
//                          atScrollPosition:UITableViewScrollPositionBottom
//                                  animated:NO];
}

#pragma mark - Helpers

- (void)scrollToBottom{
    NSInteger lastRow = self.htmlList.count - 1;
    NSIndexPath *indexPath =
    [NSIndexPath indexPathForRow:lastRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
}

- (void)appendHTML:(NSString *)html {

    [self.htmlList addObject:html];

    NSInteger row = self.htmlList.count - 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];

    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];

    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.htmlList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    LBMarkdownWebCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"MarkdownWebCell"
                                    forIndexPath:indexPath];

    NSString *html = self.htmlList[indexPath.row];

    __weak typeof(self) weakSelf = self;
    cell.heightChangedBlock = ^(CGFloat height) {
        
    };

    [cell renderMarkdownHTML:html];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSNumber *h = self.heightCache[indexPath];
    return h ? h.floatValue : 44;
}

@end
