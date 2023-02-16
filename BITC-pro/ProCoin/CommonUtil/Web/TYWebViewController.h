//
//  TYWebViewController.h
//  yunyue
//
//  Created by admin on 2017/3/1.
//  Copyright © 2017年 zhanlijun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface TYWebViewController : UIViewController

/**
 webview
 */
@property (nonatomic, strong) WKWebView *wKWebView;

/**
 网址
 */
@property (nonatomic, copy) NSString *url;

/// 是否隐藏导航栏
@property (nonatomic, assign) BOOL isNavHidden;
/**
 网页内容
 */
@property (nonatomic, strong) NSString *htmlContent;

/// 跳转类型（默认push  1为present）
@property (nonatomic, assign) NSInteger type;

@end
