//
//  CoinQuotationsSegmentInfoController.h
//  Cropyme
//
//  Created by Hay on 2019/9/2.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "YNPageTableView.h"
#import "CoinIntroEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoinQuotationsSegmentInfoController : TJRBaseViewController

@property (retain, nonatomic) IBOutlet YNPageTableView *infoTableView;

- (void)reloadCoinQuotationSegmentInfo:(CoinIntroEntity *)introEntity;
@end

NS_ASSUME_NONNULL_END
