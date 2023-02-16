//
//  MarketInfoHeaderView.h
//  Cropyme
//
//  Created by Hay on 2019/8/9.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MarketInfoHeaderView : UIView

- (void)reloadInfoHeaderViewData:(NSArray *)chartArray totalMarket:(NSString *)totalMarket totalMarketCNY:(NSString *)totalMarketCNY;

@end

