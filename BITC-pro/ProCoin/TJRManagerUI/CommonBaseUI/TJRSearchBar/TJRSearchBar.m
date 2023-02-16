//
//  CYLSearchBar.m
//  CYLSearchViewController
//
//  Created by taojinroad on 12-8-28.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRSearchBar.h"

@implementation TJRSearchBar

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		self = [self sharedInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

	if (self) {
		self = [self sharedInit];
	}
	return self;
}

- (id)sharedInit {
	self.backgroundColor = TEXTFIELD_BACKGROUNDC0LOR;
	self.placeholder = @"搜索";
	self.keyboardType = UIKeyboardTypeDefault;
	self.showsCancelButton = NO;
	// 删除UISearchBar中的UISearchBarBackground
    UIImage *image = [[UIImage alloc] init];
    self.backgroundImage = image;
    RELEASE(image);
	self.tintColor = APP_TINT_COLOR;
	[[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitle:NSLocalizedStringForKey(@"取消")];
    
    //  开户SDK的存在UI错误，现强制使输入光标左边距拉宽20
    self.searchTextPositionAdjustment = UIOffsetMake(20, self.searchTextPositionAdjustment.vertical);
    
	return self;
}

@end
