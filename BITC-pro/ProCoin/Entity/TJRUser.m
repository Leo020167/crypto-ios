//
//  User.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-28.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRUser.h"

@implementation TJRUser

- (void)dealloc {
    
    TT_RELEASE_SAFELY(_password);
    TT_RELEASE_SAFELY(_userAccount);
    TT_RELEASE_SAFELY(_type);
    TT_RELEASE_SAFELY(_sex);
    TT_RELEASE_SAFELY(_selfDescription);
    TT_RELEASE_SAFELY(_userRealName);
    TT_RELEASE_SAFELY(_token);
    TT_RELEASE_SAFELY(_birthday);
    TT_RELEASE_SAFELY(_ethAddress);
    TT_RELEASE_SAFELY(_payPass);
    TT_RELEASE_SAFELY(_countryCode);
    TT_RELEASE_SAFELY(_email);
    TT_RELEASE_SAFELY(_phone);
    [super dealloc];
}

@end
