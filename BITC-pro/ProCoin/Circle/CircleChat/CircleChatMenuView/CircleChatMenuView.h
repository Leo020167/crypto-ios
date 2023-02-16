//
//  CircleChatMenuView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 3/29/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRBaseView.h"

@class CircleChatMenuView;
@class CircleBaseDataEntity;

@protocol CircleChatMenuViewDelegate <NSObject>

@optional
- (void)chatMenuView:(CircleChatMenuView *)menuView goldButtonClicked:(id)sender;
- (void)chatMenuView:(CircleChatMenuView *)menuView stockButtonClicked:(id)sender;
- (void)chatMenuView:(CircleChatMenuView *)menuView microButtonClicked:(id)sender;


- (void)chatMenuViewOn:(CircleChatMenuView *)menuView;
- (void)chatMenuViewOff:(CircleChatMenuView *)menuView;

@end

@interface CircleChatMenuView : TJRBaseView

@property (assign, nonatomic) id<CircleChatMenuViewDelegate> delegate;
@property (retain, nonatomic) CircleBaseDataEntity *entity;
- (void)show:(UIView*)superView;
@end
