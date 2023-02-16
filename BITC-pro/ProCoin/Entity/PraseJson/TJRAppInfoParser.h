//
//  AppInfoParser.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12-10-15.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseParserJson.h"
#import "TJRAppInfo.h"

@interface TJRAppInfoParser : TJRBaseParserJson
- (TJRAppInfo *)parser:(NSDictionary *)json;
- (TJRPlacard *)parserPlacard:(NSDictionary *)json;
@end
