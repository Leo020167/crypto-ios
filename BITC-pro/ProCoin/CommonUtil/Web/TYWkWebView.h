//
//  TYWkWebView.h
//  yunmaimai
//
//  Created by 祥翔李 on 2017/11/8.
//  Copyright © 2017年 YUNSHANGZHIJIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface TYWkWebView : WKWebView

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) void(^refreshHeightBlock)(CGFloat webHeight);

@end
