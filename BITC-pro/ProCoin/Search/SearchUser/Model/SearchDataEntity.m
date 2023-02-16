//
//  SearchDataEntity.m
//  Redz
//
//  Created by Hay on 2018/12/4.
//  Copyright © 2018年 淘金路. All rights reserved.
//

#import "SearchDataEntity.h"

@implementation SearchDataEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.headUrl = [self stringParser:@"headUrl" json:json];
        self.name = [self stringParser:@"name" json:json];
        self.userId = [self stringParser:@"userId" json:json];
        self.type = [self integerParser:@"type" json:json];
        self.url = [self stringParser:@"url" json:json];
    }
    return self;
}


- (void)dealloc
{
    [_headUrl release];
    [_name release];
    [_userId release];
    [_url release];
    [super dealloc];
}
@end
