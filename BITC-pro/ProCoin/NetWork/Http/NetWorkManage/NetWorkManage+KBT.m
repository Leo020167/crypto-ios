//
//  NetWorkManage+KBT.m
//  Cropyme
//
//  Created by Hay on 2019/8/14.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "NetWorkManage+KBT.h"
#define URL_API_KBT_ASSET           @"kbt/kbtAsset"
#define URL_API_YYB_REPOHOME        @"yyb/repoHome"
#define URL_API_YYB_NOTICE          @"yyb/notice"
#define URL_API_YYB_REPO            @"yyb/repo"


@implementation NetWorkManage (KBT)

- (NSString *)fullApiKBTUrl:(NSString *)apiUrl
{
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}

#pragma mark - KBT资产数据
- (void)reqKBTAssetsInfo:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiKBTUrl:URL_API_KBT_ASSET]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"pageNo" value:pageNo], nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - YYB回购主页数据
- (void)reqYYBBuyBackMainInfo:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiKBTUrl:URL_API_YYB_REPOHOME]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - YYB公告
- (void)reqYYBBuyBackAnnounceData:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiKBTUrl:URL_API_YYB_NOTICE]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 回购YYB
- (void)reqYYBRepo:(id)delegate amount:(NSString *)amount finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiKBTUrl:URL_API_YYB_REPO]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"amount" value:amount],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}




/** 认购接口*/
#pragma mark - 认购主页
- (void)reqSubMainHome:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiKBTUrl:@"coin/sub/intoSubHome"]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取认购公告
- (void)reqSubAnnounceData:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiKBTUrl:@"coin/sub/notice"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
    
}

#pragma mark - 认购
- (void)reqSubBuy:(id)delegate subId:(NSString *)subId symbol:(NSString *)symbol amount:(NSString *)amount finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiKBTUrl:@"coin/sub/subBuy"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"subId" value:subId],
                                       [BasicNameValuePair setName:@"symbol" value:symbol],
                                       [BasicNameValuePair setName:@"amount" value:amount],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - XXX资产页
- (void)reqAccountAssetsInfo:(id)delegate symbol:(NSString *)symbol pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiKBTUrl:@"account/asset"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol],
                                      [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

@end
