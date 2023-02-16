//
//  YSJJWeakScriptMessageDelegate.m
//  yunshangjiejie
//
//  Created by LiuQingying on 2018/4/6.
//  Copyright © 2018年 YUNSHANGZHIJIA. All rights reserved.
//

#import "TYWeakScriptMessageDelegate.h"

@implementation TYWeakScriptMessageDelegate
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate{
    if (self = [super init]) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}
@end
