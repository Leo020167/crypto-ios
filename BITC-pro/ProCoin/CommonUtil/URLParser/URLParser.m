//
//  URLParser.m
//  TJRtaojinroad
//
//  Created by taojinroad on 2/26/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "URLParser.h"
#import "BasicNameValuePair.h"

@implementation URLParser

@synthesize variables;

- (id) initWithURLString:(NSString *)url{
    self = [super init];
    if (self != nil) {
        NSString *string = url;
        NSScanner *scanner = [NSScanner scannerWithString:string];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
        NSString *tempString;
        NSMutableArray *vars = [NSMutableArray new];
        //ignore the beginning of the string and skip to the vars
        [scanner scanUpToString:@"?" intoString:nil];
        while ([scanner scanUpToString:@"&" intoString:&tempString]) {
            [vars addObject:tempString];
        }
        variables = vars;
    }
    return self;
}

- (NSString *)valueForVariable:(NSString *)varName {
    for (NSString *var in variables) {
        if ([var length] > [varName length]+1 && [[var substringWithRange:NSMakeRange(0, [varName length]+1)] isEqualToString:[varName stringByAppendingString:@"="]]) {
            NSString *varValue = [var substringFromIndex:[varName length]+1];
            return varValue;
        }
    }
    return nil;
}

- (NSDictionary *)valueToDictionary {
    
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc]init]autorelease];
    
    for (NSString *var in variables) {
        if ([var length] > 0) {
            NSString *varName = @"";
            NSString *varValue = @"";
            NSRange startRange = [var rangeOfString:@"="];
            if (startRange.location != NSNotFound && (var.length >= startRange.location + startRange.length)) {
                varName = [var substringToIndex:startRange.location];
                varValue = [var substringFromIndex:startRange.location + startRange.length];
            }
            if (TTIsStringWithAnyText(varName)) {
                [dic setValue:varValue forKey:varName];
            }
        }
    }
    return dic;
}

@end
