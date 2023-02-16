//
//  NetWorkManage+Leverage.m
//  BYY
//
//  Created by Hay on 2019/12/24.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "NetWorkManage+Leverage.h"

@implementation NetWorkManage (Leverage)

- (NSString *)fullApiLeverageUrl:(NSString *)apiUrl
{
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}

#pragma mark - 请求交易配置信息
- (void)reqLeverageTradeConfig:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiLeverageUrl:@"prybar/config"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol], nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 请求交易前数据确认
- (void)reqLeverageTradeCheckOut:(id)delegate symbol:(NSString *)symbol bailBalance:(NSString *)bailBalance buySell:(NSString *)buySell multiNum:(NSString *)multiNum finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiLeverageUrl:@"prybar/checkOut"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"symbol" value:symbol],
                                       [BasicNameValuePair setName:@"bailBalance" value:bailBalance],
                                       [BasicNameValuePair setName:@"buySell" value:buySell],
                                       [BasicNameValuePair setName:@"multiNum" value:multiNum],
                                       [BasicNameValuePair setName:@"isLimit" value:@"0"],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 请求下单
- (void)reqCommitLeverageTrade:(id)delegate symbol:(NSString *)symbol bailBalance:(NSString *)bailBalance buySell:(NSString *)buySell multiNum:(NSString *)multiNum payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiLeverageUrl:@"prybar/order/createOrder"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"symbol" value:symbol],
                                       [BasicNameValuePair setName:@"bailBalance" value:bailBalance],
                                       [BasicNameValuePair setName:@"buySell" value:buySell],
                                       [BasicNameValuePair setName:@"multiNum" value:multiNum],
                                       [BasicNameValuePair setName:@"isLimit" value:@"0"],
                                       [BasicNameValuePair setName:@"payPass" value:payPass],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 杠杆交易记录
- (void)reqLeverageTradeRecord:(id)delegate symbol:(NSString *)symbol buySell:(NSString *)buySell isDone:(NSString *)isDone pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiLeverageUrl:@"prybar/order/queryList"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol],
                                      [BasicNameValuePair setName:@"buySell" value:buySell],
                                      [BasicNameValuePair setName:@"isDone" value:isDone],
                                      [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - 获取交易详情记录
- (void)reqLeverageTradeDetail:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiLeverageUrl:@"prybar/order/detail"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"orderId" value:orderId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 请求平仓
- (void)reqLeverageTradeClose:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiLeverageUrl:@"prybar/order/closeOrder"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"orderId" value:orderId],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 增加保证金
- (void)reqLeverageAddBondBalance:(id)delegate orderId:(NSString *)orderId bailBalance:(NSString *)bailBalance finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiLeverageUrl:@"prybar/order/appendBailBalance"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"orderId" value:orderId],
                                      [BasicNameValuePair setName:@"bailBalance" value:bailBalance],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 设置止盈止损前的检查
- (void)reqLeverageCheckWinLoss:(id)delegate orderId:(NSString *)orderId stopWin:(NSString *)stopWin stopLoss:(NSString *)stopLoss finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiLeverageUrl:@"prybar/order/checkWinLoss"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"orderId" value:orderId],
                                       [BasicNameValuePair setName:@"stopWin" value:stopWin],
                                       [BasicNameValuePair setName:@"stopLoss" value:stopLoss],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 设置止盈止损
- (void)reqLeverageSetWinLoss:(id)delegate orderId:(NSString *)orderId stopWin:(NSString *)stopWin stopLoss:(NSString *)stopLoss finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiLeverageUrl:@"prybar/order/updateWinLoss"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"orderId" value:orderId],
                                       [BasicNameValuePair setName:@"stopWin" value:stopWin],
                                       [BasicNameValuePair setName:@"stopLoss" value:stopLoss],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}
@end
