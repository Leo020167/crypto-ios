//
//  NetWorkManage+TransferCoin.m
//  ProCoin
//
//  Created by Hay on 2020/2/21.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "NetWorkManage+TransferCoin.h"

@implementation NetWorkManage (TransferCoin)

- (NSString *)fullApiBaseUrlTransferCoin:(NSString *)apiUrl
{
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}

/** 获取可划转的账户类型
 账户类型：digital(数字货币账户)，stock(股指期货账户)，followdigital(跟单数字货币账户)，followstock(跟单股指期货账户)，balance(余额账户)
 */
- (void)reqTransferAccountList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTransferCoin:@"account/listAccountType"]
                              params:[self fetchUrlParam:nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 获取账户可用数量*/
- (void)reqTransferAccountHoldAmount:(id)delegate accountType:(NSString *)accountType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTransferCoin:@"account/outHoldAmount"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"accountType" value:accountType],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 账户划转

/// 获取可划转的币种
- (void)reqTransferSymbols:(id)delegate fromAccountType:(NSString *)fromAccountType
                       toAccountType:(NSString *)toAccountType
                    finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTransferCoin:@"account/getTransferSymbols"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"fromAccountType" value:fromAccountType],
                                      [BasicNameValuePair setName:@"toAccountType" value:toAccountType],nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


- (void)reqAccountTransfer:(id)delegate amount:(NSString *)amount symbol:(NSString *)symbol fromAccountType:(NSString *)fromAccountType toAccountType:(NSString *)toAccountType payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiBaseUrlTransferCoin:@"account/transfer"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"amount" value:amount],
                                       [BasicNameValuePair setName:@"symbol" value:symbol],
                                       [BasicNameValuePair setName:@"fromAccountType" value:fromAccountType],
                                       [BasicNameValuePair setName:@"toAccountType" value:toAccountType],
                                       [BasicNameValuePair setName:@"payPass" value:payPass],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 划转记录*/
- (void)reqTransferRecord:(id)delegate fromAccountType:(NSString *)fromAccountType toAccountType:(NSString *)toAccountType pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiBaseUrlTransferCoin:@"account/queryTransferList"]
      params:[self fetchUrlParam:
              [BasicNameValuePair setName:@"fromAccountType" value:fromAccountType],
              [BasicNameValuePair setName:@"toAccountType" value:toAccountType],
              [BasicNameValuePair setName:@"pageNo" value:pageNo],nil]
    delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}
@end
