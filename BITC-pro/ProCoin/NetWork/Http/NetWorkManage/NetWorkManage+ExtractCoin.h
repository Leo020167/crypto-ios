//
//  NetWorkManage+ExtractCoin.h
//  Cropyme
//
//  Created by Hay on 2019/6/13.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "NetWorkManage.h"



@interface NetWorkManage (ExtractCoin)

/** 获取冲提币记录*/
- (void)reqCoinOperationRecord:(id)delegate inOut:(NSString *)inOut pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取币种列表 inOut(1充币,-1提币) */
- (void)reqDepositeWithdrawCoinList:(id)delegate inOut:(NSString *)inOut finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 取消提币*/
- (void)reqCancelExtractCoin:(id)delegate withdrawId:(NSString *)withdrawId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取提币或充币信息(地址、手续费、最小量等等) */
- (void)reqDepositeWithdrawCoinBaseInfo:(id)delegate symbol:(NSString *)symbol inOut:(NSString *)inOut chainType:(NSString *)chainType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 提币操作*/
- (void)reqSubmitExtractCoin:(id)delegate symbol:(NSString *)symbol amount:(NSString *)amount address:(NSString *)address chainType:(NSString *)chainType payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 提币记录 */
- (void)reqExtractCoinRecordList:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;



@end

//@interface NetWorkManage (Pledge)
//
///** 获取冲提币记录*/
//- (void)reqCoinOperationRecord:(id)delegate inOut:(NSString *)inOut pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
//
///** 获取币种列表 inOut(1充币,-1提币) */
//- (void)reqPledgeList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
//
///** 取消提币*/
//- (void)reqCancelExtractCoin:(id)delegate withdrawId:(NSString *)withdrawId finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
//
///** 获取提币或充币信息(地址、手续费、最小量等等) */
//- (void)reqDepositeWithdrawCoinBaseInfo:(id)delegate symbol:(NSString *)symbol inOut:(NSString *)inOut chainType:(NSString *)chainType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
//
///** 提币操作*/
//- (void)reqSubmitExtractCoin:(id)delegate symbol:(NSString *)symbol amount:(NSString *)amount address:(NSString *)address chainType:(NSString *)chainType payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
//
///** 提币记录 */
//- (void)reqExtractCoinRecordList:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
//
//@end

