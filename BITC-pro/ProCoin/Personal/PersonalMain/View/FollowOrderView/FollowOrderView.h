//
//  FollowOrderView.h
//  Cropyme
//
//  Created by Hay on 2019/7/23.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FollowOrderViewRiskTipsButtonType  =  1,
    FollowOrderViewFollowOrderRulesButtonType,
    FollowOrderViewFollowOrderButtonType,
}FollowOrderViewButtonType;

#define FollowOrderInputPriceTextKey     @"FollowOrderInputPriceTextKey"

@class FollowOrderView;

@protocol FollowOrderViewDelegate <NSObject>

@optional

- (void)followOrderViewButtonDidPressedWithType:(FollowOrderViewButtonType)buttonType infoDic:(NSDictionary *)infoDic followOrderView:(FollowOrderView *)followOrderView;

@end

@interface FollowOrderView : UIView

@property (assign, nonatomic) id<FollowOrderViewDelegate> delegate;

#pragma mark - 显示与消失
- (void)showFollowOrderViewInView:(UIView *)view withOwnAssets:(NSString *)ownAssets minFollowBalance:(NSString *)minFollowBalance followFeeTip:(NSString *)followFeeTip;

- (void)dismissFollowOrderView;


@end


