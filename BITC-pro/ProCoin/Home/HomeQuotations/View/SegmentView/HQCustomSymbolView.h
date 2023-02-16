//
//  HQCustomSymbolView.h
//  BYY
//
//  Created by Hay on 2019/10/22.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeQuotationsSortHeaderView.h"

@protocol HQCustomSybolViewDelegate <NSObject>

@optional
- (void)customSymbolViewLoginButtonPressed;
- (void)customSymbolViewSymbolDidSelected:(NSString *)symbol originSymbol:(NSString *)originSymbol marketType:(NSString *)marketType;
- (void)customSymbolViewSortButtonDidSelectedWithSortField:(NSString *)sortField sortState:(NSString *)sortState;
@end


@interface HQCustomSymbolView : UIView

@property (assign, nonatomic) id<HQCustomSybolViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

/** 未登录数据 */
- (void)customSymbolViewDidNotLoginData;

/** 重新加载数据 */
- (void)reloadCustomSymbolViewData:(NSArray *)dataArr;

- (SortButtonState)customSymbolViewCurrentSortState;

- (NSString *)customSymbolViewCurrentSortField;

@end

