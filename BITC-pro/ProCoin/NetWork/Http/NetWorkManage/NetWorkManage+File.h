//
//  NetWorkManage+File.h
//  Redz
//
//  Created by taojinroad on 2018/11/5.
//  Copyright © 2018 淘金路. All rights reserved.
//

#import "NetWorkManage.h"

NS_ASSUME_NONNULL_BEGIN


#define FILEUPLOADTYPE_FILE                     @"file"//通用文件上传

#define FILEUPLOADTYPE_IMG_ORIGINAL             @"imageRetOriginal"//上传图片，返回原图链接
#define FILEUPLOADTYPE_IMG_COMPRESSED           @"imageRetCompressed"//上传图片，返回压缩图片链接
#define FILEUPLOADTYPE_IMG_ORG_CPR              @"imageRetOrgAndCpr"//上传图片，返回原图和压缩图片链接

#define FILEUPLOADTYPE_VIDEO_ORIGINAL           @"videoRetOriginal"//上传视频，返回原视频链接
#define FILEUPLOADTYPE_VIDEO_COMPRESSED         @"videoRetCompressed"//上传视频，返回压缩视频链接

#define FILEUPLOADPATH_DIR_COMMON               @"common"//公用路径
#define FILEUPLOADPATH_DIR_IMAGE                @"image"//图片路径
#define FILEUPLOADPATH_DIR_VIDEO                @"video"//音频路径
#define FILEUPLOADPATH_DIR_CIRCLE               @"circle"//圈子路径
#define FILEUPLOADPATH_DIR_TEXTLIVE             @"liveImage"//文字直播路径

#define FILEUPLOADPATH_DIR_CHAT_IMAGE           @"chatImage"//圈子图片路径
#define FILEUPLOADPATH_DIR_CHAT_VIDEO           @"chatVoice"//圈子音频路径
#define FILEUPLOADPATH_DIR_USER_IMAGE           @"userImage"//图片路径
#define FILEUPLOADPATH_DIR_IDENTIFIER_IMAGE     @"identityImage"//认证图片路径

@interface NetWorkManage (File)

/** 通用上传文件 - file-key3参数*/
- (void)reqUploadFile:(id)delegate type:(NSString*)type dir:(NSString*)dir files:(NSMutableArray *)files imageFiles:(NSMutableArray*)imageFiles videoFiles:(NSMutableArray *)videoFiles finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 上传用户头像文件*/
- (void)reqUploadUserHeadUrlFile:(id)delegate imageFile:(NSString *)imageFile finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 上传个人认证文件*/
- (void)reqUploadUserCertificationFile:(id)delegate imageFile:(NSString *)imageFile finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;


/** 上传创建圈子图片文件*/
- (void)reqUploadCreateCircleFile:(id)delegate imgFile:(NSString *)imgFile finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;


/** 上传私聊图片文件*/
- (void)reqUploadChatImgFile:(id)delegate imageFile:(NSString *)imageFile verify:(NSString *)verify finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 上传私聊语音文件*/
- (void)reqUploadChatVideoFile:(id)delegate videoFile:(NSString *)videoFile verify:(NSString *)verify finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 上传个人主页背景图片*/
- (void)reqUploadHomePageBackground:(id)delegate imageFile:(NSString *)imageFile finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 上传圈子主页背景图片*/
- (void)reqUploadCircleBackground:(id)delegate imageFile:(NSString *)imageFile finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 上传圈子主页背景图片(多图片)*/
- (void)reqUploadCircleBackground:(id)delegate imageFiles:(NSMutableArray *)imageFiles finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 上传文字直播图片*/
- (void)reqUploadTextLiveContentImage:(id)delegate imageFiles:(NSArray *)imageFiles finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 上传提现二维码图片*/
- (void)reqWithdrawUploadQRCodeImage:(id)delegate imageFile:(NSString *)imageFile finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

@end

NS_ASSUME_NONNULL_END
