//
//  FODFollowOrderSettingView.h
//  Cropyme
//
//  Created by Hay on 2019/6/17.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowOrderDetailEntity.h"

@class FODFollowOrderSettingView;

@protocol FODFollowOrderSettingViewDelegate <NSObject>

@optional

- (void)settingViewCommitButtonDidSelectedWithAmount:(NSString *)amount stopWin:(NSString *)stopWin stopLoss:(NSString *)stopLoss settingView:(FODFollowOrderSettingView *)settingView;
- (void)settingViewShowErrorMsg:(NSString *)msg;

@end



@interface FODFollowOrderSettingView : UIView

@property (assign, nonatomic) id<FODFollowOrderSettingViewDelegate> delegate;

- (void)updateSettingViewData:(FollowOrderDetailEntity *)entity usdtRate:(NSString *)usdtRate;

- (void)showSettingViewWithAnimationInView:(UIView *)superView;

- (void)dismissSettingViewWithAnimation;

@end


