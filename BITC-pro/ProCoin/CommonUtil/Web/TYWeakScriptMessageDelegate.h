//
//  YSJJWeakScriptMessageDelegate.h
//  yunshangjiejie
//
//  Created by LiuQingying on 2018/4/6.
//  Copyright © 2018年 YUNSHANGZHIJIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <WebKit/WKScriptMessageHandler.h>
#import <JavaScriptCore/JavaScriptCore.h>
@interface TYWeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;
@end
