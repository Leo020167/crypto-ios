//
//  TJRBaseObj.h
//  TJRtaojinroad
//
//  Created by taojinroad on 13-1-4.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetWorkManage.h"

@interface TJRBaseObj : NSObject
{
    NSMutableDictionary *ttDelegateDictionary;
}

- (void)recordHttpRequest:(NSString *)cacheKey httpRequest:(id)httpRequest;
- (void)removeHttpRequestFromDictionary:(NSString *)cacheKey;
#pragma mark - 清除所有的httpRequest 可以手动调用
- (void)removeAllHttpRequest;
- (void)clearHttpRequest;
@end
