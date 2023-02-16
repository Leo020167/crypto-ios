//
//  NetWorkManage+Share.m
//  Perval
//
//  Created by taojinroad on 27/09/2017.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "NetWorkManage+Share.h"

#define URL_API_WXAUTH_GET_SHARE             @"share/getShareInfo"


@implementation NetWorkManage (Share)

- (NSString *)fullApiBaseUrlShare:(NSString *)apiUrl {
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}

#pragma mark - 获取分享信息数据
/**
 *    获取分享信息数据
 *    @param shareType 分享内容类型（article_detail等）
 *    @param params json格式字符串(article_id等)
 */
- (void)reqShareData:(id)delegate shareType:(NetWorkManageShareType)shareType params:(NSString *)params finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    NSString *shareTypeString = [NSString stringWithFormat:@"%@",@(shareType)];
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlShare:URL_API_WXAUTH_GET_SHARE]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"shareType" value:shareTypeString],
                                       [BasicNameValuePair setName:@"params" value:params], nil]
                               delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}
@end
