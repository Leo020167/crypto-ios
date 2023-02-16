//
//  TencentOAuthLoginModel.h
//  TJRtaojinroad
//
//  Created by taojinroad on 13-8-2.
//  Copyright (c) 2013年 BPerval. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThirdGetUserInfoBase.h"

@interface TencentOAuthLoginModel : ThirdGetUserInfoBase{

}
//向腾讯QQ请求更多用户信息，包括姓名，头像，性别
- (void)reqTencentQQUserInfo:(NSString *)openId accessToken:(NSString*)accessToken;

@end
