//
//  TJRImageAndDownFileBaseView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 14-6-6.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TJRImageAndDownFileBaseViewDelegate <NSObject>
@optional
- (void)TJRDownloadFileFinish:(id)file url:(NSString *)url;
- (void)TJRDownloadFileFail:(NSError *)error url:(NSString *)url;
@end

typedef enum TJRImageAndDownFileType {
	TJRImageAndDownFileType_Json,
	TJRImageAndDownFileType_Image,
	TJRImageAndDownFileType_Voice_Amr,
	TJRImageAndDownFileType_Voice_Mp3,
	TJRImageAndDownFileType_Data
} TJRImageAndDownFileType;

@interface TJRImageAndDownFileBaseView : UIImageView {
	NSMutableDictionary *tjrDicRequest;
	NSString *urlPath;
	TJRImageAndDownFileType type;
}

@property (nonatomic, assign) id <TJRImageAndDownFileBaseViewDelegate> delegate;

/**
 *    下载图片
 *    @param imageUrl
 */
- (void)downloadImageFile:(NSString *)imageUrl;

/**
 *    下载MP3音频文件
 *    @param voiceUrl
 */
- (void)downloadMp3VoiceFile:(NSString *)voiceUrl;

/**
 *    下载音频文件
 *    @param voiceUrl
 */
- (void)downloadVoiceFile:(NSString *)voiceUrl voiceType:(TJRImageAndDownFileType)voiceType;

/**
 *   文件下载,以NSData方式
 *   @param fileUrl
 */
- (void)downloadFile:(NSString *)fileUrl fileType:(TJRImageAndDownFileType)fileType ;

/**
 *   下载音频文件
 *   @param voiceUrl 音频文件url
 *   @param isCheckCache  是否检测本地有该文件(转换失败时,可以再次下载,不检测本地)
 */
- (void)downloadVoiceFile:(NSString *)voiceUrl voiceType:(TJRImageAndDownFileType)voiceType isCheckCache:(BOOL)isCheckCache;

/**
 *   通过音频文件的url来截取文件名?getVoice=后面的字符
 *   @param url
 *   @returns
 */
+ (NSString *)getVoiceNameFormUrl:(NSString *)url;


/**
 通过音频文件的url来截取文件名?getVoice=后面的字符
 @param url
 @param voiceType  音频文件名以什么结尾(wav,amr,mp3自己定)
 @returns
 */
+ (NSString *)getVoiceNameFormUrl:(NSString *)url voiceType:(NSString *)voiceType;
@end

