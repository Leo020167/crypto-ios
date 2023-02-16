//
//  ExpressSellAlertView.h
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class P2POrderEntity;
@class P2PPayWayEntity;


@interface ExpressSellAlertView : UIView

- (void)showInView:(UIView *)view;

- (void)dismissView;

- (void)reloadUIData:(P2POrderEntity*)entity item:(P2PPayWayEntity*)item buySell:(NSString*)buySell amount:(NSString*)amount;

@end

NS_ASSUME_NONNULL_END
