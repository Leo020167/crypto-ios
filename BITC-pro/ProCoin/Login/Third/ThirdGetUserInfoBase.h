//
//  ThirdGetUserInfoBase.h
//  TJRtaojinroad
//
//  Created by taojinroad on 13-11-8.
//  Copyright (c) 2018年 蓝跳蚤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Encryption.h"
#import "UserParser.h"
#import "TJRUser.h"
#import "NetWorkManage.h"
#import "LoginSQLModel.h"

@protocol ThirdGetUserInfoDelegate <NSObject>

@optional
- (void)registerBaseHttpFinished:(NSString*)account nickname:(NSString*)nickname headurl:(NSString*)headurl sex:(NSString*)sex;
- (void)registerBaseHttpFailed;
- (void)registerBaseHttpStart;
@end

@interface ThirdGetUserInfoBase : NSObject
{
    id <ThirdGetUserInfoDelegate> delegate;
}

@property (assign, nonatomic) id delegate;
@end
