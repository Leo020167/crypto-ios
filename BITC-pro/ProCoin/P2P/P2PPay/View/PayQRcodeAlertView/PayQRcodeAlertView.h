//
//  PayQRcodeAlertView.h
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PayQRcodeAlertView : UIView

- (void)showInView:(UIView *)view;

- (void)dismissView;

- (void)reloadUIData:(NSString*)qrcodeUrl;
@end

NS_ASSUME_NONNULL_END
