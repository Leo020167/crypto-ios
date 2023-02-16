//
//  P2PAlertView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 3/29/16.
//  Copyright © 2016 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRBaseView.h"

@class P2PAlertView;

@protocol P2PAlertViewDelegate <NSObject>

@optional
- (void)p2pAlertView:(P2PAlertView *)alertView okButtonClicked:(id)sender;
- (void)p2pAlertView:(P2PAlertView *)alertView cancelButtonClicked:(id)sender;

@end

@interface P2PAlertView : TJRBaseView

@property (assign, nonatomic) id<P2PAlertViewDelegate> delegate;

- (void)show:(UIView*)superView;

- (void)reloadUIData:(NSString*)title tips1:(NSString*)tips1 tips2:(NSString*)tips2 btnTips:(NSString*)btnTips  btnLeftTips:(NSString*)btnLeftTips  btnRightTips:(NSString*)btnRightTips;

- (void)reloadUIData:(NSString*)time;
@end
