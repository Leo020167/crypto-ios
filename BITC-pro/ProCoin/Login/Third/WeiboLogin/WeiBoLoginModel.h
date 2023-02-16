//
//  WeiBoLoginModel.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-4.
//  Copyright (c) 2012年 BPerval. All rights reserved.
//

#import "ThirdGetUserInfoBase.h"


@interface WeiBoLoginModel : ThirdGetUserInfoBase{
}
//向新浪请求更多用户信息，包括姓名，头像，性别
- (void)reqSinaUserInfo:(NSString *)openId accessToken:(NSString*)accessToken;
@end
