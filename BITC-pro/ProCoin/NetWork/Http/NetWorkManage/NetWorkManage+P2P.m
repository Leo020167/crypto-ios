//
//  NetWorkManage+P2P.m
//  ProCoin
//
//  Created by Hay on 2020/2/21.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "NetWorkManage+P2P.h"

@implementation NetWorkManage (P2P)

- (NSString *)fullApiBaseUrlP2P:(NSString *)apiUrl
{
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}

/** 【广告市场】市场广告列表（购买，出售）
 */
- (void)reqP2PADList:(id)delegate buySell:(NSString *)buySell filterPayWay:(NSString *)filterPayWay filterCny:(NSString *)filterCny type:(NSString *)type pageNo:(NSString *)pageNo currencyType:(NSString *)currencyType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/mainad/findAdList"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"currencyType" value:currencyType],
                                      [BasicNameValuePair setName:@"buySell" value:buySell],
                                      [BasicNameValuePair setName:@"filterPayWay" value:filterPayWay],
                                      [BasicNameValuePair setName:@"filterCny" value:filterCny],
                                      [BasicNameValuePair setName:@"type" value:type],
                                      [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 【广告市场】下单
- (void)reqP2PCreateOrder:(id)delegate buySell:(NSString *)buySell adId:(NSString *)adId amount:(NSString *)amount price:(NSString *)price showReceiptType:(NSString *)showReceiptType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/mainad/createOrder"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"buySell" value:buySell],
                                      [BasicNameValuePair setName:@"adId" value:adId],
                                      [BasicNameValuePair setName:@"amount" value:amount],
                                      [BasicNameValuePair setName:@"showReceiptType" value:showReceiptType],
                                      [BasicNameValuePair setName:@"price" value:price],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 【广告市场】获取订单详情
- (void)reqP2PGetOrderDetail:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/mainad/getOrderDetail"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"orderId" value:orderId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark -【广告市场】付款第1步：点击“订单取消”按钮
- (void)reqP2PCancelOrder:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/mainad/cancelOrder"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"orderId" value:orderId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - 【广告市场】付款第1步：点击“去付款”按钮进入到付款页面
- (void)reqP2PToPayOrder:(id)delegate orderId:(NSString *)orderId showUserId:(NSString *)showUserId showPaymentId:(NSString *)showPaymentId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/mainad/toPayOrder"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"orderId" value:orderId],
                                      [BasicNameValuePair setName:@"showUserId" value:showUserId],
                                      [BasicNameValuePair setName:@"showPaymentId" value:showPaymentId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - 【广告市场】付款第2步：点击“我已付款成功”按钮
- (void)reqP2PToMarkPayOrderSuccess:(id)delegate orderId:(NSString *)orderId  finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/mainad/toMarkPayOrderSuccess"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"orderId" value:orderId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - 【广告市场】出售第2步：点击“我确认已收到付款”按钮
- (void)reqP2PToConfirmReceivedPay:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/mainad/toConfirmReceivedPay"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"orderId" value:orderId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark -【广告市场】我的订单历史记录
- (void)reqP2PFindOrderList:(id)delegate buySell:(NSString *)buySell pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/mainad/findOrderList"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"buySell" value:buySell],
                                      [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark -【申诉】初始化申诉理由列表
- (void)reqP2PGetInitReasonList:(id)delegate orderId:(NSString *)orderId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/mainad/getInitAppealList"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"orderId" value:orderId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark -【申诉】提交
- (void)reqP2PAppealSubmit:(id)delegate orderId:(NSString *)orderId reason:(NSString *)reason image1Url:(NSString *)image1Url image2Url:(NSString *)image2Url message:(NSString *)message finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/mainad/submitAppeal"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"orderId" value:orderId],
                                      [BasicNameValuePair setName:@"reason" value:reason],
                                      [BasicNameValuePair setName:@"message" value:message],
                                      [BasicNameValuePair setName:@"image2Url" value:image2Url],
                                      [BasicNameValuePair setName:@"image1Url" value:image1Url],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark -【收款方式】获取我的收款方式列表
- (void)reqP2PFindMyPaymentList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/payment/findMyPaymentList"]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark -【收款方式】可选择收款(在“添加收款方式”时调用)
- (void)reqP2PFindPaymentOptionList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/payment/findPaymentOptionList"]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark -【收款方式】添加或修改我的收款方式
- (void)reqP2PSavePayment:(id)delegate receiptType:(NSString *)receiptType paymentId:(NSString *)paymentId receiptName:(NSString *)receiptName receiptNo:(NSString *)receiptNo bankName:(NSString *)bankName qrCodeUrl:(NSString *)qrCodeUrl finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/payment/savePayment"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"receiptType" value:receiptType],
                                      [BasicNameValuePair setName:@"paymentId" value:paymentId],
                                      [BasicNameValuePair setName:@"receiptName" value:receiptName],
                                      [BasicNameValuePair setName:@"receiptNo" value:receiptNo],
                                      [BasicNameValuePair setName:@"bankName" value:bankName],
                                      [BasicNameValuePair setName:@"qrCodeUrl" value:qrCodeUrl],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark -【收款方式】删除我的收款方式
- (void)reqP2PPaymentDelete:(id)delegate paymentId:(NSString *)paymentId  finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/payment/delete"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"paymentId" value:paymentId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark -【收款方式】获取我的收款方式列表
- (void)reqP2PGetCertificationInfo:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/certification/getCertificationInfo"]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark -【商家认证】申请成为商家
- (void)reqP2PCertificationAuthenticate:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/certification/authenticate"]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark -【商家认证】撤销成为商家
- (void)reqP2PApplyForCancellation:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/certification/applyForCancellation"]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark -【我的广告】我的广告列表
- (void)reqP2PFindMyAdList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/myad/findMyAdList"]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark -【我的广告】我的广告详情
- (void)reqP2PGetMyAdInfo:(id)delegate adId:(NSString *)adId  finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/myad/getMyAdInfo"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"adId" value:adId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark -【我的广告】我的广告设置上下架
- (void)reqP2PSetOnline:(id)delegate adId:(NSString *)adId online:(NSString *)online  finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/myad/setOnline"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"adId" value:adId],
                                      [BasicNameValuePair setName:@"online" value:online],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark -【我的广告】删除我的广告
- (void)reqP2PDelMyAd:(id)delegate adId:(NSString *)adId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/myad/delMyAd"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"adId" value:adId],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark -【我的广告】发布广告
- (void)reqP2PAddMyAd:(id)delegate buySell:(NSString *)buySell price:(NSString *)price  minCny:(NSString *)minCny maxCny:(NSString *)maxCny amount:(NSString *)amount  payWay:(NSString *)payWay content:(NSString *)content finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/myad/addMyAd"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"buySell" value:buySell],
                                      [BasicNameValuePair setName:@"price" value:price],
                                      [BasicNameValuePair setName:@"minCny" value:minCny],
                                      [BasicNameValuePair setName:@"maxCny" value:maxCny],
                                      [BasicNameValuePair setName:@"amount" value:amount],
                                      [BasicNameValuePair setName:@"payWay" value:payWay],
                                      [BasicNameValuePair setName:@"content" value:content],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark -【我的广告】编辑广告
- (void)reqP2PUpdateMyAd:(id)delegate adId:(NSString *)adId buySell:(NSString *)buySell price:(NSString *)price  minCny:(NSString *)minCny maxCny:(NSString *)maxCny amount:(NSString *)amount  payWay:(NSString *)payWay content:(NSString *)content finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/myad/updateMyAd"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"adId" value:adId],
                                      [BasicNameValuePair setName:@"buySell" value:buySell],
                                      [BasicNameValuePair setName:@"price" value:price],
                                      [BasicNameValuePair setName:@"minCny" value:minCny],
                                      [BasicNameValuePair setName:@"maxCny" value:maxCny],
                                      [BasicNameValuePair setName:@"amount" value:amount],
                                      [BasicNameValuePair setName:@"payWay" value:payWay],
                                      [BasicNameValuePair setName:@"content" value:content],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark -【我的广告】获取广告最高最低价格
- (void)reqP2PGetAdPrice:(id)delegate buySell:(NSString *)buySell finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlP2P:@"otc/myad/getAdPrice"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"buySell" value:buySell],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

@end
