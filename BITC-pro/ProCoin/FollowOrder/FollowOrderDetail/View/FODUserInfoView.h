//
//  FODUserInfoView.h
//  Cropyme
//
//  Created by Hay on 2019/8/27.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowOrderDetailEntity.h"

@protocol FODUserInfoViewDelegate <NSObject>

@optional
- (void)userInfoViewUserHeadLogoDidSelected:(NSString *)userId;
- (void)userInfoViewFollowOrderSettingDidSelected;

@end



@interface FODUserInfoView : UIView

@property (assign, nonatomic) id<FODUserInfoViewDelegate> delegate;

- (void)reloadUserInfoData:(FollowOrderDetailEntity *)detailEntity isLimitFunction:(BOOL)isLimitFunction;

@end


