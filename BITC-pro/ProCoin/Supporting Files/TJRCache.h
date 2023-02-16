//
//  CacheManager.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-28.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TJRCache : NSObject {
    NSMutableDictionary *cache;
}
@property (nonatomic, retain) NSMutableDictionary *cache;
+ (TJRCache *)shareTJRCache;

- (void)putCacheValue:(id)value forKey:(id)key;
- (id)getCacheValueForKey:(id)key;
- (void)removeCacheValueForKey:(id)key;

/**
 *	@brief	从模块参数字典里取出一个值
 *
 *	@param  model   模块名
 *	@param  key     所取值的Key
 *
 *	@return
 */
- (id)getValueFromModelDictionary:(NSString *)model forKey:(id)key;

/**
 *	@brief	往一个模块参数字典里添加一个参数
 *
 *	@param  model   模块名
 *	@param  value   参数值
 *	@param  key     参数key
 */
- (void)putValueToParamDictionary:(NSString *)model value:(id)value forKey:(id)key;

/**
 *	@brief	为一个模块添加一个参数字典(省去设值的过程)
 *
 *	@param  model
 *	@param  dic
 */
- (void)putValueToParamDictionaryModel:(NSString *)model withDictionary:(NSDictionary *)dic;

/**
 *	@brief	从一个模块参数字典里移除一个值
 *
 *	@param  model   模块名
 *	@param  key{    要移除的值的Key
 */
- (void)removeParamFromModelDictionary:(NSString *)model forKey:(id)key;
@end
