//
//  TJRBaseShareTimeView.h
//  TJRtaojinroad
//
//  Created by linqing lv on 12-9-18.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetWorkManage.h"

@interface TJRBaseView : UIControl {
    NSMutableDictionary *ttDelegateDictionary;
    CGRect phoneRectScreen;
}

- (void)recordHttpRequest:(NSString *)cacheKey httpRequest:(id)httpRequest;
- (void)removeHttpRequestFromDictionary:(NSString *)cacheKey;
#pragma mark - 清除所有的httpRequest 可以手动调用
- (void)removeAllHttpRequest;
- (void)clearHttpRequest;
@end
