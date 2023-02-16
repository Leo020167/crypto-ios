//
//  TJRBaseObj.m
//  TJRtaojinroad
//
//  Created by taojinroad on 13-1-4.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseObj.h"
#import "TTGlobalCore.h"
#import "HttpBase.h"

@implementation TJRBaseObj


- (id)init {
    self = [super init];
    if (self) {
        [self createHttpRequest];
    }
    return self;
}

- (void)createHttpRequest {
    if (!ttDelegateDictionary) ttDelegateDictionary = [[NSMutableDictionary alloc] init];
}

#pragma mark - 清除所有的httpRequest 可以手动调用
- (void)removeAllHttpRequest {
    [self clearHttpRequest];
    [ttDelegateDictionary removeAllObjects];
    TT_RELEASE_SAFELY(ttDelegateDictionary);
}

-(void)dealloc{
    [self removeAllHttpRequest];
    [super dealloc];
}

#pragma mark - 网络记录

/**
 *	@brief	保存网络里的httpRequest
 *
 *	@param 	cacheKey
 *	@param 	tjrDelegate
 */
- (void)recordHttpRequest:(NSString *)cacheKey httpRequest:(id)httpRequest {
    if (!TTIsStringWithAnyText(cacheKey)) return;
    [ttDelegateDictionary setObject:httpRequest forKey:cacheKey];
}

/**
 *	@brief	移除一个httpRequest
 *
 *	@param 	cacheKey
 */
- (void)removeHttpRequestFromDictionary:(NSString *)cacheKey {
    if (!TTIsStringWithAnyText(cacheKey)) return;
    [ttDelegateDictionary removeObjectForKey:cacheKey];
}

- (void)clearHttpRequest {

    for (TTBaseHttpDelegate *tjr in [ttDelegateDictionary objectEnumerator]) {
        [tjr clean];
    }
}
@end
