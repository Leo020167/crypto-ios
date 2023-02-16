//
//  TJRHeadView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 14-5-5.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRImageAndDownFile.h"
#import "UserInfo.h"

@interface TJRHeadView : UIImageView {
	UIImageView *vipImageView;
}
@property (retain, nonatomic) TJRImageAndDownFile *imageView;

#pragma mark - 根据等级设置vipImageView是否隐藏
- (void)setIsHiddenAccordingToUserLevel:(NSInteger)_userLevel;

- (void)showImageViewWithURL:(NSString *)imageUrl canTouch:(BOOL)_canTouch userid:(NSString *)_userid isCornerRadius:(BOOL)_isCornerRadius userLevel:(NSInteger)_userLevel;
- (void)showImageViewWithUserInfo:(UserInfo *)userInfo canTouch:(BOOL)_canTouch;
- (void)showImageViewWithUserInfo:(UserInfo *)userInfo canTouch:(BOOL)_canTouch isCornerRadius:(BOOL)_isCornerRadius;
- (void)showImageViewWithURL:(NSString *)imageUrl  userId:(NSString *)_userId userLevel:(NSInteger)_userLevel showType:(TJRImageAndDownShowType)showType;
- (void)showImageViewWithUserInfo:(UserInfo *)userInfo showType:(TJRImageAndDownShowType)showType;

@end

