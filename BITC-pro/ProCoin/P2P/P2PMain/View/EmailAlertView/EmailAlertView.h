//
//  EmailAlertView.h
//  ProCoin
//
//  Created by sh on 2021/7/24.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EmailAlertViewDelegate <NSObject>

- (void)emailCodeSuccess;

@end

@interface EmailAlertView : UIView

- (void)showInView:(UIView *)view;

- (void)dismissView;

@property (nonatomic, assign) id<EmailAlertViewDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
