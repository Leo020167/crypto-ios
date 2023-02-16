//
//  PayAlertView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 1/27/16.
//  Copyright © 2016 淘金路. All rights reserved.
//

#import "TJRBaseView.h"

@class PayAlertView;

@protocol PayAlertViewDelegate <NSObject>

- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password;

- (void)payAlertView:(PayAlertView *)toolView forgetButtonClicked:(id)sender;

@end

@interface PayAlertView : TJRBaseView

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *tipsLabel;

@property (assign, nonatomic) id<PayAlertViewDelegate> delegate;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate;
- (void)show;
- (void)reset;
- (void)close;
@end
