//
//  LanguageManager.m
//  Encropy
//
//  Created by taojinroad on 2019/4/17.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "LanguageManager.h"
#import "NSBundle+Language.h"

static NSString * const LanguageAbridgeCodes[] = { @"en", @"cn", @"ts", @"ko", @"fr" , @"ru", @"es", @"ja" };

static NSString * const LanguageCodes[] = { @"en", @"zh-Hans", @"zh-HK", @"ko", @"fr" , @"ru", @"es", @"ja" };
static NSString * const LanguageStrings[] = { @"English", @"简体中文", @"繁體中文", @"한국어", @"Français", @"русский", @"Español", @"日本語" };
static NSString * const LanguageSaveKey = @"currentLanguageKey";

@implementation LanguageManager

+ (void)setupCurrentLanguage
{
//    NSString *currentLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageSaveKey];
//    if (!currentLanguage) {
//        NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
//        if (languages.count > 0) {
//            currentLanguage = languages[0];
//            [[NSUserDefaults standardUserDefaults] setObject:currentLanguage forKey:LanguageSaveKey];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//    }
//    [NSBundle setLanguage:currentLanguage];
    
    NSString *code = [LanguageManager currentLanguageCode];
    if (code) {
        [LanguageManager saveLanguageByCode: code];
    } else {
        [LanguageManager saveLanguageByCode: LanguageCodes[2]]; // 默认繁体中文
    }

}

+ (NSArray *)languageStrings
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < ELanguageCount; ++i) {
        [array addObject:NSLocalizedString(LanguageStrings[i], @"")];
    }
    return [array copy];
}

+ (NSArray *)languageCountryCodes
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < ELanguageCount; ++i) {
        [array addObject:LanguageCodes[i]];
    }
    return [array copy];
}

+ (NSString *)currentLanguageString
{
    NSString *string = @"";
    NSString *currentCode = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageSaveKey];
    for (NSInteger i = 0; i < ELanguageCount; ++i) {
        if ([currentCode isEqualToString:LanguageCodes[i]]) {
            string = NSLocalizedString(LanguageStrings[i], @"");
            break;
        }
    }
    return string;
}

+ (NSString *)currentLanguageCode
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:LanguageSaveKey];
}

/// 简体中文：用户协议48，隐私政策54，关于我们60；
///繁体中文：用户协议49，隐私政策55，关于我们61；
///其他所有语言：用户协议50，隐私政策56，关于我们62
+ (int)protocolCodeByLanguage: (int)urlCode
{
    NSLog(@"%@", [LanguageManager languageCountryCodes]);
    NSString *code = [[[NSUserDefaults standardUserDefaults] objectForKey:LanguageSaveKey] stringValue];
    
    if( [code isEqualToString:  @"zh-Hans"]) {
        return [@[@480, @540 , @600][urlCode] intValue];
    } else if( [code isEqualToString:  @"zh-HK"]) {
        return [@[@490, @550 , @610][urlCode] intValue];
    } else  {
        return [@[@500,  @560, @620][urlCode] intValue];
    }
}

+ (NSInteger)currentLanguageIndex
{
    NSInteger index = 0;
    NSString *currentCode = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageSaveKey];
    for (NSInteger i = 0; i < ELanguageCount; ++i) {
        if ([currentCode isEqualToString:LanguageCodes[i]]) {
            index = i;
            break;
        }
    }
    return index;
}

+ (void)saveLanguageByIndex:(NSInteger)index
{
    if (index >= 0 && index < ELanguageCount) {
        NSString *code = LanguageCodes[index];
        [LanguageManager saveLanguageByCode:code];
    }
}

+ (void)saveLanguageByCode:(NSString*)code
{
    [[NSUserDefaults standardUserDefaults] setObject:code forKey:LanguageSaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSBundle setLanguage:code];
}

+ (BOOL)isCurrentLanguageRTL
{
    NSInteger currentLanguageIndex = [self currentLanguageIndex];
    return ([NSLocale characterDirectionForLanguage:LanguageCodes[currentLanguageIndex]] == NSLocaleLanguageDirectionRightToLeft);
}

+ (NSString *)abridgeCode
{
    NSString *currentCode = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageSaveKey];
    for (NSInteger i = 0; i < ELanguageCount; ++i) {
        if ([currentCode isEqualToString:LanguageCodes[i]]) {
            return LanguageAbridgeCodes[i];
        }
    }
    return LanguageAbridgeCodes[0];
}

@end
