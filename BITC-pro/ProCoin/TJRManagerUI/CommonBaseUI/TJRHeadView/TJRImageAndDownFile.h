//
//  TJRImageAndDownFile.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-27.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

#define downloadFileFinishImage @""
#define downloadFileFalidImage	@""

#define HeadImagePath			@"util_Image_bg_no_head"
#define imgDefault              @"util_Image_bg_loading_img"
#define RectangleDefault        @"util_Image_bg_loading_img_rectangle"

extern NSString *const ImageDownLoadFinish;
extern NSString *const UserInfoUIImageView;

@protocol TJRImageAndDownFileDelegate <NSObject>
@optional
- (void)TJRVoicePlay:(NSString *)voiceURL;
- (void)TJRVoiceShowHud;
- (void)TJRVoiceHideHud;
- (void)TJRDownloadFileFinish;
- (void)TJRDownloadFileFail;
- (void)TJRDownloadFileStartLoad:(NSString*)url;
@end

@protocol TJRImageClickDelegate <NSObject>
@optional
- (void)imageHeadClicked:(id)imageView userId:(NSString*)userId;
@end


typedef enum TJRImageAndDownShowType {
    TJRImageAndDownShowType_KLineArenaFriend,
    TJRImageAndDownShowType_KLineArenaPublic,
    TJRImageAndDownShowType_TalkieTalkiePlaza,
    TJRImageAndDownShowType_TalkieTalkiePlaza_NO_Touch,
    TJRImageAndDownShowType_NewFriendMsg
}TJRImageAndDownShowType;

@interface TJRImageAndDownFile : UIImageView {
	int type;
	NSString *finishImageName;
	NSString *faildImageName;
	NSMutableDictionary *tjrDicRequest;
	NSMutableArray *klineArray;
	NSString *klingKey;

	BOOL noAnimation;		// 显示时是否有动画
	id <TJRImageAndDownFileDelegate> tjrDelegate;
	NSString *urlPath;		// 当前请求路径
	BOOL isRightOrit;		// 气泡方向是否为右
    
    BOOL isCornerRadius;    // 是否圆角
}
@property (nonatomic, assign) id <TJRImageAndDownFileDelegate> tjrDelegate;
@property (nonatomic, assign) id <TJRImageClickDelegate> clickDelegate;
@property (nonatomic, copy) NSString *voiceFileName;
@property (nonatomic, assign) BOOL isPlaying;			// 是否正在播放声音
@property (nonatomic, assign) BOOL noAnimation;			// 显示时是否有动画
@property (nonatomic, copy) NSString *finishImageName;
@property (nonatomic, copy) NSString *faildImageName;
@property (nonatomic, copy) NSString *klingKey;
@property (nonatomic, copy) NSString *urlPath;
@property (nonatomic, assign) BOOL canGoFriendPage;		// 是否能够进入好友主页(应该为可以点击头像进入到其他页面,不只是好友主页)
@property (nonatomic, copy) NSString *fileUrl;			// 语音文件下载路径
@property (nonatomic, assign) BOOL isFitImageView;		// 是否将图片等比例拉伸后,截取一部分布满imageview
@property (nonatomic, copy) NSString *paramDictionary;	// 跳转存入的字典(默认为 ChatDict)
@property (nonatomic, copy) NSString *paramKey;			// 跳转存入的key(默认为 FriendHeadUserId)
@property (nonatomic, copy) NSString *pageToName;		// 跳转的页面名称(默认为 FriendHomeViewController)
@property (nonatomic, assign) BOOL pageIsNotOnly;       // 跳转的页面的唯一性(YES为非唯一,NO为唯一,默认为NO)
@property (nonatomic, copy) NSString *paramKeyForUserName;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) BOOL isCornerRadius;      // 是否圆角
@property (nonatomic, assign) BOOL isContentMode;       //设置是否默认ContentMode

- (void)showImageViewWithNoAnimation:(NSString *)imageUrl;
- (void)showImageViewWithURL:(NSString *)imageUrl defaultImage:(id)imageName userId:(NSString*)userId;
- (void)showImageViewWithURL:(NSString *)imageUrl;
- (void)downloadFile:(NSString *)fileUrl defaultImage:(NSString *)imageName finishImage:(NSString *)finishName faildImage:(NSString *)faildName;

#pragma mark - 显示头像
- (void)showHeadImageViewWithURL:(NSString *)imageUrl userId:(NSString*)userId;

- (void)showImageViewWithURL:(NSString *)imageUrl canTouch:(BOOL)_canTouch;

- (void)showHeadImageViewWithURL:(NSString *)imageUrl userId:(NSString*)userId canTouch:(BOOL)_canTouch;

- (void)showImageViewWithURL:(NSString *)imageUrl canTouch:(BOOL)_canTouch isCornerRadius:(BOOL)_isCornerRadius;

- (void)showImageViewWithURL:(NSString *)imageUrl canTouch:(BOOL)_canTouch userid:(NSString *)_userid isCornerRadius:(BOOL)_isCornerRadius;


@end

