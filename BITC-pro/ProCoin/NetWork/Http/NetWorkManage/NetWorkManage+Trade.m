//
//  NetWorkManage+Trade.m
//  Cropyme
//
//  Created by Hay on 2019/5/13.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "NetWorkManage+Trade.h"

#define URL_API_COIN_INFO                                   @"coin/info"
#define URL_API_SEARCH_COIN                                 @"search/coin"
#define URL_API_TRADE_INOUTHOME                             @"trade/inOutHome"
#define URL_API_TRADE_CONFIG                                @"trade/config"
#define URL_API_TRADE_CASH_ORDER                            @"trade/cash/order"
#define URL_API_TRADE_ORDERCASH_BUY                         @"trade/orderCash/buy"
#define URL_API_TRADE_ORDERCASH_SELL                        @"trade/orderCash/sell"
#define URL_API_TRADE_ORDERCASH_CANCEL                      @"trade/orderCash/cancel"
#define URL_API_RECEIPT_USER_PAY_LIST                       @"receipt/userPayList"
#define URL_API_RECEIPT_USER_RECEIPT_LIST                   @"receipt/userReceiptList"
#define URL_API_RECEIPT_SAVE_RECEIPT                        @"receipt/saveReceipt"
#define URL_API_RECEIPT_GET_DEFAULT                         @"receipt/getDefault"
#define URL_API_RECEIPT_RECEIPT_LIST_FOR_ADD                @"receipt/receiptListForAdd"
#define URL_API_RECEIPT_SET_DEFAULT                         @"receipt/setDefault"
#define URL_API_RECEIPT_DELETE                              @"receipt/delete"
#define URL_API_CASH_INOUT_CREATE                           @"cash/inOut/create"
#define URL_API_TRADE_ORDER_CASH_MARK_PAY                   @"trade/orderCash/markPay"
#define URL_API_TRADE_HISTORY_ORDER_LIST                    @"trade/history/orderList"
#define URL_API_TRADE_HISTORY_ORDER_CASH_LIST               @"trade/history/orderCashList"
#define URL_API_TRADE_HISTORY_ORDER_CASH_DETAIL             @"trade/history/orderCash/detail"
#define URL_API_TRADE_HISTORY_TRADE_ORDER_DETAIL            @"trade/history/order/detail"
#define URL_API_ACCOUNT_HOLD                                @"account/hold"



@implementation NetWorkManage (Trade)

- (NSString *)fullApiBaseUrlTrade:(NSString *)apiUrl
{
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}

#pragma mark - 币种简介
- (void)reqCoinInfo:(id)delegate symbol:(NSString *)symbol type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:URL_API_COIN_INFO]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"type" value:type],
                                      [BasicNameValuePair setName:@"symbol" value:symbol],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 请求是否已添加自选
- (void)reqCoinIsFollow:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:@"optional/coin/isOptional"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 添加自选股
- (void)reqAddCoinFollow:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:@"optional/coin/add"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 删除自选股
- (void)reqCancelCoinFollow:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:@"optional/coin/del"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}



#pragma mark - 搜索币种
- (void)reqSearchCoin:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:URL_API_SEARCH_COIN]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 充值提现页面获取usdt汇率和后面小数还有充值时间等等
- (void)reqDepositWithdrawHomeConfig:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:URL_API_TRADE_INOUTHOME]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 充值获取usdt汇率和后面小数等等
- (void)reqDepositUSDTConfig:(id)delegate symbol:(NSString *)symbol targetUid:(NSString *)targetUid finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:URL_API_TRADE_CONFIG]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"symbol" value:symbol],
                                      [BasicNameValuePair setName:@"targetUid" value:targetUid],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取用户资金支付方式列表
- (void)reqUserFundPayList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:URL_API_RECEIPT_USER_PAY_LIST]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark -  充值USDT
- (void)reqDepositUSDTOrder:(id)delegate cny:(NSString *)cny receiptId:(NSString *)receiptId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:URL_API_TRADE_ORDERCASH_BUY]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"cny" value:cny],
                                       [BasicNameValuePair setName:@"receiptId" value:receiptId],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 提现USDT
