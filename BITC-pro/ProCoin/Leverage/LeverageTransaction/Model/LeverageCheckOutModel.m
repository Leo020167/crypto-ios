//
//  LeverageCheckOutModel.m
//  BYY
//
//  Created by Hay on 2019/12/26.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "LeverageCheckOutModel.h"

@implementation LeverageCheckOutModel

- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.tip = [self stringParser:@"tip" json:json];
        self.open = [self boolParser:@"open" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_tip release];
    [super dealloc];
}

@end
