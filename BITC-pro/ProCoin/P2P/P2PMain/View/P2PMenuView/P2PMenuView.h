//
//  P2PMenuView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 3/29/16.
//  Copyright © 2016 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRBaseView.h"

@class P2PMenuView;

@protocol P2PMenuViewDelegate <NSObject>

@optional
- (void)p2pMenuView:(P2PMenuView *)menuView adButtonClicked:(id)sender;
- (void)p2pMenuView:(P2PMenuView *)menuView customerButtonClicked:(id)sender;
- (void)p2pMenuView:(P2PMenuView *)menuView moneyButtonClicked:(id)sender;

@end

@interface P2PMenuView : TJRBaseView

@property (assign, nonatomic) id<P2PMenuViewDelegate> delegate;

- (void)show:(UIView*)superView;
@end