- (void)reqWithdrawUSDTOrder:(id)delegate amount:(NSString *)amount receiptId:(NSString *)receiptId payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:URL_API_TRADE_ORDERCASH_SELL]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"amount" value:amount],
                                       [BasicNameValuePair setName:@"receiptId" value:receiptId],
                                       [BasicNameValuePair setName:@"payPass" value:payPass],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 创建充值/提现订单  inOut（1：充值，-1：提现）
- (void)reqCreateUserFundOrder:(id)delegate entrustAmount:(NSString *)entrustAmount receiptId:(NSString *)receiptId inOut:(NSString *)inOut finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:URL_API_CASH_INOUT_CREATE]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"entrustAmount" value:entrustAmount],
                                      [BasicNameValuePair setName:@"receiptId" value:receiptId],
                                      [BasicNameValuePair setName:@"inOut" value:inOut],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 创建现金买币,充值,提现订单 entrustAmount（买入金额/卖出数量）, buySell（ 1：买/充值，-1：卖/提现）, isLimit（0：非限价，1：限价）
- (void)reqCrateUserFundExchangeOrder:(id)delegate symbol:(NSString *)symbol entrustAmount:(NSString *)entrustAmount unitPrice:(NSString *)unitPrice buySell:(NSString *)buySell isLimit:(NSString *)isLimit receiptId:(NSString *)receiptId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:URL_API_TRADE_CASH_ORDER]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"symbol" value:symbol],
                                       [BasicNameValuePair setName:@"entrustAmount" value:entrustAmount],
                                       [BasicNameValuePair setName:@"unitPrice" value:unitPrice],
                                       [BasicNameValuePair setName:@"buySell" value:buySell],
                                       [BasicNameValuePair setName:@"isLimit" value:isLimit],
                                       [BasicNameValuePair setName:@"receiptId" value:receiptId],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 取消充值订单
- (void)reqCancelDepositOrder:(id)delegate orderCashId:(NSString *)orderCashId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:URL_API_TRADE_ORDERCASH_CANCEL]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"orderCashId" value:orderCashId],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];

}

#pragma mark - 获取充值提现订单详情
- (void)reqCashTradeOrderDetil:(id)delegate orderCashId:(NSString *)orderCashId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:URL_API_TRADE_HISTORY_ORDER_CASH_DETAIL]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"orderCashId" value:orderCashId],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 标记支付
- (void)reqUserMarkPay:(id)delegate orderCashId:(NSString *)orderCashId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:URL_API_TRADE_ORDER_CASH_MARK_PAY]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"orderCashId" value:orderCashId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取用户已添加的收款方式
- (void)reqUserReceiptList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:URL_API_RECEIPT_USER_RECEIPT_LIST]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 获取用户默认的收款方式
- (void)reqUserDefaultReceiptMode:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:URL_API_RECEIPT_GET_DEFAULT]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 用户可以添加的收款方式列表
- (void)reqUserAbleAddReceiptList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:URL_API_RECEIPT_RECEIPT_LIST_FOR_ADD]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 用户添加收款方式
- (void)reqUserSaveReceipt:(id)delegate receiptType:(NSString *)receiptType receiptId:(NSString *)receiptId receiptName:(NSString *)receiptName receiptNo:(NSString *)receiptNo bankName:(NSString *)bankName bankBranch:(NSString *)bankBranch qrCodeUrl:(NSString *)qrCodeUrl payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:URL_API_RECEIPT_SAVE_RECEIPT]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"receiptType" value:receiptType],
                                      [BasicNameValuePair setName:@"receiptId" value:receiptId],
                                      [BasicNameValuePair setName:@"receiptName" value:receiptName],
                                      [BasicNameValuePair setName:@"receiptNo" value:receiptNo],
                                      [BasicNameValuePair setName:@"bankName" value:bankName],
                                      [BasicNameValuePair setName:@"bankBranch" value:bankBranch],
                                      [BasicNameValuePair setName:@"qrCodeUrl" value:qrCodeUrl],
                                      [BasicNameValuePair setName:@"payPass" value:payPass],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 设置默认收款方式
