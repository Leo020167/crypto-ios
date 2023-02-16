//
//  CoinQuotationSegmentDealController.h
//  ProCoin
//
//  Created by Hay on 2020/3/26.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "YNPageTableView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYCoinQuotationSegmentDealController : TJRBaseViewController

@property (retain, nonatomic) IBOutlet YNPageTableView *dealTableView;

- (void)reloadDealData:(NSArray *)dealData;

@end

NS_ASSUME_NONNULL_END
