//
//  TYWebViewController.m
//  yunyue
//
//  Created by admin on 2017/3/1.
//  Copyright © 2017年 zhanlijun. All rights reserved.
//

#import "TYWebViewController.h"
#import <SDWebImageDownloader.h>

@interface TYWebViewController ()<WKNavigationDelegate,WKUIDelegate,UIGestureRecognizerDelegate,WKScriptMessageHandler>


/**
 进度条
 */
@property (nonatomic, strong) UIProgressView *progressView;
/**
 上次加载URL时间
 */
@property (nonatomic, strong) NSDate *lastLoadDate;
/**
 定时器隐藏progressView
 */
@property (nonatomic, strong) NSTimer *timer;
/** 是否包含中View中 */
@property (assign, nonatomic) BOOL isInView;
/** 返回按钮 */
@property (nonatomic, strong) UIBarButtonItem *backItem;
/** 关闭按钮 */
@property (nonatomic, strong) UIBarButtonItem *closeItem;
/** 网址 */
@property (nonatomic, strong) NSString *webUrl;
/** 标题 */
@property (nonatomic, strong) NSString *webTitle;
/** 图片链接 */
@property (nonatomic, strong) NSString *webImageUrl;
/** 网页内容 */
@property (nonatomic, strong) NSString *webContent;
/** 网页中的所有的图片链接 */
@property (nonatomic, strong) NSMutableArray *webImageUrlsArr;
/** 交互对象，使用它个页面注入JS代码给能够获取到的页面图片添加点击事件 */
@property (nonatomic, strong) WKUserScript *userScript;
/** 长按图片识别的二维码地址 */
@property (nonatomic, strong) NSString *QRCodeURLStr;
/**
 userContentController
 */
@property (nonatomic, strong) WKUserContentController *userContentController;

@property (nonatomic, strong) NSString *getedCouponID;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation TYWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.wKWebView];
    [self.view addSubview:self.progressView];
    if (_url) {
        [_wKWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15]];
    }else if (self.htmlContent){
        [_wKWebView loadHTMLString:self.htmlContent baseURL:nil];
    }
    if (@available(iOS 11.0, *)) {
        _wKWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setProgress) userInfo:nil repeats:YES];
    self.navigationItem.leftBarButtonItems = @[self.backItem];
    if (!self.isNavHidden) {
        [self setNav];
    }else{
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kUIStatusBarHeight, 44, 44)];
        backBtn.backgroundColor = UIColor.clearColor;
        backBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
            [self.navigationController popViewControllerAnimated:YES];
        };
        [self.view addSubview:backBtn];
    }
}

