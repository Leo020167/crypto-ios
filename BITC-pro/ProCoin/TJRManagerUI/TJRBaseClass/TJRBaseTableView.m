//
//  TJRBaseTableView.m
//  TJRtaojinroad
//
//  Created by linqing lv on 12-9-18.
//  Copyright (c) 2012年 Taojinroad. All rights reserved.
//

#import "TJRBaseTableView.h"
#import "TTGlobalCore.h"
#import "HttpBase.h"

@implementation TJRBaseTableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (!ttDelegateDictionary) ttDelegateDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (!ttDelegateDictionary) ttDelegateDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        if (!ttDelegateDictionary) ttDelegateDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)dealloc{
    [self clearHttpRequest];
    [ttDelegateDictionary removeAllObjects];
    TT_RELEASE_SAFELY(ttDelegateDictionary);
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
    for (TTBaseHttpDelegate *tt in [ttDelegateDictionary objectEnumerator]) {
        [tt clean];
    }
}


@end
