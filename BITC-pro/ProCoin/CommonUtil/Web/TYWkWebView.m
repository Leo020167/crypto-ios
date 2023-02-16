//
//  TYWkWebView.m
//  yunmaimai
//
//  Created by 祥翔李 on 2017/11/8.
//  Copyright © 2017年 YUNSHANGZHIJIA. All rights reserved.
//

#import "TYWkWebView.h"

@interface TYWkWebView ()<WKNavigationDelegate,WKUIDelegate,UIGestureRecognizerDelegate,WKScriptMessageHandler>

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

@end

@implementation TYWkWebView

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration{

    self = [super initWithFrame:frame configuration:[self customConfiguration]];
    if (self) {
        [self initWebView];
    }
    return self;
}

//
- (WKWebViewConfiguration *)customConfiguration{

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
    [_userContentController addScriptMessageHandler:self name:@"hitMoneyForNews"];
    [_userContentController addUserScript:self.userScript];

    NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";

    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [_userContentController addUserScript:wkUserScript];

    configuration.userContentController = _userContentController;
    return configuration;
}

- (void)initWebView{
    
    [self addSubview:self.progressView];

    self.UIDelegate = self;
    self.navigationDelegate = self;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    self.allowsBackForwardNavigationGestures = YES;
    [self sizeToFit];
}

- (void)setUrl:(NSString *)url{
    _url = url;
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
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
  
        
    } else if ([keyPath isEqualToString:@"URL"]) {
        
    } else if (object == self && [keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.estimatedProgress;
        if ([keyPath isEqual: @"estimatedProgress"] && object == self) {
            [self.progressView setAlpha:1.0f];
            [self.progressView setProgress:self.estimatedProgress animated:YES];
            if(self.estimatedProgress >= 1.0f)
            {
                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.progressView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    self.progressView.progress = 0;
                }];
            }
        }
    }else if (object == self.progressView && [keyPath isEqualToString:@"progress"]){
        
        if (self.estimatedProgress >=1) {
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
    
    if([urlStr hasPrefix:@"javasctipt"]){
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
//    NSLog(@"---navigationAction : %@",navigationAction.sourceFrame);
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
//    NSURLResponse *response = navigationResponse.response;
//    NSString *url = [[response URL] absoluteString];
//    NSLog(@"------url : %@",url);
    if (self.estimatedProgress ==1) {
        self.lastLoadDate = [NSDate date];
        [self.progressView setAlpha:1.0f];
        self.progressView.progress += 0.3;
    }

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
    NSString *injectionJSString = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, user-scalable=no\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
    
//    [webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//        CGRect frame = webView.frame;
//        frame.size.height = [result doubleValue];
//        webView.frame = frame;
//        NSLog(@"result : %f", [result doubleValue]);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (weakSelf.refreshHeightBlock) {
//                weakSelf.refreshHeightBlock([result doubleValue]);
//                weakSelf.scrollView.scrollEnabled = NO;
//            }
//        });
//   }];

    NSLog(@"---_webUrl : %@",_webUrl);
    NSString *jsToGetPSource = @"document.getElementsByTagName('p')[0].innerHTML";
    [webView evaluateJavaScript:jsToGetPSource completionHandler:^(id _Nullable HTMLsource, NSError * _Nullable error) {
//        NSLog(@"HTMLsource : %@",HTMLsource);
        self->_webContent = HTMLsource;
        
    }];
    NSString *jsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
    [webView evaluateJavaScript:jsToGetHTMLSource completionHandler:^(id _Nullable HTMLsource, NSError * _Nullable error) {
//        NSLog(@"HTMLsource : %@",HTMLsource);
        if (HTMLsource) {
            self.webImageUrlsArr = [NSMutableArray arrayWithArray:[self filterImage:HTMLsource]];
            if (self.webImageUrlsArr.count<1) {
                [self getImageUrlByJS:webView];
            }
        }
    }];
    [self evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    
    
}
//失败
- (void)webView:(WKWebView *)webView didFailNavigation: (null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error : %@",error);
}
- (void)pushViewController{
    
    //    YYHitMoneyVC *hvc = [[YYHitMoneyVC alloc]init];
    //    [self.navigationController pushViewController:hvc animated:YES];
    
}
#pragma mark -- WKScriptMessageHandler
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //JS调用OC方法
    //message.boby就是JS里传过来的参数
    NSLog(@"body:%@",message.body);
    if ([message.name isEqualToString:@"hitMoneyForNews"]) {
        //        YYHitMoneyVC *hvc = [[YYHitMoneyVC alloc] init];
        //        [self.navigationController pushViewController:hvc animated:YES];
    }
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


#pragma mark - init
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
- (void)dealloc{
    
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [self setNavigationDelegate:nil];
    [self setUIDelegate:nil];
    [self removeObserver:self forKeyPath:@"title"];
    [_progressView removeObserver:self forKeyPath:@"progress"];
}
@end
