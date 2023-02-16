//
//  FODModifyInfoView.h
//  Cropyme
//
//  Created by Hay on 2019/6/3.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TradeConfigInfoEntity.h"

@class FODModifyInfoView;

@protocol FODModifyInfoViewDelegate <NSObject>

@optional

- (void)modifyInfoViewCommintDidSelectedWithBalance:(NSString *)balance modifyInfoView:(FODModifyInfoView *)view;
- (void)modifyInfoViewShowErrorMsg:(NSString *)msg;

@end



@interface FODModifyInfoView : UIView

@property (assign, nonatomic) id<FODModifyInfoViewDelegate> delegate;

- (void)updateModifyInfoViewData:(TradeConfigInfoEntity *)entity;

- (void)showModifyViewWithAnimationInView:(UIView *)superView;

- (void)dismissModifyViewWithAnimation;

@end


