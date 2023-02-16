//
//  TencentOAuthController.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-10-29.
//  Copyright (c) 2014年 BPerval. All rights reserved.
//

#import "TencentOAuthController.h"
#import "CommonUtil.h"

#define redirect_uri_str @"http%3a%2f%2fweb.taojinroad.com%2ftjrweb%2f"

@interface TencentOAuthController ()

@end

@implementation TencentOAuthController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.canDragBack = NO;
    [self loadOAuthUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
- (void)dealloc {
    [_webView release];
    [_indicatorView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setWebView:nil];
    [self setIndicatorView:nil];
    [super viewDidUnload];
}

- (IBAction)leftButtonClicked:(id)sender {
    [self goBack];
}

/**
 * response_type	授权类型，此值固定为“code”。
 * client_id        申请QQ登录成功后，分配给应用的appid。
 * redirect_uri     成功授权后的回调地址，必须是注册appid时填写的主域名下的地址，建议设置为网站首页或网站的用户中心。
                    注意需要将url进行URLEncode。
 * state            client端的状态值。用于第三方应用防止CSRF攻击，成功授权后回调时会原样带回。
                    请务必严格按照流程检查用户与state参数状态的绑定。
 */
- (void)loadOAuthUrl{
    
    NSString* path = [NSString stringWithFormat:@"https://graph.qq.com/oauth2.0/authorize?response_type=code&client_id=%@&redirect_uri=%@&state=tjr&display=mobile",TencentOAuthAppId,redirect_uri_str];

    NSURL *url = [[NSURL alloc] initWithString:path];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [url release];
    
}


#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    return YES;
    
}

- (void)webViewDidStartLoad:(UIWebView *)_webView{
    self.indicatorView.hidden = NO;
}

/**
 Step1：通过Authorization Code获取Access Token
 Step2：使用Access Token来获取用户的OpenID
 */

- (void)webViewDidFinishLoad:(UIWebView *)_webView{
    
    NSString *url = self.webView.request.URL.absoluteString;

    if ([url hasPrefix:@"http://web.taojinroad.com/tjrweb/?"]) {
        
        //找到”code=“的range
        NSRange rangeOne;
        rangeOne=[url rangeOfString:@"code="];
        
        //根据他“code=”的range确定code参数的值的range
        NSRange range = NSMakeRange(rangeOne.length+rangeOne.location, url.length-(rangeOne.length+rangeOne.location));
        //获取code值
        NSString *codeString = [url substringWithRange:range];
        codeString = [codeString stringByReplacingOccurrencesOfString:@"&state=tjr" withString:@""];

        NSString* muString = [NSString stringWithFormat:@"https://graph.qq.com/oauth2.0/token?grant_type=authorization_code&client_id=%@&client_secret=%@&state=tjr&redirect_uri=%@&code=%@",TencentOAuthAppId,TencentOAuthAppKEY,redirect_uri_str,codeString];

        NSString *str1 = [self reqDataString:muString];
        
        
        NSString *access_token = @"";
        NSArray* arr = [str1 componentsSeparatedByString:@"&"];
        for (NSString* str in arr) {
            if ([str hasPrefix:@"access_token"]) {
                access_token = [[str componentsSeparatedByString:@"="]lastObject];
                break;
            }
        }
        NSString *openid = @"";
        if (access_token.length > 0) {
            NSString* muString = [NSString stringWithFormat:@"https://graph.qq.com/oauth2.0/me?access_token=%@",access_token];
            NSString *sText = [self reqDataString:muString];
            sText = [sText stringByReplacingOccurrencesOfString:@"callback(" withString:@""];
            sText = [sText stringByReplacingOccurrencesOfString:@");" withString:@""];
            
            
            NSDictionary *dictionary = [CommonUtil jsonValue:sText];
            openid = [dictionary objectForKey:@"openid"];
            NSLog(@"openid is:%@",openid);
        }
        
        if (openid.length>0) {
            [self putValueToParamDictionary:WebTencentOauthDict value:access_token forKey:@"access_token"];
            [self putValueToParamDictionary:WebTencentOauthDict value:openid forKey:@"openid"];
        }
        [self pageToViewControllerForName:@"LoginViewController" isReusing:YES];

    }
    self.indicatorView.hidden = YES;
}

- (void)webView:(UIWebView *)_webView didFailLoadWithError:(NSError *)error{

}

- (NSString*)reqDataString:(NSString*)str{
    
    NSURL *urlstring = [NSURL URLWithString:str];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:urlstring cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    //第三步，连接服务器
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    return str1;
}

@end
