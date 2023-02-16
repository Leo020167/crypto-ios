//
//  NetWorkManage+Trade.h
//  Cropyme
//
//  Created by Hay on 2019/5/13.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "NetWorkManage.h"

#define COIN_COIN_TRADE_HISTORY_ALL              @""
#define COIN_COIN_TRADE_HISTORY_DONE             @"30"
#define COIN_COIN_TRADE_HISTORY_PART_DONE        @"20"
#define COIN_COIN_TRADE_HISTORY_CANCEL           @"44"


@interface NetWorkManage (Trade)

#pragma mark - 币种简介
- (void)reqCoinInfo:(id)delegate symbol:(NSString *)symbol type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 请求是否已添加自选
- (void)reqCoinIsFollow:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 添加自选股
- (void)reqAddCoinFollow:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 删除自选股
- (void)reqCancelCoinFollow:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;



#pragma mark - 搜索币种
- (void)reqSearchCoin:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 充值提现
/** 充值提现页面获取usdt汇率和后面小数还有充值时间等等*/
- (void)reqDepositWithdrawHomeConfig:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 充值获取usdt汇率和后面小数等等 symbol(可选，填入此参数返回对应symbol的可用数量)*/
- (void)reqDepositUSDTConfig:(id)delegate symbol:(NSString *)symbol targetUid:(NSString *)targetUid finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;


/** 获取用户资金支付方式列表*/
- (void)reqUserFundPayList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 充值USDT long userId, String cny（买入金额cny）, long receiptId */
- (void)reqDepositUSDTOrder:(id)delegate cny:(NSString *)cny receiptId:(NSString *)receiptId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 提现USDT*/
- (void)reqWithdrawUSDTOrder:(id)delegate amount:(NSString *)amount receiptId:(NSString *)receiptId payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 创建充值/提现订单  inOut（1：充值，-1：提现）【已弃用】 */
- (void)reqCreateUserFundOrder:(id)delegate entrustAmount:(NSString *)entrustAmount receiptId:(NSString *)receiptId inOut:(NSString *)inOut finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed NS_DEPRECATED_IOS(8.0, 8.0,"use reqCrateUserFundExchangeOrder");

/** 创建现金买币,充值,提现订单 entrustAmount（买入金额/卖出数量）,  buySell（ 1：买/充值，-1：卖/提现）, isLimit（0：非限价，1：限价）*/
- (void)reqCrateUserFundExchangeOrder:(id)delegate symbol:(NSString *)symbol entrustAmount:(NSString *)entrustAmount unitPrice:(NSString *)unitPrice buySell:(NSString *)buySell isLimit:(NSString *)isLimit receiptId:(NSString *)receiptId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 取消充值订单*/
- (void)reqCancelDepositOrder:(id)delegate orderCashId:(NSString *)orderCashId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取充值提现订单详情*/
- (void)reqCashTradeOrderDetil:(id)delegate orderCashId:(NSString *)orderCashId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 标记支付*/
- (void)reqUserMarkPay:(id)delegate orderCashId:(NSString *)orderCashId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取用户已添加的收款方式*/
- (void)reqUserReceiptList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取用户默认的收款方式*/
- (void)reqUserDefaultReceiptMode:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 用户可以添加的收款方式列表*/
- (void)reqUserAbleAddReceiptList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 用户添加收款方式*/
- (void)reqUserSaveReceipt:(id)delegate receiptType:(NSString *)receiptType receiptId:(NSString *)receiptId receiptName:(NSString *)receiptName receiptNo:(NSString *)receiptNo bankName:(NSString *)bankName bankBranch:(NSString *)bankBranch qrCodeUrl:(NSString *)qrCodeUrl payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 设置默认收款方式*/
- (void)reqSetDefaultReceipt:(id)delegate receiptId:(NSString *)receiptId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 删除收款方式*/
- (void)reqDeleteReceiptWay:(id)delegate receiptId:(NSString *)receiptId payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 交易
/** 进入交易页面前配置信息*/
- (void)reqTradeConfig:(id)delegate symbol:(NSString *)symbol type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 下单前的信息计算*/
- (void)reqTradeCheckOut:(id)delegate symbol:(NSString *)symbol price:(NSString *)price hand:(NSString *)hand multiNum:(NSString *)multiNum buySell:(NSString *)buySell orderType:(NSString *)orderType type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 下单购买*/
- (void)reqTradeOrder:(id)delegate symbol:(NSString *)symbol price:(NSString *)price hand:(NSString *)hand buySell:(NSString *)buySell multiNum:(NSString *)multiNum orderType:(NSString *)orderType payPass:(NSString *)payPass type:(NSString *) type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 交易详情*/
- (void)reqTransactionDetail:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 设置止损价格*/
- (void)reqSetStopLossPriceOperation:(id)delegate orderId:(NSString *)orderId stopLossPrice:(NSString *)stopLossPrice payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 设置止盈价格*/
- (void)reqSetStopWinPriceOperation:(id)delegate orderId:(NSString *)orderId stopWinPrice:(NSString *)stopWinPrice payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 平仓*/
- (void)reqStopOrderOperation:(id)delegate orderId:(NSString *)orderId closeHand:(NSString *)closeHand payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 取消委托订单*/
- (void)reqTradeCancelOrder:(id)delegate orderId:(NSString *)orderId payPass:(NSString *)payPass type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;



