//
//  ExtractCoinDataEntity.h
//  Cropyme
//
//  Created by Hay on 2019/6/13.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface ExtractCoinDataEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *amount;                       //可输入的最大提币数量
@property (copy, nonatomic) NSString *maxWithdrawDecimals;          //输入提现最大小数点位数
@property (copy, nonatomic) NSString *minWithdrawAmt;               //最小提币数量
@property (copy, nonatomic) NSString *symbol;                       //币种类
@property (copy, nonatomic) NSString *withdrawFee;                  //手续费

@end



//"availableAmount": "102.12",
//"addressList": [{
//    "address": "1231231231",
//    "createTime": "1669814953",
//    "id": "1597945848128417793",
//    "remark": "111",
//    "symbol": "BTC",
//    "userId": "2009591"
//}],
//"fee": "1",
//"frozenAmount": "23102.221"
@interface CoinWithdrawConfigAddress : NSObject

@property (copy, nonatomic) NSString *addressId;
/// 地址
@property (copy, nonatomic) NSString *address;
/// 币种
@property (nonatomic, copy) NSString *symbol;
/// 链
@property (nonatomic, copy) NSString *chainType;
@property (nonatomic, copy) NSString *remark;

@property (nonatomic, copy) NSString *userId;
@end
 

@interface CoinWithdrawConfigEntity : NSObject

/// 可用
@property (copy, nonatomic) NSString *availableAmount;
/// 冻结
@property (copy, nonatomic) NSString *frozenAmount;
/// 地址列表
@property (nonatomic, copy) NSArray<CoinWithdrawConfigAddress *> *addressList;

/// 手续费
@property (nonatomic, copy) NSString *fee;


@end
