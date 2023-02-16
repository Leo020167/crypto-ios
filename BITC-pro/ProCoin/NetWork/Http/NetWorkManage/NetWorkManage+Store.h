//
//  NetWorkManage+Store.h
//  BYY
//
//  Created by Hay on 2019/12/18.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "NetWorkManage.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetWorkManage (Store)


/** 获取某个币种存币宝的信息*/
- (void)reqStoreSymbolAssetInfo:(id)delegate storeSymbol:(NSString *)storeSymbol pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取存取币配置信息*/
//inOut=1(转入)\-1(转出)
- (void)reqStoreTransferConfig:(id)delegate storeSymbol:(NSString *)storeSymbol inOut:(NSString *)inOut finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 转入请求*/
- (void)reqStoreCreateTransferIn:(id)delegate storeSymbol:(NSString *)storeSymbol amount:(NSString *)amount finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 转出请求*/
//参数说明:selectItem=0代表选择本金转出，selectItem=1代表选择收益转出
- (void)reqStoreCreateTransferOut:(id)delegate storeSymbol:(NSString *)storeSymbol amount:(NSString *)amount selectItem:(NSString *)selectItem finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
@end

NS_ASSUME_NONNULL_END