- (void)setNav{
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kUINormalNavBarHeight)];
    [self.view addSubview:navView];
    navView.backgroundColor = UIColor.whiteColor;
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kUIStatusBarHeight, 44, 44)];
    [backBtn setImage:UIImageMake(@"btn_back_black") forState:0];
    backBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
        [self.navigationController popViewControllerAnimated:YES];
    };
    [navView addSubview:backBtn];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    self.titleLabel = titleLabel;
    titleLabel.text = self.title;
    titleLabel.textColor = UIColor.blackColor;
    titleLabel.font = UIFontMake(17);
    [navView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(navView);
        make.top.mas_equalTo(kUIStatusBarHeight);
        make.height.mas_equalTo(44);
    }];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    
    // Unsure why WKWebView calls this controller - instead of it's own parent controller
    if (self.presentedViewController) {
        [self.presentedViewController presentViewController:viewControllerToPresent animated:flag completion:completion];
    } else {
        [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_userContentController){
        [_userContentController removeScriptMessageHandlerForName:@"lookMyPrize"];
        [_userContentController addScriptMessageHandler:self name:@"lookMyPrize"];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated{
    [_userContentController removeScriptMessageHandlerForName:@"lookMyPrize"];
}

- (void)setProgress{
    if (_lastLoadDate) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.lastLoadDate];
        if (interval>1) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
                [self.progressView setProgress:1 animated:YES];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"loading"]) {
        
    } else if ([keyPath isEqualToString:@"title"]) {
        NSLog(@"title :%@", self.title);
        if (!self.title) {
            self.titleLabel.text = self.wKWebView.title;
            _webTitle = self.wKWebView.title;
        }
    } else if ([keyPath isEqualToString:@"URL"]) {
        
    } else if (object == self.wKWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.wKWebView.estimatedProgress;
        if ([keyPath isEqual: @"estimatedProgress"] && object == _wKWebView) {
            [self.progressView setAlpha:1.0f];
            [self.progressView setProgress:_wKWebView.estimatedProgress animated:YES];
            if(_wKWebView.estimatedProgress >= 1.0f)
            {
                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.progressView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    self.progressView.progress = 0;
                }];
            }
        }
    }else if (object == self.progressView && [keyPath isEqualToString:@"progress"]){
        
        if (_wKWebView.estimatedProgress >=1) {
            CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
            if (newprogress>=0.9) {
                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.progressView setAlpha:0.0f];
                    [self.progressView setProgress:1 animated:YES];
                } completion:^(BOOL finished) {
                    [self.progressView setProgress:0.0f animated:NO];
                }];
                
            }else if(newprogress > 0){
                [self.progressView setAlpha:1.0f];
                [UIView animateWithDuration:0.5 animations:^{
                    [self.progressView setProgress:newprogress animated:YES];
                } completion:^(BOOL finished) {
                    
                }];
                
            }
        }
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSURL *URL = navigationAction.request.URL;
    NSString *urlStr = [URL absoluteString];
    NSString *scheme = [URL scheme];
    
    // 打电话
    if ([scheme isEqualToString:@"tel"]) {
        if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:URL];
            }
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    // 打开appstore
    if ([urlStr containsString:@"ituns.apple.com"]) {
        if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            [[UIApplication sharedApplication] openURL:URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    if([urlStr hasPrefix:@"javasctipt"]){
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
//    NSLog(@"---navigationAction : %@",navigationAction.sourceFrame);
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    if ([navigationAction.request.URL.absoluteString hasPrefix:@"weixin://wap/pay"]){
        decisionHandler(WKNavigationActionPolicyCancel);
        
        if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]){
            
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]){
                
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO} completionHandler:^(BOOL success) {
                        
                    }];
                } else {
                    [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
                }
            }else{
                [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
            }
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"未检测到微信客户端，请安装后重试。" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"立即安装" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSString* urlStr = @"https://itunes.apple.com/cn/app/微信/id414478124?mt=8";
                NSURL *downloadUrl = [NSURL URLWithString:urlStr];
                [[UIApplication sharedApplication]openURL:downloadUrl];
            }]];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSURLResponse *response = navigationResponse.response;
    NSString *url = [[response URL] absoluteString];
    NSLog(@"------url : %@",url);
    if (_wKWebView.estimatedProgress ==1) {
        self.lastLoadDate = [NSDate date];
        [self.progressView setAlpha:1.0f];
        self.progressView.progress += 0.3;
    }
    [self updateNavigationItems];
    decisionHandler(WKNavigationResponsePolicyAllow);
    
}

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
}
// 内容返回时
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}
// 页面加载成功
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    [self updateNavigationItems];
    _webUrl = webView.URL.absoluteString;
