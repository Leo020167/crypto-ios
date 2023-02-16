//
//  TJRHeadView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-5-5.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRHeadView.h"

@implementation TJRHeadView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		[self initilization];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

	if (self) {
		[self initilization];
	}

	return self;
}

- (void)dealloc {
	[vipImageView release];
	[_imageView release];
	[super dealloc];
}

- (void)initilization {
	[self setBackgroundColor:[UIColor clearColor]];
	CGRect rect = self.frame;
	float factor = 0.95;
	_imageView = [[TJRImageAndDownFile alloc] initWithFrame:CGRectMake(0, 0, rect.size.width * factor, rect.size.height * factor)];

    _imageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
	_imageView.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
	[self addSubview:_imageView];

	factor = 0.5;
	vipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tjrpublic_logo_vip"]];
	[vipImageView setFrame:CGRectMake(rect.size.width - rect.size.width * factor, 0, rect.size.width * factor, rect.size.height * factor)];
        vipImageView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin ;
	vipImageView.hidden = YES;
	[self addSubview:vipImageView];
    
    vipImageView.userInteractionEnabled = NO;
}


- (void)showImageViewWithURL:(NSString *)imageUrl canTouch:(BOOL)_canTouch userid:(NSString *)_userid isCornerRadius:(BOOL)_isCornerRadius userLevel:(NSInteger)_userLevel {
	 /* userLevel 0为普通用户，1为认证用户 */
	[self setIsHiddenAccordingToUserLevel:_userLevel];
	[_imageView showImageViewWithURL:imageUrl canTouch:_canTouch userid:_userid isCornerRadius:_isCornerRadius];
}

#pragma mark - 根据等级设置vipImageView是否隐藏
- (void)setIsHiddenAccordingToUserLevel:(NSInteger)_userLevel {
	 /* userLevel 0为普通用户，1为认证用户 */
	switch (_userLevel) {
		case 0:
			vipImageView.hidden = YES;
			break;

		case 1:
			vipImageView.hidden = NO;
			break;

		default:
			break;
	}
}

- (void)showImageViewWithURL:(NSString *)imageUrl userId:(NSString *)_userId userLevel:(NSInteger)_userLevel showType:(TJRImageAndDownShowType)showType {
    [self setIsHiddenAccordingToUserLevel:_userLevel];

}

- (void)showImageViewWithUserInfo:(UserInfo *)userInfo showType:(TJRImageAndDownShowType)showType {
    [self setIsHiddenAccordingToUserLevel:!userInfo ? 0 :userInfo.userLevel];

}

- (void)showImageViewWithUserInfo:(UserInfo *)userInfo canTouch:(BOOL)_canTouch {
    [self setIsHiddenAccordingToUserLevel:!userInfo ? 0 :userInfo.userLevel];
    [_imageView showImageViewWithURL:!userInfo ? nil : userInfo.headurl canTouch:_canTouch userid:!userInfo ? nil : userInfo.userId isCornerRadius:NO];
}

- (void)showImageViewWithUserInfo:(UserInfo *)userInfo canTouch:(BOOL)_canTouch isCornerRadius:(BOOL)_isCornerRadius {
    [self setIsHiddenAccordingToUserLevel:!userInfo ? 0 :userInfo.userLevel];
    [_imageView showImageViewWithURL:!userInfo ? nil : userInfo.headurl canTouch:_canTouch userid:!userInfo ? nil : userInfo.userId isCornerRadius:_isCornerRadius];
}
@end

