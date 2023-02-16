//
//  TTCacheManager.h
//  Redz
//
//  Created by taojinroad on 2018/4/13.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HtmlDefaultCacheName @"html"
#define VoiceDefaultCacheName  @"voice"

@interface TTCacheManager : NSObject

+ (NSString *)storeImage:(UIImage*)image forURL:(NSString*)URL;

+ (void)storeData:(NSData*)data forKey:(NSString*)key;

+ (NSString *)storeUserImage:(UIImage *)image fileName:(NSString *)fileName;

+ (NSString *)storeDataForUserImage:(NSData *)data fileName:(NSString *)fileName;

+ (void)storeData:(NSData*)data forURL:(NSString*)URL;

+ (NSData*)dataForURL:(NSString*)URL;

+ (NSData*)dataForKey:(NSString*)key;

+ (NSString*)cachePathForPath:(NSString*)path;

+ (NSString*)getDocumentPicPath:(NSString*)keyName;

//储存读取html的图片，包含后缀png
+ (void)storeHtmlImage:(UIImage *)image forURL:(NSString *)URL;

+ (NSString*)cacheHtmlPathForURL:(NSString*)URL;

+ (NSData *)dataHtmlForURL:(NSString*)URL;

@end
