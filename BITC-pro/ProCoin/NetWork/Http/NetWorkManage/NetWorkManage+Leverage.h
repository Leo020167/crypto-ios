//
//  NetWorkManage+Leverage.h
//  BYY
//
//  Created by Hay on 2019/12/24.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "NetWorkManage.h"



@interface NetWorkManage (Leverage)

/** 请求交易配置信息*/
- (void)reqLeverageTradeConfig:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 请求交易前数据确认*/
- (void)reqLeverageTradeCheckOut:(id)delegate symbol:(NSString *)symbol bailBalance:(NSString *)bailBalance buySell:(NSString *)buySell multiNum:(NSString *)multiNum finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 请求下单*/
- (void)reqCommitLeverageTrade:(id)delegate symbol:(NSString *)symbol bailBalance:(NSString *)bailBalance buySell:(NSString *)buySell multiNum:(NSString *)multiNum payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 杠杆交易记录*/
/** isDone = 0 : 当前开仓
 *  isDone = 1: 历史开仓
 */
- (void)reqLeverageTradeRecord:(id)delegate symbol:(NSString *)symbol buySell:(NSString *)buySell isDone:(NSString *)isDone pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取交易详情记录 */
- (void)reqLeverageTradeDetail:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 请求平仓*/
- (void)reqLeverageTradeClose:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 增加保证金*/
- (void)reqLeverageAddBondBalance:(id)delegate orderId:(NSString *)orderId bailBalance:(NSString *)bailBalance finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 设置止盈止损前的检查*/
- (void)reqLeverageCheckWinLoss:(id)delegate orderId:(NSString *)orderId stopWin:(NSString *)stopWin stopLoss:(NSString *)stopLoss finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 设置止盈止损*/
- (void)reqLeverageSetWinLoss:(id)delegate orderId:(NSString *)orderId stopWin:(NSString *)stopWin stopLoss:(NSString *)stopLoss finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
@end

