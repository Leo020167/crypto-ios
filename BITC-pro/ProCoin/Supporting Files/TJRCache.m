//
//  CacheManager.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-28.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRCache.h"

@implementation TJRCache

@synthesize cache;
static TJRCache *tjrCache;

- (id)init {
    self = [super init];
    if (self) {
        cache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/**
 *	@brief	缓存单例
 *
 *	@return	
 */
+ (TJRCache *)shareTJRCache {
    static dispatch_once_t onceToken;
    
	dispatch_once(&onceToken, ^{
        if (!tjrCache)  tjrCache = [[TJRCache alloc] init];
    });
    return tjrCache;
}

/**
 *	@brief	将数据put到单例的字典里
 *
 *	@param 	value 	值
 *	@param 	key 	key
 */
- (void)putCacheValue:(id)value forKey:(id)key {
    [cache setObject:value forKey:key];
}

/**
 *	@brief	从缓存里取出一项值
 *
 *	@param 	key
 *
 *	@return	
 */
- (id)getCacheValueForKey:(id)key {
    if (!TTIsStringWithAnyText(key)) return nil;
    return [cache objectForKey:key];
}

/**
 *	@brief	按key从字典里移除一个值
 *
 *	@param 	key 	
 */
- (void)removeCacheValueForKey:(id)key {
    if (!TTIsStringWithAnyText(key)) return ;
    [cache removeObjectForKey:key];
}

/**
 *	@brief	从模块参数字典里取出一个值
 *
 *	@param  model   模块名
 *	@param  key     所取值的Key
 *
 *	@return
 */
- (id)getValueFromModelDictionary:(NSString *)model forKey:(id)key {
	NSMutableDictionary *param = [self getCacheValueForKey:model];
    
	if (!param) return nil;
    
	return [param objectForKey:key];
}

/**
 *	@brief	往一个模块参数字典里添加一个参数
 *
 *	@param  model   模块名
 *	@param  value   参数值
 *	@param  key     参数key
 */
- (void)putValueToParamDictionary:(NSString *)model value:(id)value forKey:(id)key {
	NSMutableDictionary *param = [self getCacheValueForKey:model];
    
	if (!param) {
		param = [[NSMutableDictionary alloc] init];
		[self putCacheValue:param forKey:model];
		TT_RELEASE_SAFELY(param);
		param = [self getCacheValueForKey:model];
	}
    
	if (value) [param setObject:value forKey:key];
}

/**
 *	@brief	为一个模块添加一个参数字典(省去设值的过程)
 *
 *	@param  model
 *	@param  dic
 */
- (void)putValueToParamDictionaryModel:(NSString *)model withDictionary:(NSDictionary *)dic {
	if (!TTIsStringWithAnyText(model) || !dic) return;
    
	[self putCacheValue:dic forKey:model];
}

/**
 *	@brief	从一个模块参数字典里移除一个值
 *
 *	@param  model   模块名
 *	@param  key{    要移除的值的Key
 */
- (void)removeParamFromModelDictionary:(NSString *)model forKey:(id)key {
	NSMutableDictionary *param = [self getCacheValueForKey:model];
    
	if (!param || !key || !TTIsStringWithAnyText(key) || ![param.allKeys containsObject:key]) return;
    
	[param removeObjectForKey:key];
}


@end
