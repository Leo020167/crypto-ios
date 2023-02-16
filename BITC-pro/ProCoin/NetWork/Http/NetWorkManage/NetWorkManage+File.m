//
//  NetWorkManage+File.m
//  Redz
//
//  Created by taojinroad on 2018/11/5.
//  Copyright © 2018 淘金路. All rights reserved.
//

#import "NetWorkManage+File.h"

#define URL_API_UPLOAD_FILE                  @"upload/file"

@implementation NetWorkManage (File)

- (NSString *)fullFileUrl:(NSString *)apiUrl {
    
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://upload.%@/procoin-file/", ip];
    return [NSString stringWithFormat:@"%@%@.do", urlApi, apiUrl];
}

/** 通用上传文件 - file-key3参数*/
- (void)reqUploadFile:(id)delegate type:(NSString*)type dir:(NSString*)dir files:(NSMutableArray *)files imageFiles:(NSMutableArray*)imageFiles videoFiles:(NSMutableArray *)videoFiles finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase uploadFileToServer:[self fullFileUrl:URL_API_UPLOAD_FILE]
                                params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"type" value:type],
                                        [BasicNameValuePair setName:@"dir" value:dir],nil]
                                 files:[self fetchUrlFiles:
                                        [BasicNameValuePair setName:@"files" value:files],
                                        [BasicNameValuePair setName:@"imageFiles" value:imageFiles],
                                        [BasicNameValuePair setName:@"videoFiles" value:videoFiles],nil]
                              delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 上传用户头像文件*/
- (void)reqUploadUserHeadUrlFile:(id)delegate imageFile:(NSString *)imageFile finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase uploadFileToServer:[self fullFileUrl:URL_API_UPLOAD_FILE]
                                params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"type" value:FILEUPLOADTYPE_IMG_ORIGINAL],
                                        [BasicNameValuePair setName:@"dir" value:FILEUPLOADPATH_DIR_USER_IMAGE],nil]
                                 files:[self fetchUrlFiles:
                                        [BasicNameValuePair setName:@"imageFiles" value:imageFile],nil]
                              delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 上传个人认证文件*/
- (void)reqUploadUserCertificationFile:(id)delegate imageFile:(NSString *)imageFile finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase uploadFileToServer:[self fullFileUrl:URL_API_UPLOAD_FILE]
                                params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"type" value:FILEUPLOADTYPE_IMG_ORIGINAL],
                                        [BasicNameValuePair setName:@"dir" value:FILEUPLOADPATH_DIR_IDENTIFIER_IMAGE],nil]
                                 files:[self fetchUrlFiles:
                                        [BasicNameValuePair setName:@"imageFiles" value:imageFile],nil]
                              delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


/** 上传创建圈子图片文件*/
- (void)reqUploadCreateCircleFile:(id)delegate imgFile:(NSString *)imgFile finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase uploadFileToServer:[self fullFileUrl:URL_API_UPLOAD_FILE]
                                params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"type" value:FILEUPLOADTYPE_IMG_ORIGINAL],
                                        [BasicNameValuePair setName:@"dir" value:FILEUPLOADPATH_DIR_CIRCLE],nil]
                                 files:[self fetchUrlFiles:
                                        [BasicNameValuePair setName:@"imageFiles" value:imgFile],nil]
                              delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}


/** 上传私聊图片文件*/
- (void)reqUploadChatImgFile:(id)delegate imageFile:(NSString *)imageFile verify:(NSString *)verify finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase uploadFileToServer:[self fullFileUrl:URL_API_UPLOAD_FILE]
                                params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"type" value:FILEUPLOADTYPE_IMG_ORIGINAL],
                                        [BasicNameValuePair setName:@"dir" value:FILEUPLOADPATH_DIR_CHAT_IMAGE],
                                        [BasicNameValuePair setName:@"verify" value:verify],nil]
                                 files:[self fetchUrlFiles:
                                        [BasicNameValuePair setName:@"imageFiles" value:imageFile],nil]
                              delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 上传私聊语音文件*/
- (void)reqUploadChatVideoFile:(id)delegate videoFile:(NSString *)videoFile verify:(NSString *)verify finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase uploadFileToServer:[self fullFileUrl:URL_API_UPLOAD_FILE]
                                params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"type" value:FILEUPLOADTYPE_FILE],
                                        [BasicNameValuePair setName:@"dir" value:FILEUPLOADPATH_DIR_CHAT_VIDEO],
                                        [BasicNameValuePair setName:@"verify" value:verify],nil]
                                 files:[self fetchUrlFiles:
                                        [BasicNameValuePair setName:@"files" value:videoFile],nil]
                              delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 上传个人主页背景图片*/
- (void)reqUploadHomePageBackground:(id)delegate imageFile:(NSString *)imageFile finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase uploadFileToServer:[self fullFileUrl:URL_API_UPLOAD_FILE]
                                params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"type" value:FILEUPLOADTYPE_IMG_ORIGINAL],
                                        [BasicNameValuePair setName:@"dir" value:FILEUPLOADPATH_DIR_IMAGE],nil]
                                 files:[self fetchUrlFiles:
                                        [BasicNameValuePair setName:@"imageFiles" value:imageFile],nil]
                              delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 上传圈子主页背景图片(单图片)*/
- (void)reqUploadCircleBackground:(id)delegate imageFile:(NSString *)imageFile finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase uploadFileToServer:[self fullFileUrl:URL_API_UPLOAD_FILE]
                                params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"type" value:FILEUPLOADTYPE_IMG_ORIGINAL],
                                        [BasicNameValuePair setName:@"dir" value:FILEUPLOADPATH_DIR_CIRCLE],nil]
                                 files:[self fetchUrlFiles:
                                        [BasicNameValuePair setName:@"imageFiles" value:imageFile],nil]
                              delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 上传圈子主页背景图片(多图片)*/
- (void)reqUploadCircleBackground:(id)delegate imageFiles:(NSMutableArray *)imageFiles finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase uploadFileToServer:[self fullFileUrl:URL_API_UPLOAD_FILE]
                                params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"type" value:FILEUPLOADTYPE_IMG_ORIGINAL],
                                        [BasicNameValuePair setName:@"dir" value:FILEUPLOADPATH_DIR_CIRCLE],nil]
                                 files:[self fetchUrlFiles:
                                        [BasicNameValuePair setName:@"imageFiles" value:imageFiles],nil]
                              delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

/** 上传文字直播图片*/
- (void)reqUploadTextLiveContentImage:(id)delegate imageFiles:(NSArray *)imageFiles finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase uploadFileToServer:[self fullFileUrl:URL_API_UPLOAD_FILE]
                                params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"type" value:FILEUPLOADTYPE_IMG_ORG_CPR],
                                        [BasicNameValuePair setName:@"dir" value:FILEUPLOADPATH_DIR_TEXTLIVE],nil]
                                 files:[self fetchUrlFiles:
                                        [BasicNameValuePair setName:@"imageFiles" value:imageFiles],nil]
                              delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

- (void)reqWithdrawUploadQRCodeImage:(id)delegate imageFile:(NSString *)imageFile finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase uploadFileToServer:[self fullFileUrl:URL_API_UPLOAD_FILE]
                                params:[self fetchUrlParam:
                                        [BasicNameValuePair setName:@"type" value:FILEUPLOADTYPE_IMG_ORIGINAL],
                                        [BasicNameValuePair setName:@"dir" value:FILEUPLOADPATH_DIR_COMMON],nil]
                                 files:[self fetchUrlFiles:
                                        [BasicNameValuePair setName:@"imageFiles" value:imageFile],nil]
                              delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}



@end
