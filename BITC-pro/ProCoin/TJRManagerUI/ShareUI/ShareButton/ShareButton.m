//
//  ShareButton.m
//  TJRtaojinroad
//
//  Created by Jeans on 11/2/12.
//  Copyright (c) 2018 蓝跳蚤. All rights reserved.
//

#import "ShareButton.h"
#import "TJRBaseViewController.h"
#import "TJRAppDelegate.h"
#import "ShareToWeixin.h"
#import "TTCacheManager.h"
#import "CommonUtil.h"
#import "CHTumblrMenuView.h"
#import "TJRBaseParserJson.h"

#define STRING_SHARE_WEIXIN                     @"转发给微信好友"
#define STRING_SHARE_PENGYOUQUAN                @"转发到微信朋友圈"
#define STRING_SHARE_PRINTSCREENCHAT            @"分享到私聊"

@interface ShareButton () <UIAlertViewDelegate>{

	ShareBtnType btnType;
    CHTumblrMenuView *tumblrMenuView;
    ShareToWeixin* share;
}

@property (assign, nonatomic) BOOL isShareToSession;
@property (copy, nonatomic) NSString* shareType;

@end

@implementation ShareButton


- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		[self initialization];
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

	if (self) {
		[self initialization];
	}

	return self;
}

- (void)initialization {

	self.descText = @"";
	// 添加弹出菜单事件
	[self addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

/**
 *  设置行情分享模式的所有按钮(titleArray和iconArray长度要相等)
 *
 *  @param type       按钮类型
 *  @param titleArray 标题Array
 *  @param iconArray  图标图片名Array
 */
- (void)setShareMenu:(ShareBtnType)type itemTitles:(NSArray *)titleArray itemIcons:(NSArray *)iconArray {
    btnType = type;
    if (!tumblrMenuView && titleArray && iconArray && titleArray.count == iconArray.count) {
        tumblrMenuView = [[CHTumblrMenuView alloc] init];
        NSUInteger size = titleArray.count;
        __block ShareButton *weakSelf = self;//block中要使用弱引用，否则造成循环引用
        for (int i = 0; i < size; i++) {
            NSString *title = titleArray[i];
            NSString *imageName = iconArray[i];
            [tumblrMenuView addMenuItemWithTitle:title andIcon:[UIImage imageNamed:imageName] andSelectedBlock:^{
                [weakSelf menuClicked:nil menuId:i];
            }];
        }
    }
}

#pragma mark - 弹出下拉菜单
- (void)shareButtonPressed:(id)sender {
    if ([_delegate respondsToSelector:@selector(shareBtnClick:)]) {
        [_delegate shareBtnClick:sender];
    }
    [tumblrMenuView showWithBackView:[self getTopViewController].view];
}

- (void)menuClicked:(id)sender menuId:(NSInteger)menuId {

	switch (btnType) {
		
        case ShareBtnArticle:
        case ShareBtnWebView:
        case ShareBtnApp:
        case ShareBtnHome:
        case ShareBtnCircle:
        case ShareBtnComponents:
            
            switch (menuId) {
                case 0:	// 转发给微信好友
                    
                    if ([ShareToWeixin checkWXCanShare]) {
                        if ([_delegate respondsToSelector:@selector(shareTouchType:)]) {
                            [_delegate shareTouchType:ShareTouchWeixin];
                        }
                    }
                    
                    break;
                    
                case 1:	// 转发到微信朋友圈
                    
                    if ([ShareToWeixin checkWXCanShare]) {
                        if ([_delegate respondsToSelector:@selector(shareTouchType:)]) {
                            [_delegate shareTouchType:ShareTouchPengyouquan];
                        }
                    }
                    
                    break;
            }
            
            break;
		default:
			break;
	}
}

- (void)didClickOnImageIndex:(NSInteger)index{
    [self menuClicked:nil menuId:index];
}

- (TJRBaseViewController *)getTopViewController {
	return (TJRBaseViewController *)ROOTCONTROLLER.navigationController.topViewController;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_shareType release];
    [_params release];
    RELEASE(tumblrMenuView);
    RELEASE(_shareTitle);
    [share release];
    [_descText release];
    [super dealloc];
}
@end

