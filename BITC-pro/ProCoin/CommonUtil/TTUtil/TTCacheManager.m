//
//  TTCacheManager.m
//  Redz
//
//  Created by taojinroad on 2018/4/13.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "TTCacheManager.h"
#import "TTURLCache.h"
#import "NSStringAdditions.h"

#import "NetWorkManage.h"

@implementation TTCacheManager

// url作为key
+ (void)storeData:(NSData *)data forURL:(NSString *)URL {
    TTURLCache *cache = [TTURLCache sharedCache];
    
    [cache storeData:data forURL:URL];
}

// 自定义作为key
+ (void)storeData:(NSData *)data forKey:(NSString *)key {
    TTURLCache *cache = [TTURLCache sharedCache];
    
    [cache storeData:data forKey:key];
}

/**
 *  保存图片到本地缓存,url使用MD5加密,可以通过url从缓存中获取
 *  ([cache storeImage:image forURL:URL]; 是不加密url,所以不能用url从本地获取
 *
 *  @param image image
 *  @param URL URL
 *
 *  @return URL
 */
+ (NSString *)storeImage:(UIImage *)image forURL:(NSString *)URL {
    if (!image) return URL;
    NSData *data = UIImagePNGRepresentation(image);
    if (data && TTIsStringWithAnyText(URL)) {
        TTURLCache *cache = [TTURLCache sharedCache];
        [cache storeData:data forURL:URL];
    }
    return URL;
}

// 专为用户头像作备份缓存
+ (NSString *)storeDataForUserImage:(NSData *)data fileName:(NSString *)fileName {
    if (!data) {
        return nil;
    }
    TTURLCache *cache = [TTURLCache sharedCache];
    
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    NSString *URL = [NSString stringWithFormat:@"%@images/user/%@", urlApi, fileName];
    [cache storeData:data forURL:URL];
    return URL;
}

// 专为用户头像作备份缓存
+ (NSString *)storeUserImage:(UIImage *)image fileName:(NSString *)fileName {
    TTURLCache *cache = [TTURLCache sharedCache];
    
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    NSString *URL = [NSString stringWithFormat:@"%@images/user/%@", urlApi, fileName];
    
    [cache storeImage:image forURL:URL];
    return URL;
}

/**
 * Gets the data for a URL from the cache if it exists.
 *
 * @return nil if the URL is not cached.
 */
+ (NSData *)dataForURL:(NSString *)URL {
    TTURLCache *cache = [TTURLCache sharedCache];
    
    return [cache dataForURL:URL];
}

/**
 * Gets the data for a key from the cache if it exists.
 *
 * @return nil if the key is not cached.
 */
+ (NSData *)dataForKey:(NSString *)key {
    TTURLCache *cache = [TTURLCache sharedCache];
    
    return [cache dataForKey:key expires:TT_CACHE_EXPIRATION_AGE_NEVER timestamp:nil];
}

/**
 * Gets the url for a path from the cache if it exists.
 *
 * @return nil if the path is not cached.
 */
+ (NSString *)cachePathForPath:(NSString *)path {
    TTURLCache *cache = [TTURLCache sharedCache];
    
    return [cache cachePathForURL:path];
}

+ (NSString*)getDocumentPicPath:(NSString*)keyName{
    TTURLCache* cache = [TTURLCache sharedCache];
    return [cache cachePathForKey:keyName];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (void)storeHtmlImage:(UIImage *)image forURL:(NSString *)URL {
    
    if (!TTIsStringWithAnyText(URL))return;
    
    NSString *extension = [URL pathExtension];
//    if (!TTIsStringWithAnyText(extension))return;
    if (!TTIsStringWithAnyText(extension)) extension = @"png"; // 无后缀默认设为png

    NSString* key = [NSString stringWithFormat:@"%@.%@",[URL md5Hash],extension];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* cachesPath = [paths objectAtIndex:0];
    NSString* cachePath = [[cachesPath stringByAppendingPathComponent:kDefaultCacheName] stringByAppendingPathComponent:HtmlDefaultCacheName];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:cachePath]) {
        [fm createDirectoryAtPath: cachePath withIntermediateDirectories: YES attributes: nil error: nil];
    }
    
    NSString* filePath = [cachePath stringByAppendingPathComponent:key];
    
    [fm createFileAtPath:filePath contents:UIImagePNGRepresentation(image) attributes:nil];
}

+ (NSString*)cacheHtmlPathForURL:(NSString*)URL {
    
    if (!TTIsStringWithAnyText(URL))return nil;
    
    NSString *extension = [URL pathExtension];
//    if (!TTIsStringWithAnyText(extension))return nil;
    if (!TTIsStringWithAnyText(extension)) extension = @"png"; // 无后缀默认设为png
    
    NSString* key = [NSString stringWithFormat:@"%@.%@",[URL md5Hash],extension];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* cachesPath = [paths objectAtIndex:0];
    NSString* cachePath = [[cachesPath stringByAppendingPathComponent:kDefaultCacheName] stringByAppendingPathComponent:HtmlDefaultCacheName];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:cachePath]) {
        [fm createDirectoryAtPath: cachePath withIntermediateDirectories: YES attributes: nil error: nil];
    }
    
    return [cachePath stringByAppendingPathComponent:key];
}

+ (NSData *)dataHtmlForURL:(NSString*)URL {
    
    if (!TTIsStringWithAnyText(URL))return nil;
    
    NSString *extension = [URL pathExtension];
//    if (!TTIsStringWithAnyText(extension))return nil;
    if (!TTIsStringWithAnyText(extension)) extension = @"png"; // 无后缀默认设为png

    NSString* key = [NSString stringWithFormat:@"%@.%@",[URL md5Hash],extension];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* cachesPath = [paths objectAtIndex:0];
    NSString* cachePath = [[cachesPath stringByAppendingPathComponent:kDefaultCacheName] stringByAppendingPathComponent:HtmlDefaultCacheName];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:cachePath]) {
        [fm createDirectoryAtPath: cachePath withIntermediateDirectories: YES attributes: nil error: nil];
    }
    
    NSString* filePath = [cachePath stringByAppendingPathComponent:key];
    
    if ([fm fileExistsAtPath:filePath]) {
        return [NSData dataWithContentsOfFile:filePath];
    }
    
    return nil;
}
@end
