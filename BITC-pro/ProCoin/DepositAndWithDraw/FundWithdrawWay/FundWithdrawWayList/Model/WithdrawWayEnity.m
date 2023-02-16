//
//  WithdrawWayEnity.m
//  Cropyme
//
//  Created by Hay on 2019/5/15.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "WithdrawWayEnity.h"

@implementation WithdrawWayEnity



- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.receiptLogo = [self stringParser:@"receiptLogo" json:json];
        self.receiptTypeValue = [self stringParser:@"receiptTypeValue" json:json];
        self.receiptType = [self integerParser:@"receiptType" json:json];
        self.receiptDesc = [self stringParser:@"receiptDesc" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_receiptLogo release];
    [_receiptTypeValue release];
    [_receiptDesc release];
    [super dealloc];
}
@end
