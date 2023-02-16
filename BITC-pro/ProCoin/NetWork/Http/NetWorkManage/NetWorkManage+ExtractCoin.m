//
//  NetWorkManage+ExtractCoin.m
//  Cropyme
//
//  Created by Hay on 2019/6/13.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "NetWorkManage+ExtractCoin.h"

#define URL_API_WITH_DRAW_COIN_COIN_LIST        @"depositeWithdraw/coinList"
#define URL_API_WITH_DRAW_COIN_SUBMIT           @"depositeWithdraw/submit"
#define URL_API_WITH_DRAW_COIN_LIST             @"depositeWithdraw/list"
#define URL_API_WITH_DRAW_COIN_CALCEL           @"depositeWithdraw/cancel"

@implementation NetWorkManage (ExtractCoin)

- (NSString *)fullApiBaseUrlExtractCoin:(NSString *)apiUrl
{
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}

#pragma mark - 获取冲提币记录
- (void)reqCoinOperationRecord:(id)delegate inOut:(NSString *)inOut pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlExtractCoin:@"depositeWithdraw/list"]
                              params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"inOut" value:inOut],
                                        [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取币种列表
- (void)reqDepositeWithdrawCoinList:(id)delegate inOut:(NSString *)inOut finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlExtractCoin:URL_API_WITH_DRAW_COIN_COIN_LIST]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 取消提币
- (void)reqCancelExtractCoin:(id)delegate withdrawId:(NSString *)withdrawId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlExtractCoin:URL_API_WITH_DRAW_COIN_CALCEL]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"withdrawId" value:withdrawId],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取提币或充币信息
- (void)reqDepositeWithdrawCoinBaseInfo:(id)delegate symbol:(NSString *)symbol inOut:(NSString *)inOut chainType:(NSString *)chainType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlExtractCoin:@"depositeWithdraw/getCoinInfo"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol],
                                      [BasicNameValuePair setName:@"inOut" value:inOut],
                                      [BasicNameValuePair setName:@"chainType" value:chainType],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 提币操作
- (void)reqSubmitExtractCoin:(id)delegate symbol:(NSString *)symbol amount:(NSString *)amount address:(NSString *)address chainType:(NSString *)chainType payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlExtractCoin:URL_API_WITH_DRAW_COIN_SUBMIT]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"symbol" value:symbol],
                                       [BasicNameValuePair setName:@"amount" value:amount],
                                       [BasicNameValuePair setName:@"address" value:address],
                                       [BasicNameValuePair setName:@"chainType" value:chainType],
                                       [BasicNameValuePair setName:@"payPass" value:payPass],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 提币记录
- (void)reqExtractCoinRecordList:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlExtractCoin:URL_API_WITH_DRAW_COIN_LIST]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}



@end
