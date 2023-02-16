//
//  FPDCancelOrderAlertView.h
//  Cropyme
//
//  Created by Hay on 2019/7/27.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FPDCancelOrderAlertViewDelegate <NSObject>

@optional
- (void)cancelOrderAlertViewDidCertain;
- (void)cancelOrderAlertViewDidCancel;

@end

NS_ASSUME_NONNULL_BEGIN

@interface FPDCancelOrderAlertView : UIView

@property (assign, nonatomic) id<FPDCancelOrderAlertViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
