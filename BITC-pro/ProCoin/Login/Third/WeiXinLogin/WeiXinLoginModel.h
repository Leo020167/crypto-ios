//
//  WeiXinLoginModel.h
//  TJRtaojinroad
//
//  Created by taojinroad on 14-9-12.
//  Copyright (c) 2018年 蓝跳蚤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThirdGetUserInfoBase.h"

@interface WeiXinLoginModel : ThirdGetUserInfoBase{

}

//向微信请求更多用户信息，包括姓名，头像，性别
- (void)reqWeiXinUserInfo:(NSString *)openId accessToken:(NSString*)accessToken;
@end
