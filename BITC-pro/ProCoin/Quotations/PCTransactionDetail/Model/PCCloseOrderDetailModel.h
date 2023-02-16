//
//  PCCloseOrderDetailModel.h
//  ProCoin
//
//  Created by Hay on 2020/3/27.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCCloseOrderDetailModel : TJRBaseEntity


@property (copy, nonatomic) NSString *closeBail;
@property (copy, nonatomic) NSString *closePrice;       //平仓价
@property (copy, nonatomic) NSString *profit;           //平仓盈亏
@property (copy, nonatomic) NSString *closeHand;        //平仓手数
@property (copy, nonatomic) NSString *closeFee;         //平仓手续费
@property (copy, nonatomic) NSString *closeTime;        //平仓时间
@property (copy, nonatomic) NSString *profitShare;      //盈利分成
/// 亏损补贴
@property (nonatomic, copy) NSString *lossShare;


@end

NS_ASSUME_NONNULL_END
