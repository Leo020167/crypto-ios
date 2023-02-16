//
//  CMDDepositWayView.h
//  Cropyme
//
//  Created by Hay on 2019/7/26.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FundExchangeWayEntity.h"

@protocol CMDDepositWayViewDelegate <NSObject>

@optional
- (void)depositWayViewDidSelectedWayWithIndex:(NSInteger)index;

@end


@interface CMDDepositWayView : UIView

@property (assign, nonatomic) id<CMDDepositWayViewDelegate> delegate;

/** 显示页面*/
- (void)showDepositWayViewInView:(UIView *)superView wayCount:(NSInteger)wayCount;
/** 隐藏页面*/
- (void)dismissDepositWayView;

- (void)reloadDepositWayData:(NSArray *)dataArr;
@end