- (void)reqSetDefaultReceipt:(id)delegate receiptId:(NSString *)receiptId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:URL_API_RECEIPT_SET_DEFAULT]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"receiptId" value:receiptId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 删除收款方式
- (void)reqDeleteReceiptWay:(id)delegate receiptId:(NSString *)receiptId payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:URL_API_RECEIPT_DELETE]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"receiptId" value:receiptId],
                                      [BasicNameValuePair setName:@"payPass" value:payPass],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 进入交易页面前配置信息
- (void)reqTradeConfig:(id)delegate symbol:(NSString *)symbol type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:@"pro/order/config"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"type" value:type],
                                      [BasicNameValuePair setName:@"symbol" value:symbol],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 下单前的信息计算
- (void)reqTradeCheckOut:(id)delegate symbol:(NSString *)symbol price:(NSString *)price hand:(NSString *)hand multiNum:(NSString *)multiNum buySell:(NSString *)buySell orderType:(NSString *)orderType type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:@"pro/order/checkOut"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"type" value:type],
                                       [BasicNameValuePair setName:@"symbol" value:symbol],
                                       [BasicNameValuePair setName:@"price" value:price],
                                       [BasicNameValuePair setName:@"hand" value:hand],
                                       [BasicNameValuePair setName:@"multiNum" value:multiNum],
                                       [BasicNameValuePair setName:@"buySell" value:buySell],
                                       [BasicNameValuePair setName:@"orderType" value:orderType],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 下单购买
- (void)reqTradeOrder:(id)delegate symbol:(NSString *)symbol price:(NSString *)price hand:(NSString *)hand buySell:(NSString *)buySell multiNum:(NSString *)multiNum orderType:(NSString *)orderType payPass:(NSString *)payPass type:(NSString *) type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:@"pro/order/open"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"type" value:type],
                                       [BasicNameValuePair setName:@"symbol" value:symbol],
                                       [BasicNameValuePair setName:@"price" value:price],
                                       [BasicNameValuePair setName:@"hand" value:hand],
                                       [BasicNameValuePair setName:@"buySell" value:buySell],
                                       [BasicNameValuePair setName:@"multiNum" value:multiNum],
                                       [BasicNameValuePair setName:@"orderType" value:orderType],
                                       [BasicNameValuePair setName:@"payPass" value:payPass],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 交易详情
- (void)reqTransactionDetail:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTrade:@"pro/order/detail"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"orderId" value:orderId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 设置止损价格
- (void)reqSetStopLossPriceOperation:(id)delegate orderId:(NSString *)orderId stopLossPrice:(NSString *)stopLossPrice payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:@"pro/order/updateLossPrice"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"orderId" value:orderId],
                                       [BasicNameValuePair setName:@"stopLossPrice" value:stopLossPrice],
                                       [BasicNameValuePair setName:@"payPass" value:payPass],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 设置止盈价格
- (void)reqSetStopWinPriceOperation:(id)delegate orderId:(NSString *)orderId stopWinPrice:(NSString *)stopWinPrice payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:@"pro/order/updateWinPrice"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"orderId" value:orderId],
                                       [BasicNameValuePair setName:@"stopWinPrice" value:stopWinPrice],
                                       [BasicNameValuePair setName:@"payPass" value:payPass],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 平仓
- (void)reqStopOrderOperation:(id)delegate orderId:(NSString *)orderId closeHand:(NSString *)closeHand payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:@"pro/order/close"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"orderId" value:orderId],
                                       [BasicNameValuePair setName:@"closeHand" value:closeHand],
                                       [BasicNameValuePair setName:@"payPass" value:payPass],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 取消交易委托订单
