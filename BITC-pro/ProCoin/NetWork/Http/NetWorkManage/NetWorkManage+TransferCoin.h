//
//  NetWorkManage+TransferCoin.h
//  ProCoin
//
//  Created by Hay on 2020/2/21.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "NetWorkManage.h"



@interface NetWorkManage (TransferCoin)

/** 获取可划转的账户类型
    账户类型：digital(数字货币账户)，stock(股指期货账户)，followdigital(跟单数字货币账户)，followstock(跟单股指期货账户)，balance(余额账户)
 */
- (void)reqTransferAccountList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取账户可用数量*/
- (void)reqTransferAccountHoldAmount:(id)delegate accountType:(NSString *)accountType finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取可划转币种 */
- (void)reqTransferSymbols:(id)delegate fromAccountType:(NSString *)fromAccountType
                       toAccountType:(NSString *)toAccountType
          finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 账户划转 */
- (void)reqAccountTransfer:(id)delegate amount:(NSString *)amount  symbol:(NSString *)symbol fromAccountType:(NSString *)fromAccountType toAccountType:(NSString *)toAccountType payPass:(NSString *)payPass finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 划转记录*/
- (void)reqTransferRecord:(id)delegate fromAccountType:(NSString *)fromAccountType toAccountType:(NSString *)toAccountType pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
@end


