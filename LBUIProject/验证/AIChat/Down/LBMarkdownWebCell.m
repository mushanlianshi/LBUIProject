#import "LBMarkdownWebCell.h"
#import <WebKit/WebKit.h>
#import "Masonry.h"

@interface LBMarkdownWebCell () <WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) CGFloat lastHeight;

@end

@implementation LBMarkdownWebCell

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupWebView];
    }
    return self;
}

- (void)setupWebView {

    WKUserContentController *ucc = [[WKUserContentController alloc] init];
    [ucc addScriptMessageHandler:self name:@"heightChanged"];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = ucc;

    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero
                                      configuration:config];
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.opaque = NO;
    self.webView.backgroundColor = UIColor.clearColor;

    [self.contentView addSubview:self.webView];

    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
        make.height.mas_equalTo(10);
    }];
}

#pragma mark - Render

- (void)renderMarkdownHTML:(NSString *)html {

//    self.lastHeight = 0;
//    NSLog(@"LBLog html is %@",html);
    NSString *wrapHTML = [NSString stringWithFormat:
    @"<html>"
     "<head>"
     "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
     "<style>"
     "body{margin:0;padding:0;font-size:15px;}"
     "table{width:100%%;border-collapse:collapse;}"
     "td,th{border:1px solid #ccc;padding:6px;}"
     "</style>"
     "</head>"
     "<body>"
     "%@"
     "<script>"
     "function reportHeight(){"
     "var h=Math.max(document.body.scrollHeight,document.documentElement.scrollHeight);"
     "window.webkit.messageHandlers.heightChanged.postMessage(h);"
     "}"
     "window.onload=function(){setTimeout(reportHeight,50);};"
     "</script>"
     "</body>"
     "</html>", html];

    [self.webView loadHTMLString:wrapHTML baseURL:nil];
}

#pragma mark - JS Callback

- (void)userContentController:(WKUserContentController *)userContentController
       didReceiveScriptMessage:(WKScriptMessage *)message {

    if (![message.name isEqualToString:@"heightChanged"]) return;

    CGFloat height = [message.body doubleValue];

    // 防止死循环刷新
    if (ceil(self.lastHeight) == ceil(height)) return;
    [self.webView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    self.lastHeight = height;

    if (self.heightChangedBlock) {
        self.heightChangedBlock(height);
    }
}

#pragma mark - Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    self.heightChangedBlock = nil;
}

@end
