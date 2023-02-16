//
//  CoinQuotationsSegmentGearController.h
//  Cropyme
//
//  Created by Hay on 2019/9/2.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "YNPageTableView.h"

@interface CoinQuotationsSegmentGearController : TJRBaseViewController

@property (retain, nonatomic) IBOutlet YNPageTableView *gearTableView;

- (void)reloadControllerWithBuyDataArr:(NSArray *)buyDataArr sellDataArr:(NSArray *)sellDataArr;

@end