- (void)reqTradeCancelOrder:(id)delegate orderId:(NSString *)orderId payPass:(NSString *)payPass type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:@"pro/order/cancel"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"type" value:type],
                                       [BasicNameValuePair setName:@"orderId" value:orderId],
                                       [BasicNameValuePair setName:@"payPass" value:payPass],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 数字货币与股指期货交易记录
- (void)reqDigitalStockTransactionRecord:(id)delegate symbol:(NSString *)symbol accountType:(NSString *)accountType isDone:(NSString *)isDone pageNo:(NSString *)pageNo buySell:(NSString *)buySell orderState:(NSString *)orderState type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:@"pro/order/queryList"]
                                params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"type" value:type],
                                        [BasicNameValuePair setName:@"symbol" value:symbol],
                                        [BasicNameValuePair setName:@"accountType" value:accountType],
                                        [BasicNameValuePair setName:@"isDone" value:isDone],
                                        [BasicNameValuePair setName:@"pageNo" value:pageNo],
                                        [BasicNameValuePair setName:@"buySell" value:buySell],
                                        [BasicNameValuePair setName:@"orderState" value:orderState],nil]
                              delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 跟单交易记录
- (void)reqFollowOrderTransactionRecord:(id)delegate symbol:(NSString *)symbol accountType:(NSString *)accountType isDone:(NSString *)isDone pageNo:(NSString *)pageNo buySell:(NSString *)buySell orderState:(NSString *)orderState finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:@"pro/order/queryFollowList"]
      params:[self fetchUrlParam:
              [BasicNameValuePair setName:@"symbol" value:symbol],
              [BasicNameValuePair setName:@"accountType" value:accountType],
              [BasicNameValuePair setName:@"isDone" value:isDone],
              [BasicNameValuePair setName:@"pageNo" value:pageNo],
              [BasicNameValuePair setName:@"buySell" value:buySell],
              [BasicNameValuePair setName:@"orderState" value:orderState],nil]
    delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - 币币交易交易记录
//http://localhost/crpm/procoin/history/orderList.do
//long userId, String symbol, String state, String buySell(1：买入，-1卖出), int isDone(0：全部委托 ，1：历史记录), int pageNo
//state: null：全部，30：全部成交，24：部分成交，44：已撤销
/** 获取*/
- (void)reqCoinCoinTradeOrderHistoryList:(id)delegate symbol:(NSString *)symbol state:(NSString *)state buySell:(NSString *)buySell isDone:(NSString *)isDone pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:URL_API_TRADE_HISTORY_ORDER_LIST]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"symbol" value:symbol],
                                       [BasicNameValuePair setName:@"state" value:state],
                                       [BasicNameValuePair setName:@"buySell" value:buySell],
                                       [BasicNameValuePair setName:@"isDone" value:isDone],
                                       [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 币币交易详情
- (void)reqCoinCoinTradeOrderDetail:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:URL_API_TRADE_HISTORY_TRADE_ORDER_DETAIL]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"orderId" value:orderId],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 现金交易记录
- (void)reqCashCoinTradeOrderHistoryList:(id)delegate symbol:(NSString *)symbol state:(NSString *)state isDone:(NSString *)isDone pageNo:(NSString *)pageNo type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:URL_API_TRADE_HISTORY_ORDER_CASH_LIST]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"symbol" value:symbol],
                                       [BasicNameValuePair setName:@"state" value:state],
                                       [BasicNameValuePair setName:@"isDone" value:isDone],
                                       [BasicNameValuePair setName:@"pageNo" value:pageNo],
                                       [BasicNameValuePair setName:@"type" value:type],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - OTC,法币购买USDT列表
- (void)reqOTCUSDTList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTrade:@"otc/support/otcList"]
                               params:[self fetchUrlParam:nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

@end

