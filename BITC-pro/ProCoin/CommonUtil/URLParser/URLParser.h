//
//  URLParser.h
//  TJRtaojinroad
//
//  Created by taojinroad on 2/26/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLParser : NSObject {
    NSArray *variables;
}

@property (nonatomic, retain) NSArray *variables;

- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForVariable:(NSString *)varName;
- (NSDictionary *)valueToDictionary;

@end