#pragma mark - 交易记录
/**
 @brief 获取数字货币与股指期货交易记录
 @param symbol查询某个交易对，空字符表示不限
 @param accountType账户类型，该接口只能查数字货币与估值期货，参数在TJRDefineManage有定义
 @param isDone交易状态，空字符表示全部，可查当前委托，当前开仓，历史，参数在TJRDefineManage有定义
 @param pageNo页数
 @param buySell买卖状态，参数在TJRDefineManage有定义
 @param orderState订单状态,当交易状态isDone为历史才有效，可查已成交或已撤销，空字符表示全部,参数在TJRDefineManage有定义
 */
- (void)reqDigitalStockTransactionRecord:(id)delegate symbol:(NSString *)symbol accountType:(NSString *)accountType isDone:(NSString *)isDone pageNo:(NSString *)pageNo buySell:(NSString *)buySell orderState:(NSString *)orderState type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/**
 @brief 获取跟单记录
 @param symbol查询某个交易对，空字符表示不限
 @param accountType账户类型，该接口只能跟单记录，参数在TJRDefineManage有定义
 @param isDone交易状态，空字符表示全部，可查当前委托，当前开仓，历史，参数在TJRDefineManage有定义
 @param pageNo页数
 @param buySell买卖状态，参数在TJRDefineManage有定义
 @param orderState订单状态,当交易状态isDone为历史才有效，可查已成交或已撤销，空字符表示全部,参数在TJRDefineManage有定义
 */
- (void)reqFollowOrderTransactionRecord:(id)delegate symbol:(NSString *)symbol accountType:(NSString *)accountType isDone:(NSString *)isDone pageNo:(NSString *)pageNo buySell:(NSString *)buySell orderState:(NSString *)orderState finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取币币交易记录*/
//http://localhost/crpm/procoin/history/orderList.do
//long userId, String symbol, String state, String buySell(1：买入，-1卖出), int isDone(0：全部委托 ，1：历史记录), int pageNo
//state: null：全部，30：全部成交，24：部分成交，44：已撤销

- (void)reqCoinCoinTradeOrderHistoryList:(id)delegate symbol:(NSString *)symbol state:(NSString *)state buySell:(NSString *)buySell isDone:(NSString *)isDone pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 币币交易详情*/
- (void)reqCoinCoinTradeOrderDetail:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取现金订单记录*/
/*
 现金订单记录（包括充值提现）
 http://localhost/crpm/procoin/history/orderCashList.do
 long userId, String symbol(充值提现填USDT), String state, int isDone(0：未完成 ，1：历史记录), int pageNo
 
 state: null:全部，0：待付款，1：已标记付款，2：已完成，-10：已失效
 type: 1:充值提现， 2：买币(用于过滤USDT记录)
 */
- (void)reqCashCoinTradeOrderHistoryList:(id)delegate symbol:(NSString *)symbol state:(NSString *)state isDone:(NSString *)isDone pageNo:(NSString *)pageNo type:(NSString *)type finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;



/** OTC,法币购买USDT列表*/
- (void)reqOTCUSDTList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

@end