//    NSLog(@"---_webUrl : %@",_webUrl);
    NSString *injectionJSString = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, user-scalable=no\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
    
    NSString *jsToGetMetaDescriptionSource = @"document.getElementsByName(\"description\")[0].content";
    [webView evaluateJavaScript:jsToGetMetaDescriptionSource completionHandler:^(id _Nullable HTMLsource, NSError * _Nullable error) {
//        NSLog(@"HTMLsource : %@",HTMLsource);
        self->_webContent = HTMLsource;
        
    }];
    if (!_webContent) {
        NSString *jsToGetPSource = @"document.getElementsByTagName('p')[0].innerHTML";
        [webView evaluateJavaScript:jsToGetPSource completionHandler:^(id _Nullable HTMLsource, NSError * _Nullable error) {
//            NSLog(@"HTMLsource : %@",HTMLsource);
            NSString *HTMLsourceStr = (NSString *)HTMLsource;
            if ([HTMLsourceStr containsString:@"<link"] ||[HTMLsourceStr containsString:@"</div>"] ||[HTMLsourceStr containsString:@"</a>"] || [HTMLsourceStr containsString:@"</span>"]|| [HTMLsourceStr containsString:@"<img"]|| [HTMLsourceStr containsString:@"</table>"]) {
                self->_webContent = nil;
            }else{
                self->_webContent = HTMLsource;
            }
        }];
    }
    NSString *jsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
    [webView evaluateJavaScript:jsToGetHTMLSource completionHandler:^(id _Nullable HTMLsource, NSError * _Nullable error) {
//        NSLog(@"HTMLsource : %@",HTMLsource);
        self->_webImageUrlsArr = [NSMutableArray arrayWithArray:[self filterImage:HTMLsource]];
        if (self->_webImageUrlsArr.count<1) {
            [self getImageUrlByJS:webView];
        }
    }];
    [self.wKWebView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];


}
//失败
- (void)webView:(WKWebView *)webView didFailNavigation: (null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error : %@",error);
}
- (void)pushViewController{
    
//    YYHitMoneyVC *hvc = [[YYHitMoneyVC alloc]init];
//    [self.navigationController pushViewController:hvc animated:YES];
    
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark -- WKScriptMessageHandler
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //JS调用OC方法
    //message.boby就是JS里传过来的参数
    NSLog(@"body:%@",message.body);
}

- (NSArray *)filterImage:(NSString *)html
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<(img|IMG)(.*?)(/>|></img>|>)" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    NSArray *result = [regex matchesInString:html options:NSMatchingReportCompletion range:NSMakeRange(0, html.length)];
    
    for (NSTextCheckingResult *item in result) {
        NSString *imgHtml = [html substringWithRange:[item rangeAtIndex:0]];
        
        NSArray *tmpArray = nil; 
        if ([imgHtml rangeOfString:@"src=\""].location != NSNotFound) {
            tmpArray = [imgHtml componentsSeparatedByString:@"src=\""];
        } else if ([imgHtml rangeOfString:@"src="].location != NSNotFound) {
            tmpArray = [imgHtml componentsSeparatedByString:@"src="];
        }
        if (tmpArray.count >= 2) {
            NSString *src = tmpArray[1];
            
            NSUInteger loc = [src rangeOfString:@"\""].location;
            if (loc != NSNotFound) {
                src = [src substringToIndex:loc];
                if ([src hasPrefix:@"http"]) {
                    [resultArray addObject:src];
                }
            }
        }
    }
    
    return resultArray;
    
}
/*
 *通过js获取htlm中图片url
 */
- (void)getImageUrlByJS:(WKWebView *)wkWebView
{
    
    NSString *js2=@"getImages()";
    [wkWebView evaluateJavaScript:js2 completionHandler:^(id Result, NSError * error) {
        NSString *result=[NSString stringWithFormat:@"%@",Result];
        if([result hasPrefix:@"#"]){
            result=[result substringFromIndex:1];
        }
        self->_webImageUrlsArr = [NSMutableArray arrayWithArray:[result componentsSeparatedByString:@"#"]];
        NSLog(@"array====%@",self->_webImageUrlsArr);
        
    }];

}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender{
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint touchPoint = [sender locationInView:self.wKWebView];
    // 获取长按位置对应的图片url的JS代码
    NSString *imgJS = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    // 执行对应的JS代码 获取url
    [self.wKWebView evaluateJavaScript:imgJS completionHandler:^(id _Nullable imgUrl, NSError * _Nullable error) {
        
        
        
    }];
}

