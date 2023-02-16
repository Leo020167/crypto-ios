//
//  KLineCoordinate.m
//  Http
//
//  Created by  on 12-7-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "KLineCoordinate.h"
#import "CommonUtil.h"

@implementation KLineCoordinate

- (void)dealloc {
    RELEASE(_stockTime);
    [super dealloc];
}

- (void)setAmt:(double)price today:(double)today {
    if (price == today) self.amt = 0;
    else self.amt = price > today ? 1 : -1;
}

- (NSComparisonResult)compareKeysByDes:(id)otherObject {
    if ([self stockdate] < [otherObject stockdate]) {
        return NSOrderedDescending;
    } else if ([self stockdate] > [otherObject stockdate]) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareKeysByAsc:(id)otherObject {
    if ([self stockdate] > [otherObject stockdate]) {
        return NSOrderedDescending;
    } else if ([self stockdate] < [otherObject stockdate]) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

@end
