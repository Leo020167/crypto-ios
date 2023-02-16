//
//  QuotationTransactionHeaderView.h
//  Cropyme
//
//  Created by Hay on 2019/6/3.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinQuotationDataEntity.h"
#import "CoinTradeGearEntity.h"
#import "PCTradeCheckOutModel.h"
#import "PCTradeConfigModel.h"


@protocol QuotationTransactionHeaderViewDelegate <NSObject>

@optional
- (void)transactionHeaderViewDidChangedOrderType:(NSString *_Nonnull)orderType inputPrice:(NSString *_Nullable)inputPrice handAmount:(NSString *_Nullable)handAmount multiNum:(NSString *_Nonnull)multiNum buySell:(NSString *_Nonnull)buySell; //订单类型,输入价格或数量倍数等发生变化,主要用来checkout数据
- (void)commitOrderButtonPressedOrderType:(NSString *_Nonnull)orderType inputPrice:(NSString *_Nullable)inputPrice handAmount:(NSString *_Nullable)handAmount multiNum:(NSString *_Nonnull)multiNum buySell:(NSString *_Nonnull)buySell openBond:(NSString *_Nullable)openBond;    //提交数据
- (void)transactionHeaderViewTransferCoinButtonDidPressed;

@end

NS_ASSUME_NONNULL_BEGIN

@interface QuotationTransactionHeaderView : UIView

/// 倍数按钮
@property (assign, nonatomic) id<QuotationTransactionHeaderViewDelegate> delegate;

/** transactionHeaderView当前高度*/
- (CGFloat)transactionHeaderViewCurrentHeight;

/** 初始化页面数据*/
- (void)initHeaderViewWithbuySell:(NSString *)buySell;

/** 初始化设置价格文本*/
- (void)initPriceTextField:(NSString *)initPrice;

/** 更新交易配置*/
- (void)reloadHeaderViewConfig:(PCTradeConfigModel *)configEntity;

/** 更新档位和当前行情数据*/
- (void)realoadGearData:(NSArray *)buyGearData  sellGearData:(NSArray *)sellGearData currentQuotation:(CoinQuotationDataEntity *)quotationEntity;

/** 更新计算数据*/
- (void)reloadCheckOutData:(PCTradeCheckOutModel *)checkOutEntity;

/** 弹下键盘*/
- (void)inputTextResignFirstResponder;

/** 还原控件值*/
- (void)resetDefaultUIValue;
@end

NS_ASSUME_NONNULL_END
