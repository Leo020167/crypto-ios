//
//  WeiBoLoginModel.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-4.
//  Copyright (c) 2012年 BPerval. All rights reserved.
//

#import "WeiBoLoginModel.h"
#import "NetWorkManage+Third.h"

@interface WeiBoLoginModel (){

}
@end
@implementation WeiBoLoginModel

- (void)dealloc{
    [super dealloc];
}

//向新浪请求更多用户信息，包括姓名，头像，性别
- (void)reqSinaUserInfo:(NSString *)openId accessToken:(NSString*)accessToken{

    [[NetWorkManage shareSingleNetWork] reqSinaGetMethod:self userID:openId access_token:accessToken finishedCallback:@selector(reqSinaUserInfoFinished:) failedCallback:@selector(reqSinaUserInfoFailed:)];
}

- (void)reqSinaUserInfoFinished:(NSDictionary*)jsonDic{
    if (jsonDic) {
        NSString* nickname = [jsonDic objectForKey:@"name"];
        NSString *sex = [jsonDic objectForKey:@"gender"];
        NSString* openId = [jsonDic objectForKey:@"idstr"];
        
        NSString* headurl = @"";
        if ([jsonDic objectForKey:@"avatar_large"]
            && ([[jsonDic objectForKey:@"avatar_large"] isKindOfClass:[NSString class]])
            && ((NSString*)[jsonDic objectForKey:@"avatar_large"]).length>0) {
            headurl = [jsonDic objectForKey:@"avatar_large"];//用户头像地址（大图），180×180像素
        }else{
            headurl = [jsonDic objectForKey:@"profile_image_url"];//用户头像地址（中图），50×50像素
        }
        if ([sex isEqualToString:@"f"]) {
            sex = @"0";
        }else
            sex = @"1";
        NSString* tsex = sex;

        //通过微博账号请求注册账号
        if ([delegate respondsToSelector:@selector(registerBaseHttpFinished:nickname:headurl:sex:)]) {
            [delegate registerBaseHttpFinished:openId nickname:nickname headurl:headurl sex:tsex];
        }
        
    }else{
        if ([delegate respondsToSelector:@selector(registerBaseHttpFailed)]) {
            [delegate registerBaseHttpFailed];
        }
    }
}

- (void)reqSinaUserInfoFailed:(NSDictionary*)jsonDic{
    if ([delegate respondsToSelector:@selector(registerBaseHttpFailed)]) {
        [delegate registerBaseHttpFailed];
    }
}


@end
