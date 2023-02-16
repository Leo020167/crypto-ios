//
//  NetWorkManage+Store.m
//  BYY
//
//  Created by Hay on 2019/12/18.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "NetWorkManage+Store.h"

@implementation NetWorkManage (Store)

- (NSString *)fullApiStoreUrl:(NSString *)apiUrl
{
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}

#pragma mark - 获取某个币种存币宝的信息
- (void)reqStoreSymbolAssetInfo:(id)delegate storeSymbol:(NSString *)storeSymbol pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
{
    [taojinHttpBase doHttpGETForJson:[self fullApiStoreUrl:@"prybar/store/asset"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"storeSymbol" value:storeSymbol],
                                      [BasicNameValuePair setName:@"pageNo" value:pageNo], nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


#pragma mark - 获取存取币配置信息
- (void)reqStoreTransferConfig:(id)delegate storeSymbol:(NSString *)storeSymbol inOut:(NSString *)inOut finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[self fullApiStoreUrl:@"prybar/store/config"]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"storeSymbol" value:storeSymbol],
                                      [BasicNameValuePair setName:@"inOut" value:inOut], nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 转入请求
- (void)reqStoreCreateTransferIn:(id)delegate storeSymbol:(NSString *)storeSymbol amount:(NSString *)amount finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiStoreUrl:@"prybar/store/createIn"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"storeSymbol" value:storeSymbol],
                                       [BasicNameValuePair setName:@"amount" value:amount],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

#pragma mark - 转出请求
- (void)reqStoreCreateTransferOut:(id)delegate storeSymbol:(NSString *)storeSymbol amount:(NSString *)amount selectItem:(NSString *)selectItem finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpPOSTForJson:[self fullApiStoreUrl:@"prybar/store/createOut"]
                               params:[self fetchUrlParam:
                                       [BasicNameValuePair setName:@"storeSymbol" value:storeSymbol],
                                       [BasicNameValuePair setName:@"amount" value:amount],
                                       [BasicNameValuePair setName:@"selectItem" value:selectItem],nil]
                             delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}
@end
