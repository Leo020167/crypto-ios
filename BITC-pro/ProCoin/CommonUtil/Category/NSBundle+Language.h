//
//  NSBundle+Language.h
//  Encropy
//
//  Created by taojinroad on 2019/4/17.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSLocalizedStringForKey(key) [NSBundle.mainBundle localizedStringForKey:(key) value:@"" table:nil]

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (Language)

+ (void)setLanguage:(NSString *)language;

+ (NSString *)localizedStringForKey:(NSString *)key;

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
