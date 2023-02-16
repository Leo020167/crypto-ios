//
//  NetWorkManage+FollowOrder.m
//  Cropyme
//
//  Created by Hay on 2019/5/29.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "NetWorkManage+FollowOrder.h"


#define URL_API_COPY_SLAVE_ORDER_DETAIL     @"copy/slave/orderDetail"
#define URL_API_COPY_SLAVE_TRADE_LIST       @"copy/slave/tradeList"
#define URL_API_SECURITY_OPEN_COPY          @"user/security/openCopy"
#define URL_API_CONFIG_OPEN_COPY_RULES      @"config/openCopyRules"
#define URL_API_COPY_SLAVE_CLOSE_ORDER_TIPS @"copy/slave/closeOrderTips"
#define URL_API_COPY_SLAVE_CLOSE_ORDER      @"copy/slave/closeOrder"
#define URL_API_COPY_SLAVE_APPEND_BALANCE   @"copy/slave/appendBalance"
#define URL_API_COPY_SLAVE_UPDATE_OPTION    @"copy/slave/updateOption"
#define URL_API_COPY_SLAVE_UPDATESTOPTIPS   @"copy/slave/updateStopTips"
#define URL_API_COPY_HISTORY                @"copy/history"

#define URL_API_COPY_DATA_HOME                      @"copy/data/home"
#define URL_API_COPY_DATA_HOLD_HOST                 @"copy/data/holdCost"
#define URL_API_COPY_DATA_COPY_BALANCE              @"copy/data/copyBalance"
#define URL_API_COPY_DATA_HOLD_MARKET_VALUE         @"copy/data/holdMarketValue"

@implementation NetWorkManage (FollowOrder)

- (NSString *)fullApiBaseUrlFollowOrder:(NSString *)apiUrl
{
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}

#pragma mark - 开通cropyme
- (void)reqOpenCropyme:(id)delegate userId:(NSString *)userId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlFollowOrder:URL_API_SECURITY_OPEN_COPY]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"userId" value:userId],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 开通cropyme规则
- (void)reqOpenCropymeRules:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlFollowOrder:URL_API_CONFIG_OPEN_COPY_RULES]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - 申请跟单
- (void)reqFollowOrderOperation:(id)delegate dvUid:(NSString *)dvUid finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlFollowOrder:@"follow/applyForFollow"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"dvUid" value:dvUid],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 解除跟单绑定*/
- (void)reqStopFollowOrder:(id)delegate dvUid:(NSString *)dvUid finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlFollowOrder:@"follow/unBind"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"dvUid" value:dvUid],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 设置是否开启跟单
- (void)reqUpdateFollowOrderOpen:(id)delegate isOpen:(BOOL)isOpen finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    NSString *isOpenString = isOpen ? @"1" : @"0";
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlFollowOrder:@"follow/updateForOpen"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"isOpen" value:isOpenString],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 设置跟单倍数
- (void)reqUpdateFollowOrderMultiNum:(id)delegate multiple:(NSString *)multiple finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlFollowOrder:@"follow/updateMultiple"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"multiple" value:multiple],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 请求订单详情
- (void)reqFollowOrderDetail:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlFollowOrder:URL_API_COPY_SLAVE_ORDER_DETAIL]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"orderId" value:orderId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 停止跟单操作前返回的信息
- (void)reqStopFollowOrderTips:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlFollowOrder:URL_API_COPY_SLAVE_CLOSE_ORDER_TIPS]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"orderId" value:orderId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}



#pragma makr - 跟单交易明细
- (void)reqFollowOrderTradeDetailList:(id)delegate symbol:(NSString *)symbol buySell:(NSString *)buySell orderId:(NSString *)orderId pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlFollowOrder:URL_API_COPY_SLAVE_TRADE_LIST]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol],
                                      [BasicNameValuePair setName:@"buySell" value:buySell],
                                      [BasicNameValuePair setName:@"orderId" value:orderId],
                                      [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - 追加金额
- (void)reqFollowOrderAppendBalance:(id)delegate orderId:(NSString *)orderId balance:(NSString *)balance finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlFollowOrder:URL_API_COPY_SLAVE_APPEND_BALANCE]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"orderId" value:orderId],
                                       [BasicNameValuePair setName:@"balance" value:balance],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取设置止盈止损提示信息
- (void)reqFollowOrderUpdateOptionTips:(id)delegate orderId:(NSString *)orderId stopWin:(NSString *)stopWin stopLoss:(NSString *)stopLoss finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlFollowOrder:URL_API_COPY_SLAVE_UPDATESTOPTIPS]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"orderId" value:orderId],
                                      [BasicNameValuePair setName:@"stopWin" value:stopWin],
                                      [BasicNameValuePair setName:@"stopLoss" value:stopLoss],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 修改设置
- (void)reqFollowOrderUpdateOptions:(id)delegate orderId:(NSString *)orderId maxFollowBalance:(NSString *)maxFollowBalance stopWin:(NSString *)stopWin stopLoss:(NSString *)stopLoss finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlFollowOrder:URL_API_COPY_SLAVE_UPDATE_OPTION]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"orderId" value:orderId],
                                       [BasicNameValuePair setName:@"maxCopyBalance" value:maxFollowBalance],
                                       [BasicNameValuePair setName:@"stopWin" value:stopWin],
                                       [BasicNameValuePair setName:@"stopLoss" value:stopLoss],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 跟单记录
- (void)reqFollowOrderRecordList:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlFollowOrder:URL_API_COPY_HISTORY]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 跟单用户数据
/** 跟单用户基本信息*/
- (void)reqFollowOrderUsersBaseInfo:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlFollowOrder:URL_API_COPY_DATA_HOME]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 跟单用户持仓成本*/
- (void)reqFollowOrderUsersHoldCost:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlFollowOrder:URL_API_COPY_DATA_HOLD_HOST]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 跟单用户跟单资金*/
- (void)reqFollowOrderUsersFollowBalance:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlFollowOrder:URL_API_COPY_DATA_COPY_BALANCE]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


/** 跟单用户持币市值*/
- (void)reqFollowOrderUsersMarket:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlFollowOrder:URL_API_COPY_DATA_HOLD_MARKET_VALUE]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

@end
