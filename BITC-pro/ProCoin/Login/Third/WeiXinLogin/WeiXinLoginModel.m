//
//  WeiXinLoginModel.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-9-12.
//  Copyright (c) 2018年 蓝跳蚤. All rights reserved.
//

#import "WeiXinLoginModel.h"
#import "NetWorkManage+Third.h"

@interface WeiXinLoginModel (){

}
@end
@implementation WeiXinLoginModel

- (void)dealloc{
    
    [super dealloc];
}

//向微信请求更多用户信息，包括姓名，头像，性别
- (void)reqWeiXinUserInfo:(NSString *)openId accessToken:(NSString*)accessToken{

    [[NetWorkManage shareSingleNetWork] weixinGetUserInfo:self weixinOpenId:openId weixinAccessToken:accessToken httpFinish:@selector(reqWeiXinUserInfoFinished:) httpFalid:@selector(reqWeiXinUserInfoFailed:)];
}

- (void)reqWeiXinUserInfoFinished:(NSDictionary*)jsonDic{
    if (jsonDic) {
        NSString* nickname = [jsonDic objectForKey:@"nickname"];
        NSInteger sex = [[jsonDic objectForKey:@"sex"]integerValue];//普通用户性别，1为男性，2为女性
        NSString* headurl = @"";
        if ([jsonDic objectForKey:@"headimgurl"]
            && ([[jsonDic objectForKey:@"headimgurl"] isKindOfClass:[NSString class]])
            && ((NSString*)[jsonDic objectForKey:@"headimgurl"]).length>0) {
            headurl = [jsonDic objectForKey:@"headimgurl"];//用户头像地址

        }
        NSString* account = @"";
        if ([jsonDic objectForKey:@"unionid"]
            && ([[jsonDic objectForKey:@"unionid"] isKindOfClass:[NSString class]])
            && ((NSString*)[jsonDic objectForKey:@"unionid"]).length>0) {
            account= [jsonDic objectForKey:@"unionid"];//微信唯一标示
            
        }
        NSString* tsex = sex>1?@"0":@"1";
        
        //通过微信账号请求注册蓝跳蚤账号
        if ([delegate respondsToSelector:@selector(registerBaseHttpFinished:nickname:headurl:sex:)]) {
            [delegate registerBaseHttpFinished:account nickname:nickname headurl:headurl sex:tsex];
        }
        
    }else{
        if ([delegate respondsToSelector:@selector(registerBaseHttpFailed)]) {
            [delegate registerBaseHttpFailed];
        }
    }
}

- (void)reqWeiXinUserInfoFailed:(NSDictionary*)jsonDic{
    if ([delegate respondsToSelector:@selector(registerBaseHttpFailed)]) {
        [delegate registerBaseHttpFailed];
    }
}

@end
