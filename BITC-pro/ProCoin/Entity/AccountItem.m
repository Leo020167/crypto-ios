//
//  AccountItem.m
//  TJRtaojinroad
//
//  Created by Jeans on 12/19/12.
//  Copyright (c) 2018 Taojinroad. All rights reserved.
//

#import "AccountItem.h"

@implementation AccountItem
@synthesize account;
@synthesize accountName;
@synthesize bindId;
@synthesize expiresIn;
@synthesize type;
@synthesize updateTime;
@synthesize userId;
@synthesize password;

- (void)dealloc{
    [account release];
    [accountName release];
    [bindId release];
    [expiresIn release];
    [type release];
    [updateTime release];
    [userId release];
    [password release];
    [super dealloc];
}
@end
