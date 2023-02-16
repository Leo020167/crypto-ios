//
//  FPDMarkPaidAlertView.h
//  Cropyme
//
//  Created by Hay on 2019/7/27.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FPDMarkPaidAlertViewDelegate <NSObject>

@optional
- (void)markPaidAlertViewDidCertain;
- (void)markPaidAlertViewDidCancel;

@end

NS_ASSUME_NONNULL_BEGIN

@interface FPDMarkPaidAlertView : UIView

@property (assign, nonatomic) id<FPDMarkPaidAlertViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
