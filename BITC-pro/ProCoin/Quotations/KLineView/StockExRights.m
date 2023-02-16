//
//  StockExRights.m
//  TJRtaojinroad
//
//  Created by 影孤清 on 14-6-23.
//  Copyright (c) 2014年 淘金路. All rights reserved.
//

#import "StockExRights.h"

@implementation StockExRights

- (id)initWithJson:(NSDictionary *)json {
    self = [super init];
    if (self && json) {
        self.fdm = [self stringParser:@"fdm" json:json];
        self.fenHong = [self doubleParser:@"fenHong" json:json];
        self.peiGu = [self doubleParser:@"peiGu" json:json];
        self.peiJia = [self doubleParser:@"peiJia" json:json];
        self.songGu = [self doubleParser:@"songGu" json:json];
        self.stockDate = [self integerParser:@"stockDate" json:json];
    }
    return self;
}


- (void)dealloc {
    RELEASE(_fdm);
    [super dealloc];
}

- (NSComparisonResult)compareKeysByDes:(id)otherObject {
    if ([self stockDate] < [otherObject stockDate]) {
        return NSOrderedDescending;
    } else if ([self stockDate] > [otherObject stockDate]) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareKeysByAsc:(id)otherObject {
    if ([self stockDate] > [otherObject stockDate]) {
        return NSOrderedDescending;
    } else if ([self stockDate] < [otherObject stockDate]) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}
@end
