//
//  ShareButton.h
//  TJRtaojinroad
//
//  Created by Jeans on 11/2/12.
//  Copyright (c) 2018 蓝跳蚤. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareButton;

typedef enum ShareBtnType {
    ShareBtnArticle = 1,			        // 文章
    ShareBtnWebView,                        // 网页分享
    ShareBtnHome,                           // 主页
    ShareBtnApp,                            // App分享
    ShareBtnCircle,                         // 圈子分享
    ShareBtnComponents,                     // 网页组件分享
} ShareBtnType;

typedef enum ShareTouchType {
	ShareTouchWeixin,				        // 分享到微信好友
	ShareTouchPengyouquan,			        // 分享到微信朋友圈
    ShareTouchChat,                         // 分享到私聊
} ShareTouchType;

@protocol ShareButtonDelegate <NSObject>

@optional
- (void)shareTouchType:(ShareTouchType)type;	                                // 返回选中按钮的类型
- (void)shareTouchType:(ShareTouchType)type shareButton:(ShareButton *)button;	// 返回选中按钮的类型

- (void)shareBtnMenuOnClick:(int)index;
- (void)shareBtnClick:(id)sender;
@end


@interface ShareButton : UIButton

@property (copy, nonatomic) NSString *descText;
@property (copy, nonatomic) NSString *params;
@property (copy, nonatomic) NSString *shareTitle;
@property (assign, nonatomic) id <ShareButtonDelegate> delegate;

/**
 *  设置分享模式的所有按钮(titleArray和iconArray长度要相等)
 *
 *  @param type       按钮类型
 *  @param titleArray 标题Array
 *  @param iconArray  图标图片名Array
 */
- (void)setShareMenu:(ShareBtnType)type itemTitles:(NSArray *)titleArray itemIcons:(NSArray *)iconArray;

@end

