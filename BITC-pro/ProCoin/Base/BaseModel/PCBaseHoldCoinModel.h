//
//  PCBaseHoldCoinModel.h
//  ProCoin
//
//  Created by Hay on 2020/2/19.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"




@interface PCBaseHoldCoinModel : TJRBaseEntity

@property (copy, nonatomic) NSString *buySell;              //买卖方向
@property (copy, nonatomic) NSString *buySellValue;         //买卖方向文本显示
@property (copy, nonatomic) NSString *profitRate;                 //收益率
@property (copy, nonatomic) NSString *openHand;             //开仓手数
@property (copy, nonatomic) NSString *openPrice;            //开仓价
@property (copy, nonatomic) NSString *profit;               //盈亏
@property (copy, nonatomic) NSString *symbol;               //交易对
@property (copy, nonatomic) NSString *orderId;              //订单id

@end


