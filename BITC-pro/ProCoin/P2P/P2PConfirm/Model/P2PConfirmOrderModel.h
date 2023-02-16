//
//  P2PConfirmOrderModel.h
//  ProCoin
//
//  Created by Hay on 2020/3/6.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface P2PConfirmOrderModel : TJRBaseEntity

@property (copy, nonatomic) NSString *adId;
@property (copy, nonatomic) NSString *alertTip;
@property (copy, nonatomic) NSString *amount;
@property (copy, nonatomic) NSString *buySell;
@property (copy, nonatomic) NSString *buySellValue;
@property (copy, nonatomic) NSString *buyUserId;
@property (copy, nonatomic) NSString *createTime;
@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *paySecondTime;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *sellUserId;
@property (copy, nonatomic) NSString *showRealName;
@property (copy, nonatomic) NSString *showUserId;
@property (copy, nonatomic) NSString *showUserLogo;
@property (copy, nonatomic) NSString *showUserName;
@property (assign, nonatomic) NSInteger state;
@property (copy, nonatomic) NSString *stateTip;
@property (copy, nonatomic) NSString *stateValue;
@property (copy, nonatomic) NSString *tolPrice;

@property (retain, nonatomic) NSMutableArray* payWayArray;

/// 币种符号
@property (nonatomic, copy) NSString *currencySign;

@end

NS_ASSUME_NONNULL_END
