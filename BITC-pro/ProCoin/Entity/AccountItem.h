//
//  AccountItem.h
//  TJRtaojinroad
//
//  Created by Jeans on 12/19/12.
//  Copyright (c) 2018 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountItem : NSObject
@property (copy, nonatomic)     NSString    *account;       //账号,微博就是uid，或手机号码
@property (copy, nonatomic)     NSString    *accountName;   //昵称
@property (copy, nonatomic)     NSString    *bindId;
@property (copy, nonatomic)     NSString    *expiresIn;
@property (copy, nonatomic)     NSString    *type;          //账号类型，mb手机，sinawb新浪
@property (copy, nonatomic)     NSString    *updateTime;
@property (copy, nonatomic)     NSString    *userId;
@property (copy, nonatomic)     NSString    *password;
@end
