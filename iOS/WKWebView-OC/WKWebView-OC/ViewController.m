//
//  ViewController.m
//  WKWebView-OC
//
//  Created by 闫猛 on 2021/12/17.
//
//  from: https://github.com/ddd503/WKWebView-Sample-Objective-C

#import "ViewController.h"
@import WebKit;

@interface ViewController () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic) WKWebView *webView;
@end

static NSString *const RequestURL = @"https://www.apple.com/";

@implementation ViewController

#pragma mark - LifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

#pragma mark - Private Methods
- (void)setup {
    [self setupWebView];
    [self setURL: RequestURL];
}

- (void)setupWebView {
    self.webView = [[WKWebView alloc] initWithFrame: CGRectZero
                                      configuration: [self setJS]];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.baseView addSubview: self.webView];
    [self setupWKWebViewConstain: self.webView];
}

- (void)setURL:(NSString *)requestURLString {
    NSURL *url = [[NSURL alloc] initWithString: requestURLString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url
                                                  cachePolicy: NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval: 5];
    [self.webView loadRequest: request];
}

/// JS执行（从应用端随时触发）
- (WKWebViewConfiguration *)setJS {
    NSString *jsString = @"";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource: jsString
                                                      injectionTime: WKUserScriptInjectionTimeAtDocumentEnd
                                                   forMainFrameOnly:YES];
    WKUserContentController *wkUController = [WKUserContentController new];
    [wkUController addUserScript: userScript];
    // 设置键确定JS
    [wkUController addScriptMessageHandler:self name:@"callbackHandler"];

    WKWebViewConfiguration *wkWebConfig = [WKWebViewConfiguration new];
    wkWebConfig.userContentController = wkUController;

    return wkWebConfig;
}

/// JS执行（从应用端随时触发）
- (void)triggerJS:(NSString *)jsString webView:(WKWebView *)webView {
    [webView evaluateJavaScript:jsString
              completionHandler:^(NSString *result, NSError *error){
                  if (error != nil) {
                      NSLog(@"JS 运行时错误：%@", error.localizedDescription);
                      return;
                  }
                  NSLog(@"输出结果：%@", result);
              }];
}

/// 设置自动布局
- (void)setupWKWebViewConstain: (WKWebView *)webView {
    webView.translatesAutoresizingMaskIntoConstraints = NO;

    // 将 4 边的边距设置为 0
    NSLayoutConstraint *topConstraint =
    [NSLayoutConstraint constraintWithItem: webView
                                 attribute: NSLayoutAttributeTop
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.baseView
                                 attribute: NSLayoutAttributeTop
                                multiplier: 1.0
                                  constant: 0];

    NSLayoutConstraint *bottomConstraint =
    [NSLayoutConstraint constraintWithItem: webView
                                 attribute: NSLayoutAttributeBottom
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.baseView
                                 attribute: NSLayoutAttributeBottom
                                multiplier: 1.0
                                  constant: 0];

    NSLayoutConstraint *leftConstraint =
    [NSLayoutConstraint constraintWithItem: webView
                                 attribute: NSLayoutAttributeLeft
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.baseView
                                 attribute: NSLayoutAttributeLeft
                                multiplier: 1.0
                                  constant: 0];

    NSLayoutConstraint *rightConstraint =
    [NSLayoutConstraint constraintWithItem: webView
                                 attribute: NSLayoutAttributeRight
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.baseView
                                 attribute: NSLayoutAttributeRight
                                multiplier: 1.0
                                  constant: 0];

    NSArray *constraints = @[
                             topConstraint,
                             bottomConstraint,
                             leftConstraint,
                             rightConstraint
                             ];

    [self.baseView addConstraints:constraints];
}

#pragma mark - Action Methods
- (IBAction)back:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (IBAction)forword:(id)sender {
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (IBAction)refresh:(id)sender {
    [self.webView reload];
}

- (IBAction)jsTrigger:(id)sender {
    /// 使用消息调用配置中设置的 JS（无返回值）
    [self triggerJS:@"window.webkit.messageHandlers.callbackHandler.postMessage('Hello Native!');" webView:self.webView];
}

#pragma mark - UIWebViewDelegate Methods
/// 通过指定新窗口或框架打开内容时
- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures {

    if (navigationAction.targetFrame != nil &&
        !navigationAction.targetFrame.mainFrame) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [[NSURL alloc] initWithString: navigationAction.request.URL.absoluteString]];
        [webView loadRequest: request];

        return nil;
    }
    return nil;
}

/// JS alert处理
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {

}

/// JS confirm处理
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {

}

/// JS prompt处理
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {

}

#pragma mark - WKNavigationDelegate Methods
/// 是否允许链接打开
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSLog(@"访问网址：%@", navigationAction.request.URL.absoluteString);

    // WKNavigationActionPolicyCancel是表示禁止
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"页面开始加载");
}

// 加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
    [self.baseView bringSubviewToFront: self.toolbar];
    /// 加载完成时执行接收整个HTML的JS（带返回值）
    [self triggerJS:@"document.body.innerHTML" webView:webView];
}

// 加载失败
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败");
}

// 连接失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"错误代码：%ld", (long)error.code);
}

#pragma mark - WKScriptMessageHandler Methods
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    // JS回调
    if([message.name  isEqual: @"callbackHandler"]) {
        NSLog(@"%@", [NSString stringWithFormat:@"%@", message.body]);
    }
}

@end
