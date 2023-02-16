//
//  UserParser.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-28.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TJRUser.h"
#import "TJRBaseParserJson.h"
#import "AccountItem.h"

@interface UserParser : TJRBaseParserJson

- (TJRUser *)parserMyInfoJson:(NSDictionary *)json;
- (void)parserMyInfoJson:(NSDictionary *)json user:(TJRUser *)user;

@end