- (void)dealloc{
//    [_wKWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    self.wKWebView.UIDelegate = nil;
    [self.wKWebView stopLoading];
    [_wKWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_wKWebView removeObserver:self forKeyPath:@"title"];
    [_progressView removeObserver:self forKeyPath:@"progress"];
}
-(void)updateNavigationItems{
    if ([self.wKWebView canGoBack]) {
        self.navigationItem.leftBarButtonItems = @[self.backItem, self.closeItem];
    } else {
        self.navigationItem.leftBarButtonItems = @[self.backItem];
    }
}
- (void)backNative
{
    if ([self.wKWebView canGoBack]) {
        [self.wKWebView goBack];
    } else {
        [self closeNative];
    }
}
- (void)closeNative {
    if (self.type == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - init
- (WKWebView *)wKWebView{
    
    if (!_wKWebView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.preferences.javaScriptEnabled = YES;
        if (@available(iOS 9.0, *)) {
            configuration.allowsAirPlayForMediaPlayback = YES;
        } else {
            // Fallback on earlier versions
        }
        configuration.allowsInlineMediaPlayback = YES;
        configuration.selectionGranularity = YES;
        _userContentController = [[WKUserContentController alloc] init];
         [_userContentController addScriptMessageHandler:self name:@"lookMyPrize"];
        [_userContentController addUserScript:self.userScript];
        
        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";

//        NSString *sendToken = [NSString stringWithFormat:@"localStorage.setItem(\"token\",'%@');",token];
//        WKUserScript *sendTokenScript = [[WKUserScript alloc] initWithSource:sendToken injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
//        [_userContentController addScriptMessageHandler:[[YSJJWeakScriptMessageDelegate alloc] init] name:@"ios"];
//        [_userContentController addUserScript:sendTokenScript];
        WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [_userContentController addUserScript:wkUserScript];
        configuration.userContentController = _userContentController;
        if (self.isNavHidden) {
            _wKWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kUIStatusBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kUIStatusBarHeight) configuration:configuration];
        }else{
            _wKWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight) configuration:configuration];
        }
        _wKWebView.navigationDelegate = self;
        _wKWebView.UIDelegate = self;
        _wKWebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        [_wKWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [_wKWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        _wKWebView.allowsBackForwardNavigationGestures = YES;
        [_wKWebView sizeToFit];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPress.minimumPressDuration = 0.6;
        longPress.delegate = self;
        [_wKWebView addGestureRecognizer:longPress];
    }
    return _wKWebView;
}
- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 2)];
        
        _progressView.progressTintColor = [UIColor blueColor];
        _progressView.trackTintColor = [UIColor clearColor];
        [_progressView addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _progressView;
}
- (WKUserScript *)userScript {
    if (!_userScript) {
        static  NSString * const jsGetImages =
        @"function getImages(){\
        var objs = document.getElementsByTagName(\"img\");\
        var imgUrlStr='';\
        for(var i=0;i<objs.length;i++){\
        if(i==0){\
        if(objs[i]){\
        imgUrlStr=objs[i].src;\
        }\
        }else{\
        if(objs[i]){\
        imgUrlStr+='#'+objs[i].src;\
        }\
        }\
        };\
        return imgUrlStr;\
        };";
        _userScript = [[WKUserScript alloc] initWithSource:jsGetImages injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    }
    return _userScript;
}
- (UIBarButtonItem *)backItem{
    if (!_backItem) {
        _backItem = [[UIBarButtonItem alloc] init];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"common_back"];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setTitle:@"  返回" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(backNative) forControlEvents:UIControlEventTouchUpInside];
        [btn.titleLabel setFont:UIFontMake(17)];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn sizeToFit];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        btn.frame = CGRectMake(0, 0, 40, 40);
        _backItem.customView = btn;
    }
    return _backItem;
}

- (UIBarButtonItem *)closeItem
{
    if (!_closeItem) {
        _closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeNative)];
    }
    return _closeItem;
}

@end
