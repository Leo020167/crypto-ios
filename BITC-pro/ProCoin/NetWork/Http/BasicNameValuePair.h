//
//  BasicNameValuePair.h
//  tjr-taojinroad
//
//  Created by taojinroad on 12-8-24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasicNameValuePair : NSObject {
    NSString *name; //参数名(key)
    id value; //参数值(value)
}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) id value;

+ (BasicNameValuePair *)setName:(NSString *)name value:(id)value;
+ (NSString *)encodeToPercentEscapeString:(NSString *)input;
+ (NSString *)decodeURLString:(NSString*)input;
+ (NSString *)getPairString:(BasicNameValuePair *)statement;
@end
