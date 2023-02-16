//
//  NetWorkManage+FollowOrder.h
//  Cropyme
//
//  Created by Hay on 2019/5/29.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "NetWorkManage.h"



@interface NetWorkManage (FollowOrder)


#pragma mark - cropyme
/** 开通cropyme*/
- (void)reqOpenCropyme:(id)delegate userId:(NSString *)userId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 开通cropyme规则*/
- (void)reqOpenCropymeRules:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;


#pragma mark - 跟单数据
/** 申请跟单*/
- (void)reqFollowOrderOperation:(id)delegate dvUid:(NSString *)dvUid finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 解除跟单绑定*/
- (void)reqStopFollowOrder:(id)delegate dvUid:(NSString *)dvUid finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 设置是否开启跟单*/
- (void)reqUpdateFollowOrderOpen:(id)delegate isOpen:(BOOL)isOpen finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 设置跟单倍数*/
- (void)reqUpdateFollowOrderMultiNum:(id)delegate multiple:(NSString *)multiple finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;


/** 请求订单详情*/
- (void)reqFollowOrderDetail:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 停止跟单操作前返回的信息*/
- (void)reqStopFollowOrderTips:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;



/** 跟单交易明细*/
- (void)reqFollowOrderTradeDetailList:(id)delegate symbol:(NSString *)symbol buySell:(NSString *)buySell orderId:(NSString *)orderId pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 追加金额*/
- (void)reqFollowOrderAppendBalance:(id)delegate orderId:(NSString *)orderId balance:(NSString *)balance finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取设置止盈止损提示信息*/
- (void)reqFollowOrderUpdateOptionTips:(id)delegate orderId:(NSString *)orderId stopWin:(NSString *)stopWin stopLoss:(NSString *)stopLoss finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 修改设置*/
- (void)reqFollowOrderUpdateOptions:(id)delegate orderId:(NSString *)orderId maxFollowBalance:(NSString *)maxFollowBalance stopWin:(NSString *)stopWin stopLoss:(NSString *)stopLoss finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 跟单记录*/
- (void)reqFollowOrderRecordList:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;


#pragma mark - 跟单用户数据
/** 跟单用户基本信息*/
- (void)reqFollowOrderUsersBaseInfo:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 跟单用户持仓成本*/
- (void)reqFollowOrderUsersHoldCost:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 跟单用户跟单资金*/
- (void)reqFollowOrderUsersFollowBalance:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 跟单用户持币市值*/
- (void)reqFollowOrderUsersMarket:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;





@end


