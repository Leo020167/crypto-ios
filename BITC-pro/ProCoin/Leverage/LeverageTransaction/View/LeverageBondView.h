//
//  LeverageBondView.h
//  BYY
//
//  Created by Hay on 2019/12/24.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeverageBondViewDelegate <NSObject>

@optional
- (void)leverageBondBalanceDidChanged:(NSString *)bondBalance;

@end


@interface LeverageBondView : UIView

@property (assign, nonatomic) id<LeverageBondViewDelegate> delegate;


- (void)reloadLeverageBondData:(NSArray *)bondData;


@end


