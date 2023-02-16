//
//  LineDataEntity.m
//  Cropyme
//
//  Created by Hay on 2019/6/11.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "LineDataEntity.h"
#import "TradeUtil.h"

@implementation LineDataEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.dayTime = [self stringParser:@"dayTime" json:json];
        self.num = [self stringParser:@"num" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_dayTime release];
    [_num release];
    [super dealloc];
}

@end
