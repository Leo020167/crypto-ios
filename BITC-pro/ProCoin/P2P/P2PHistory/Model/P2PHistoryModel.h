//
//  P2PHistoryModel.h
//  ProCoin
//
//  Created by Hay on 2020/3/6.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface P2PHistoryModel : TJRBaseEntity

@property (copy, nonatomic) NSString *adId;
@property (copy, nonatomic) NSString *amount;
@property (copy, nonatomic) NSString *buySell;
@property (copy, nonatomic) NSString *buySellValue;
@property (copy, nonatomic) NSString *buyUserId;
@property (copy, nonatomic) NSString *createTime;
@property (copy, nonatomic) NSString *doneTime;
@property (copy, nonatomic) NSString *expireTime;
@property (assign, nonatomic) NSInteger isAdSell;
@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *sellUserId;
@property (assign, nonatomic) NSInteger state;
@property (copy, nonatomic) NSString *stateValue;
@property (copy, nonatomic) NSString *tolPrice;

/// 私聊信息
@property (nonatomic, copy) NSString *chatTopic;

/// 币种
@property (nonatomic, copy) NSString *currencySign;

/// 消息数量
@property (nonatomic, assign) NSInteger count;

@property (retain, nonatomic) NSMutableArray* payWayArray;
@end

NS_ASSUME_NONNULL_END
