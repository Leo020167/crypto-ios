//
//  LeverageTransactionHeaderView.h
//  BYY
//
//  Created by Hay on 2019/12/24.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinQuotationDataEntity.h"
#import "CoinTradeGearEntity.h"
#import "LeverageCheckOutModel.h"

static NSString *LeverageTransactionTypeBuy = @"1";
static NSString *LeverageTransactionTypeSell = @"-1";

@protocol LeverageTransactionHeaderViewDelegate <NSObject>

@optional
- (void)buySellButtonDidPressedWithBuySell:(NSString *)buySell;
- (void)multiNumDidSelectedWithMultiNum:(NSString *)multiNum;
- (void)bondBalanceDidSelectedWithBondBalance:(NSString *)bondBalance;
- (void)commitOrderButtonDidPressedWithBondBalance:(NSString *)bondBalance buySell:(NSString *)buySell multiNum:(NSString *)multiNum;


@end


@interface LeverageTransactionHeaderView : UIView

@property (assign, nonatomic) id<LeverageTransactionHeaderViewDelegate> delegate;

/** 根据buySell状态初始化设置页面*/
- (void)initHeaderViewWithBuySell:(NSString *)buySell originSymbol:(NSString *)originSymbol;

/** 设置checkOut信息*/
- (void)reloadCheckOutInfo:(LeverageCheckOutModel *)checkOutInfo;

/** 设置倍数和保证金*/
- (void)reloadHeaderViewBondBalanceArr:(NSArray *)bondBalanceArr multiNumArr:(NSArray *)multiNumArr;

/** 设置可用*/
- (void)reloadHeaderViewHoldCash:(NSString *)holdCash holdUsdt:(NSString *)holdUsdt;

/** 更新档位数据 */
- (void)realoadGearData:(NSArray *)buyGearData sellGearData:(NSArray *)sellGearData currentQuotation:(CoinQuotationDataEntity *)quotationEntity;

/** 获取当前高度*/
- (CGFloat)currentLeverageTransactionHeaderViewHeight;

@end

