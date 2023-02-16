//
//  RedzInOutWebController.m
//  TJRtaojinroad
//
//  Created by taojinroad on 9/23/15.
//  Copyright © 2015 淘金路. All rights reserved.
//

#import "RedzInOutWebController.h"
#import "CommonUtil.h"
#import "URLParser.h"
#import "TJRBaseParserJson.h"
#import "VeDateUtil.h"
#import <WebKit/WebKit.h>

@interface RedzInOutWebController () <WKUIDelegate, WKNavigationDelegate>


@property (copy, nonatomic) NSString *webURL;
@property (copy, nonatomic) NSString *webTitle;
@property (copy, nonatomic) NSString *shareURL;
@property (assign, nonatomic) BOOL bCloseHidden;

@property (retain, nonatomic) WKWebView *webView;
@property (retain, nonatomic) IBOutlet UIImageView *tipsImageView;
@property (retain, nonatomic) IBOutlet UIView *tipsView;
@property (retain, nonatomic) IBOutlet UILabel *linkLabel;
@property (retain, nonatomic) IBOutlet UIButton *closeBtn;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *IndicatorViewRight;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation RedzInOutWebController

- (void)viewDidLoad {
	[super viewDidLoad];

    if ([self getValueFromModelDictionary:MSG_PARAMS forKey:MSG_PARAMS]) {
        NSDictionary *dic = [CommonUtil jsonValue:[self getValueFromModelDictionary:MSG_PARAMS forKey:MSG_PARAMS]];
        if (dic) {
            self.webURL = [dic objectForKey:@"webURL"];
        }
        
        [self removeModelDictionaryFromParamDictionary:MSG_PARAMS];
    }else {
        
        if ([self getValueFromModelDictionary:TJRWebViewDict forKey:@"webURL"]) {
            self.webURL = [self getValueFromModelDictionary:TJRWebViewDict forKey:@"webURL"];
            [self removeParamFromModelDictionary:TJRWebViewDict forKey:@"webURL"];
        }
        
        if ([self getValueFromModelDictionary:TJRWebViewDict forKey:@"webTitle"]) {
            self.webTitle = [self getValueFromModelDictionary:TJRWebViewDict forKey:@"webTitle"];
            [self removeParamFromModelDictionary:TJRWebViewDict forKey:@"webTitle"];
        }
    }

    if ([self getValueFromModelDictionary:TJRWebViewDict forKey:@"bCloseHidden"]) {
        self.bCloseHidden = [self getValueFromModelDictionary:TJRWebViewDict forKey:@"bCloseHidden"];
        [self removeParamFromModelDictionary:TJRWebViewDict forKey:@"bCloseHidden"];
    }
    self.webView = [self initWebView];
    [self.view addSubview:_webView];
    
    _closeBtn.hidden = _bCloseHidden;

	_tipsImageView.image = [UIImage imageNamed:HUD_ERROR];

	[self loadURL];

    //添加监测网页加载进度的观察者
    [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (IBAction)leftButtonClicked:(id)sender {
    if (_bCloseHidden) {
        [self closeButtonClicked:nil];
    }else{
        if (self.webView.canGoBack) {
            [self.webView goBack];
        } else {
            [self closeButtonClicked:nil];
        }
    }
}

- (IBAction)closeButtonClicked:(id)sender {
    [self goBack];
}

- (IBAction)tipsButtonClicked:(id)sender {
	[self loadURL];
	self.tipsView.hidden = YES;
	self.webView.hidden = NO;
}

- (void)startIndicator{
    [_IndicatorViewRight startAnimating];
}

- (void)stopIndicator{
    [self performSelector:@selector(enableIndicatorView) withObject:nil afterDelay:0.1];
}
- (void)enableIndicatorView{
    [_IndicatorViewRight stopAnimating];
}

- (WKWebView *)initWebView{
    
    if(_webView == nil){
        
        //创建网页配置对象
        WKWebViewConfiguration *config = [[[WKWebViewConfiguration alloc] init] autorelease];
        
        // 创建设置对象
        WKPreferences *preference = [[[WKPreferences alloc]init] autorelease];
        //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
        preference.minimumFontSize = 0;
        //设置是否支持javaScript 默认是支持的
        preference.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preference;
        
        // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
        config.allowsInlineMediaPlayback = YES;
        //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
        config.requiresUserActionForMediaPlayback = YES;
        //设置是否允许画中画技术 在特定设备上有效
        config.allowsPictureInPictureMediaPlayback = YES;
        //设置请求的User-Agent信息中应用程序名称 iOS9后可用
        config.applicationNameForUserAgent = @"BYY";
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT) configuration:config];
        _webView.backgroundColor = [UIColor clearColor];
        _webView.opaque = NO;
        
        // UI代理
        _webView.UIDelegate = self;
        // 导航代理
        _webView.navigationDelegate = self;
        // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
        _webView.allowsBackForwardNavigationGestures = YES;
    }
    return _webView;
}

//kvo 监听进度 必须实现此方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == _webView) {
        
    }else if([keyPath isEqualToString:@"title"] && object == _webView){
        self.titleLabel.text = _webView.title;
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (NSURL *)loadURL {
	NSString *url = self.webURL;

	NSURL *URL = [NSURL URLWithString:url];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	[self.webView loadRequest:request];
    [self startIndicator];

	return URL;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString * urlStr = navigationAction.request.URL.absoluteString;
    //因为WKWebView下面两种情况跳转会出现不行的问题，所以交给系统来处理
    if ([urlStr containsString:@"//itunes.apple.com/"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }else if (navigationAction.request.URL.scheme && ![navigationAction.request.URL.scheme hasPrefix:@"http"]) { // Protocol/URL-Scheme without http(s)
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);

}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
	NSString *link = [NSURL URLWithString:self.webURL].host;

	if (link.length > 0) {
		_linkLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"网页由 %@ 提供"), link];
	}

    self.tipsView.hidden = YES;
    [self stopIndicator];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
    self.tipsView.hidden = NO;
    [self stopIndicator];
}

- (void)dealloc {
    [_webTitle release];
    [_webURL release];
    [_webView release];
    [_tipsImageView release];
    [_tipsView release];
    [_linkLabel release];
    [_closeBtn release];
    [_IndicatorViewRight release];
    [_titleLabel release];
    
    //移除观察者
    [_webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(title))];
    
    [super dealloc];
}

@end
