//
//  LanguageManager.h
//  Encropy
//
//  Created by taojinroad on 2019/4/17.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// @"English", @"简体中文", @"繁體中文", @"한국어", @"Français", @"русский", @"Español", @"日本語" };
typedef NS_ENUM(NSInteger, ELanguage)
{
    ELanguageEnglish,
    ELanguageChina,
    ELanguageChinaHK,
    ELanguageKorea,
    ELanguageFrance,
    ELanguageRussia,
    ELanguageSpanish,
    ELanguageJapan,
    
    ELanguageCount
};

@interface LanguageManager : NSObject

+ (void)setupCurrentLanguage;
+ (NSArray *)languageStrings;
+ (NSArray *)languageCountryCodes;
+ (NSString *)currentLanguageString;
+ (NSString *)currentLanguageCode;
+ (NSInteger)currentLanguageIndex;
+ (void)saveLanguageByIndex:(NSInteger)index;
+ (void)saveLanguageByCode:(NSString*)code;
+ (BOOL)isCurrentLanguageRTL;
/// 缩写
+ (NSString *)abridgeCode;
@end

NS_ASSUME_NONNULL_END
