//
//  LBMarkdownTableViewController.m
//  LBUIProject
//
//  Created by liu bin on 2025/12/30.
//

#import "LBMarkdownTableViewController.h"
#import <DTCoreText/DTCoreText.h>
#import <MMMarkdown/MMMarkdown.h>
#import "Masonry.h"
#import <WebKit/WebKit.h>

@interface LBMarkdownTableViewController ()

@property(nonatomic, strong) DTAttributedTextView *textView;
@property(nonatomic, strong) WKWebView *webView;

@end

@implementation LBMarkdownTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.webView];
    //    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.top.right.equalTo
    //    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.textView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(150);
    }];
    
    NSString *markdownStr = @"| 名称 | 数量 |\n|------|------|\n| 苹果 | 10 |\n| 香蕉 | 5 |\n| 橙子 | 7 |";
    [self renderMarkdownTable2:markdownStr];
    [self useWebviewLoadTableStr:markdownStr];
    
}

- (void)renderMarkdownTable2:(NSString *)markdown {
    // 1. 创建包含表格的 HTML
    NSString *html = @"<style>"
                     @"table { border-collapse: collapse; width: 100%; }"
                     @"th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }"
                     @"th { background-color: #f2f2f2; }"
                     @"</style>"
                     @"<table>"
                     @"<tr><th>姓名</th><th>年龄</th><th>城市</th></tr>"
                     @"<tr><td>张三</td><td>25</td><td>北京</td></tr>"
                     @"<tr><td>李四</td><td>30</td><td>上海</td></tr>"
                     @"</table>";

    // 2. 转换为 NSAttributedString
    NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *options = @{
            DTUseiOS6Attributes: @YES,
            DTDefaultFontFamily: @"Helvetica",
            DTDefaultFontSize: @14,
            DTDefaultTextColor: [UIColor darkGrayColor],
//            DTDocumentWidth: @(contentWidth),
            DTIgnoreInlineStylesOption: @NO,
            DTDefaultLineHeightMultiplier: @1.2,
            DTDefaultLinkColor: [UIColor blueColor],
            DTDefaultLinkHighlightColor: [UIColor redColor],
            DTDefaultLinkDecoration: @NO,
//            DTHTMLAttributedStringShouldDrawDebugFrames: @YES // 调试边框
        };
    
    NSAttributedString *attributedString = [[NSAttributedString alloc]
        initWithHTMLData:htmlData
        options:options
        documentAttributes:NULL];
    self.textView.attributedString = attributedString;
    CGSize size = [self.textView sizeThatFits:CGSizeMake(self.view.bounds.size.width, CGFLOAT_MAX)];
    NSLog(@"LBLog size is %@", @(size));
}

- (void)renderMarkdownTable:(NSString *)markdown {
    NSError *error = nil;
    NSString *contentHtmlString = [MMMarkdown HTMLStringWithMarkdown:markdown extensions:MMMarkdownExtensionsGitHubFlavored
                                                  error:&error];
    contentHtmlString = [self getFullHtmlWithHtmlString:contentHtmlString];
    
    NSData *data = [contentHtmlString dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *options = @{
        DTDefaultFontFamily: @"PingFang SC",
        DTDefaultFontSize: @14,
        DTUseiOS6Attributes: @YES
    };

    NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data
                                                                          options:options
                                                               documentAttributes:nil];

    self.textView.attributedString = attrString;
    CGSize size = [self.textView sizeThatFits:CGSizeMake(self.view.bounds.size.width, CGFLOAT_MAX)];
    NSLog(@"LBLog size height is %@",@(size));
//    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(size.height);
//    }];
}

- (void)useWebviewLoadTableStr:(NSString *)markdownStr{
    NSError *error = nil;
    NSString *contentHtmlString = [MMMarkdown HTMLStringWithMarkdown:markdownStr extensions:MMMarkdownExtensionsGitHubFlavored
                                                  error:&error];
    contentHtmlString = [self getFullHtmlWithHtmlString:contentHtmlString];
    [self.webView loadHTMLString:contentHtmlString baseURL:nil];
}

// 提供完整的HTML字符串，包含CSS样式
-(NSString *)getFullHtmlWithHtmlString:(NSString*)htmlString{
    // 2. 定义包含表格样式的 CSS
    NSString *css = @"<style>"
    "/* 全局样式：强制适配容器宽度，消除顶部留白 */"
    "* { box-sizing: border-box; margin: 0; padding: 0; }"
    "html, body {"
    "    width: 100%;"
    "    margin: 0;"
    "    padding: 0;"
    "    overflow-x: hidden;"
    "    font-family: -apple-system, BlinkMacSystemFont, \"PingFang SC\", \"Helvetica Neue\", sans-serif;"
    "    font-size: 16px;"
    "    line-height: 1.6;"
    "    color: #333;"
    "}"
    "/* 表格：自适应宽度，内部横向滚动 */"
    "table {"
    "    width: 100%;"
    "    border-collapse: collapse;"
    "    overflow-x: auto;"
    "    display: block;"
    "    margin: 16px 0;"
    "}"
    "/* 单元格：自动换行，避免撑大 */"
    "td, th {"
    "    border: 1px solid #ddd;"
    "    padding: 8px;"
    "    word-wrap: break-word;"
    "    white-space: normal;"
    "}"
    "/* 文字内容：占满宽度 */"
    "p, div, h1, h2, h3 {"
    "    width: 100%;"
    "    margin: 8px 0;"
    "}"
    "</style>";

    // 3. 构造完整的 HTML（包含样式和内容）
    NSString *fullHtml = [NSString stringWithFormat:
                         @"<html>"
                         "<head>"
                         "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" // 适配移动端
                         "%@" // 插入 CSS 样式
                         "</head>"
                         "<body>%@</body>" // 插入 HTML 内容
                         "</html>", css, htmlString];
    return fullHtml;
}

- (NSString *)htmlFromMarkdown:(NSString *)markdown {
    NSError *error = nil;
    NSString *html = [MMMarkdown HTMLStringWithMarkdown:markdown error:&error];
    if (error) {
        NSLog(@"Markdown 转 HTML 出错: %@", error);
        return @"";
    }

    // 包装 HTML，加上 table 样式
    NSString *htmlString = [NSString stringWithFormat:
        @"<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0'>"
        "<style>"
        "body { font-family: -apple-system; font-size: 14px; }"
        "table { border-collapse: collapse; width: 100%%; }"
        "th, td { border: 1px solid #ccc; padding: 4px; }"
        "th { background-color: #f5f5f5; }"
        "</style></head><body>%@</body></html>", html];

    return htmlString;
}

- (DTAttributedTextView *)textView{
    if (!_textView) {
        _textView = [[DTAttributedTextView alloc] init];
        _textView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    }
    return _textView;
}

- (WKWebView *)webView{
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
    }
    return _webView;
}

@end
