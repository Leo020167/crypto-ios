//
//  NetWorkManage+P2P.h
//  ProCoin
//
//  Created by Hay on 2020/2/21.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "NetWorkManage.h"



@interface NetWorkManage (P2P)

- (void)reqP2PADList:(id)delegate buySell:(NSString *)buySell filterPayWay:(NSString *)filterPayWay filterCny:(NSString *)filterCny type:(NSString *)type pageNo:(NSString *)pageNo currencyType:(NSString *)currencyType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

- (void)reqP2PCreateOrder:(id)delegate buySell:(NSString *)buySell adId:(NSString *)adId amount:(NSString *)amount price:(NSString *)price showReceiptType:(NSString *)showReceiptType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

- (void)reqP2PGetOrderDetail:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark -【广告市场】付款第1步：点击“订单取消”按钮
- (void)reqP2PCancelOrder:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 【广告市场】付款第1步：点击“去付款”按钮进入到付款页面
- (void)reqP2PToPayOrder:(id)delegate orderId:(NSString *)orderId showUserId:(NSString *)showUserId showPaymentId:(NSString *)showPaymentId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 【广告市场】付款第2步：点击“我已付款成功”按钮
- (void)reqP2PToMarkPayOrderSuccess:(id)delegate orderId:(NSString *)orderId  finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;


#pragma mark - 【广告市场】出售第2步：点击“我确认已收到付款”按钮
- (void)reqP2PToConfirmReceivedPay:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;


#pragma mark -【广告市场】我的订单历史记录
- (void)reqP2PFindOrderList:(id)delegate buySell:(NSString *)buySell pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark -【申诉】初始化申诉理由列表
- (void)reqP2PGetInitReasonList:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark -【申诉】提交
- (void)reqP2PAppealSubmit:(id)delegate orderId:(NSString *)orderId reason:(NSString *)reason image1Url:(NSString *)image1Url image2Url:(NSString *)image2Url message:(NSString *)message finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;



#pragma mark -【收款方式】获取我的收款方式列表
- (void)reqP2PFindMyPaymentList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark -【收款方式】可选择收款(在“添加收款方式”时调用)
- (void)reqP2PFindPaymentOptionList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;


#pragma mark -【收款方式】添加或修改我的收款方式
- (void)reqP2PSavePayment:(id)delegate receiptType:(NSString *)receiptType paymentId:(NSString *)paymentId receiptName:(NSString *)receiptName receiptNo:(NSString *)receiptNo bankName:(NSString *)bankName qrCodeUrl:(NSString *)qrCodeUrl finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;


#pragma mark -【收款方式】删除我的收款方式
- (void)reqP2PPaymentDelete:(id)delegate paymentId:(NSString *)paymentId  finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark -【收款方式】获取我的收款方式列表
- (void)reqP2PGetCertificationInfo:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark -【商家认证】申请成为商家
- (void)reqP2PCertificationAuthenticate:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark -【商家认证】撤销成为商家
- (void)reqP2PApplyForCancellation:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark -【我的广告】我的广告列表
- (void)reqP2PFindMyAdList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark -【我的广告】我的广告详情
- (void)reqP2PGetMyAdInfo:(id)delegate adId:(NSString *)adId  finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark -【我的广告】我的广告设置上下架
- (void)reqP2PSetOnline:(id)delegate adId:(NSString *)adId online:(NSString *)online  finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark -【我的广告】删除我的广告
- (void)reqP2PDelMyAd:(id)delegate adId:(NSString *)adId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark -【我的广告】发布广告
- (void)reqP2PAddMyAd:(id)delegate buySell:(NSString *)buySell price:(NSString *)price  minCny:(NSString *)minCny maxCny:(NSString *)maxCny amount:(NSString *)amount  payWay:(NSString *)payWay content:(NSString *)content finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;


#pragma mark -【我的广告】编辑广告
- (void)reqP2PUpdateMyAd:(id)delegate adId:(NSString *)adId buySell:(NSString *)buySell price:(NSString *)price  minCny:(NSString *)minCny maxCny:(NSString *)maxCny amount:(NSString *)amount  payWay:(NSString *)payWay content:(NSString *)content finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark -【我的广告】获取广告最高最低价格
- (void)reqP2PGetAdPrice:(id)delegate buySell:(NSString *)buySell finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

@end


