//
//  KBTTrendDataEntity.m
//  Cropyme
//
//  Created by Hay on 2019/8/15.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "KBTTrendDataEntity.h"

@implementation KBTTrendDataEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.dayTime = [self stringParser:@"dayTime" json:json];
        self.price = [self stringParser:@"price" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_dayTime release];
    [_price release];
    [super dealloc];
}

@end
