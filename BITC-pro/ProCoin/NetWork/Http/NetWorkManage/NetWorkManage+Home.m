//
//  NetWorkManage+Home.m
//  TJRtaojinniu
//
//  Created by Hay on 2017/5/6.
//  Copyright © 2017年 Taojinroad. All rights reserved.
//

#import "NetWorkManage+Home.h"

#define URL_API_CONFIG_ALL          @"config/all"
#define URL_API_HOME_ACCOUNT        @"home/account"
#define URL_API_HOME_MARKET         @"home/market"
#define URL_API_HOME_CROPYME        @"home/cropyme"
#define URL_API_HOME_MY             @"home/my"
#define URL_API_SEARCH_GET          @"search/get"
#define URL_API_HOME_ABILITYVALUETOAWARD                    @"home/abilityValueToAward"

@implementation NetWorkManage (Home)

- (NSString *)fullApiBaseUrlHome:(NSString *)apiUrl {
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}

#pragma mark - 首页获取基本App信息,版本更新等等内容
- (void)reqHomeGet:(id)delegate noticeTime:(NSString*)noticeTime finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlHome:URL_API_CONFIG_ALL]
                               params:[self fetchUrlParam:[BasicNameValuePair setName:@"noticeTime" value:noticeTime],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 账户数据
- (void)reqHomeAccountInfo:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlHome:URL_API_HOME_ACCOUNT]
                              params:[self fetchUrlParam:nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 行情数据【已弃用】
- (void)reqHomeMarketInfo:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlHome:URL_API_HOME_MARKET]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取自选股
- (void)reqCustomCoinFollowList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlHome:@"optional/coin/find"]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 排序自选股
- (void)reqSortCustomSymbol:(id)delegate symbolAndSort:(NSString *)symbolAndSort finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlHome:@"optional/coin/synSort"]
                               params:[self fetchUrlParam:[BasicNameValuePair setName:@"symbolAndSort" value:symbolAndSort],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 删除自选股
- (void)reqDeleteCustomSymbol:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlHome:@"optional/coin/del"]
                               params:[self fetchUrlParam:[BasicNameValuePair setName:@"symbol" value:symbol],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - cropyme数据
- (void)reqHomeCropymeData:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlHome:URL_API_HOME_CROPYME]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取关注页数据
- (void)reqHomeFollowUsers:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlHome:@"/home/attentionList"]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 搜索用户
- (void)reqHomeSearchUser:(id)delegate keyValue:(NSString *)keyValue finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlHome:URL_API_SEARCH_GET]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"keyValue" value:keyValue],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 请求我的页面数据
- (void)reqHomeMineData:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlHome:URL_API_HOME_MY]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 能力值兑换
- (void)reqAbilityToKBT:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlHome:URL_API_HOME_ABILITYVALUETOAWARD]
                               params:[self fetchUrlParam:nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取顶部公告
- (void)reqTopAnnounceData:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlHome:@"article/noticeTop"]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取更多公告(带分页)
- (void)reqAnnounceDataList:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlHome:@"article/noticeList"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取帮助中心列表(带分页)
- (void)reqHelpDataList:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlHome:@"article/helpList"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取平台公告列表(带分页)
- (void)reqPlatformAnnouncementDataList:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlHome:@"/article/noticeList"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

@end

