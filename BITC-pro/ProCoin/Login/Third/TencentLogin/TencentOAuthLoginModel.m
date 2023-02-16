//
//  TencentOAuthLoginModel.m
//  TJRtaojinroad
//
//  Created by taojinroad on 13-8-2.
//  Copyright (c) 2013年 BPerval. All rights reserved.
//

#import "TencentOAuthLoginModel.h"
#import "NetWorkManage+Third.h"

@interface TencentOAuthLoginModel (){

}
@end
@implementation TencentOAuthLoginModel

- (void)dealloc{
    [super dealloc];
}

//向QQ请求更多用户信息，包括姓名，头像，性别
- (void)reqTencentQQUserInfo:(NSString *)openId accessToken:(NSString*)accessToken{
    [[NetWorkManage shareSingleNetWork] reqTencentQQUserInfo:self openid:openId access_token:accessToken oauth_consumer_key:TencentOAuthAppId finishedCallback:@selector(reqTencentQQUserInfoFinished:) failedCallback:@selector(reqTencentQQUserInfoFailed:)];
}

- (void)reqTencentQQUserInfoFinished:(NSDictionary*)jsonDic{
    if (jsonDic) {
        
        if ([[jsonDic objectForKey:@"ret"]integerValue] == 0) {
            NSString* nickname = [jsonDic objectForKey:@"nickname"];
            NSString* openId = [jsonDic objectForKey:@"openid"];
            NSString *sex = [jsonDic objectForKey:@"gender"];
            
            NSString* headurl = @"";
            if ([jsonDic objectForKey:@"figureurl_qq_2"]
                && ([[jsonDic objectForKey:@"figureurl_qq_2"] isKindOfClass:[NSString class]])
                && ((NSString*)[jsonDic objectForKey:@"figureurl_qq_2"]).length>0) {
                //需要注意，不是所有的用户都拥有QQ的100x100的头像，但40x40像素则是一定会有。
                headurl = [jsonDic objectForKey:@"figureurl_qq_2"];//大小为100×100像素的QQ头像URL。
            }else{
                headurl = [jsonDic objectForKey:@"figureurl_qq_1"];//大小为40×40像素的QQ头像URL。
            }
            if ([sex isEqualToString:@"男"]) {
                sex = @"1";
            }else
                sex = @"0";
            NSString* tsex = sex;
            
            //通过腾讯QQ账号请求账号
            if ([delegate respondsToSelector:@selector(registerBaseHttpFinished:nickname:headurl:sex:)]) {
                [delegate registerBaseHttpFinished:openId nickname:nickname headurl:headurl sex:tsex];
            }
            
		}else{
            NSLog(@"%@,%@",[jsonDic objectForKey:@"ret"],[jsonDic objectForKey:@"msg"]);
            if ([delegate respondsToSelector:@selector(registerBaseHttpFailed)]) {
                [delegate registerBaseHttpFailed];
            }
        }
        
        
    }else {
        if ([delegate respondsToSelector:@selector(registerBaseHttpFailed)]) {
            [delegate registerBaseHttpFailed];
        }
    }
}

- (void)reqTencentQQUserInfoFailed:(NSDictionary*)jsonDic{
    if ([delegate respondsToSelector:@selector(registerBaseHttpFailed)]) {
        [delegate registerBaseHttpFailed];
    }
}

@end
