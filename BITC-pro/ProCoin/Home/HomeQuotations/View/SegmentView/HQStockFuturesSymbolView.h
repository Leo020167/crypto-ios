//
//  HQLeverageSymbolView.h
//  BYY
//
//  Created by Hay on 2019/12/20.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HQStockFuturesSymbolViewDelegate <NSObject>

@optional
- (void)stockFuturesSymbolViewSymbolDidSelected:(NSString *)symbol originSymbol:(NSString *)originSymbol marketType:(NSString *)marketType;
- (void)stockFuturesSymbolViewSortButtonDidSelectedWithSortField:(NSString *)sortField sortState:(NSString *)sortState;
@end

@interface HQStockFuturesSymbolView : UIView

@property (nonatomic, assign) id<HQStockFuturesSymbolViewDelegate> delegate;

#pragma mark - 更新数据
- (void)reloadStockFuturesSymbolViewData:(NSArray *)dataArr;

@end

