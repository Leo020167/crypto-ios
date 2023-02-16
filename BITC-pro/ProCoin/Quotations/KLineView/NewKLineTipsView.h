//
//  NewKLineTipsView.h
//  ProCoin
//
//  Created by Hay on 2020/5/3.
//  Copyright © 2020 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLine.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewKLineTipsView : UIView

#pragma mark - 显示数据
- (void)reloadDataWithData:(KLine *)kLineData withPriceDecimals:(NSInteger)priceDecimals;

@end

NS_ASSUME_NONNULL_END
