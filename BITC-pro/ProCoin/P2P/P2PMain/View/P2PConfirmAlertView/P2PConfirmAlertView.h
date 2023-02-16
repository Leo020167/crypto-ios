//
//  P2PConfirmAlertView.h
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@class P2POrderEntity;

@interface P2PConfirmAlertView : TJRBaseView

- (void)showInView:(UIView *)view;

- (void)dismissView;

- (void)reloadUIData:(P2POrderEntity*)entity isBuy:(BOOL)isBuy holdAmount:(NSString*)holdAmount timeLimit:(NSString*)timeLimit;

@end

NS_ASSUME_NONNULL_END
