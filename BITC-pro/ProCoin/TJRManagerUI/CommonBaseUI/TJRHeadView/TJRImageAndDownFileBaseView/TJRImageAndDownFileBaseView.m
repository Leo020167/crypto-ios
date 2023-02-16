//
//  TJRImageAndDownFileBaseView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-6-6.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

// ////////////////////////////////////////////////////
//                      _ooOoo_                      //
//                     o8888888o                     //
//                     88" . "88                     //
//                     (| -_- |)                     //
//                     O\  =  /O                     //
//                  ____/`---'\____                  //
//                .'  \\|     |//  `.                //
//               /  \\|||  :  |||//  \               //
//              /  _||||| -:- |||||-  \              //
//              |   | \\\  -  /// |   |              //
//              | \_|  ''\---/''  |   |              //
//              \  .-\__  `-`  ___/-. /              //
//            ___`. .'  /--.--\  `. . __             //
//         ."" '<  `.___\_<|>_/___.'  >'"".          //
//        | | :  `- \`.;`\ _ /`;.`/ - ` : | |        //
//        \  \ `-.   \_ __\ /__ _/   .-` /  /        //
//   ======`-.____`-.___\_____/___.-`____.-'======   //
//                      `=---='                      //
//  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^    //
//               佛祖保佑       永无BUG                //
//                                                   //
// ////////////////////////////////////////////////////

#import "TJRImageAndDownFileBaseView.h"
#import "AFNetworking.h"
#import "TTCacheManager.h"
#import "VoiceConverter.h"
#import "CommonUtil.h"

@implementation TJRImageAndDownFileBaseView

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

- (void)initilization {
	tjrDicRequest = [[NSMutableDictionary alloc] init];
}

#pragma mark - 下载图片

/**
 *    下载图片
 *    @param imageUrl
 */
- (void)downloadImageFile:(NSString *)imageUrl {
	if (!TTIsStringWithAnyText(imageUrl)) return;

	RELEASE(urlPath);
	urlPath = [imageUrl copy];
	type = TJRImageAndDownFileType_Image;
	NSData *date = [TTCacheManager dataForURL:imageUrl];

	if (nil != date) {
		UIImage *image = [UIImage imageWithData:date];

		if (_delegate && [_delegate respondsToSelector:@selector(TJRDownloadFileFinish:url:)]) {
			[_delegate TJRDownloadFileFinish:image url:imageUrl];
		}
	} else {

        NSString* urlPath = imageUrl;
        
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]];
        
        __block NSURLSessionDownloadTask * task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            return [NSURL fileURLWithPath:[TTCacheManager cachePathForPath:urlPath]];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
            if (!error) {
                NSData *data = [TTCacheManager dataForURL:urlPath];
                [self requestDidFinishLoad:task responseObject:data];
            } else {
                [self request:task didFailLoadWithError:error];
            }
        }];
        [task resume];
        
        [tjrDicRequest setObject:task forKey:[NSString stringWithFormat:@"%p", task]];
	}
}

#pragma mark - 下载音频文件

/**
 *    下载MP3音频文件
 *    @param voiceUrl
 */
- (void)downloadMp3VoiceFile:(NSString *)voiceUrl {
	[self downloadVoiceFile:voiceUrl voiceType:TJRImageAndDownFileType_Voice_Mp3 isCheckCache:NO];
}

/**
 *    下载音频文件
 *    @param voiceUrl
 */
- (void)downloadVoiceFile:(NSString *)voiceUrl voiceType:(TJRImageAndDownFileType)voiceType {
	[self downloadVoiceFile:voiceUrl voiceType:voiceType isCheckCache:YES];
}

/**
 *    下载音频文件
 *    @param voiceUrl 音频文件url
 *    @param isCheckCache  是否检测本地有该文件(转换失败时,可以再次下载,不检测本地)
 */
- (void)downloadVoiceFile:(NSString *)voiceUrl voiceType:(TJRImageAndDownFileType)voiceType isCheckCache:(BOOL)isCheckCache {
	if (!TTIsStringWithAnyText(voiceUrl)) return;

	NSData *data = nil;

	if (isCheckCache && (voiceType == TJRImageAndDownFileType_Voice_Amr)) {		/* 存在转换过的音频文件 */
		data = [TTCacheManager dataForKey:[TJRImageAndDownFileBaseView getVoiceNameFormUrl:voiceUrl]];
	}

	if (!data) {
		data = [TTCacheManager dataForURL:voiceUrl];

		if (data) {
			if (voiceType == TJRImageAndDownFileType_Voice_Amr) {	/* 当要下载amr文件,但没有转换过的音频文件 */
				[self convertVoice:data voiceUrl:voiceUrl];
			} else {
				if (_delegate && [_delegate respondsToSelector:@selector(TJRDownloadFileFinish:url:)]) {
					[_delegate TJRDownloadFileFinish:data url:voiceUrl];
				}
			}
		} else {
			[self downloadFile:voiceUrl fileType:voiceType];
		}
	} else {
		if (_delegate && [_delegate respondsToSelector:@selector(TJRDownloadFileFinish:url:)]) {
			[_delegate TJRDownloadFileFinish:data url:voiceUrl];
		}
	}
}

/**
 *    文件下载,以NSData方式
 *    @param fileUrl
 */
- (void)downloadFile:(NSString *)fileUrl fileType:(TJRImageAndDownFileType)fileType {
	RELEASE(urlPath);
	urlPath = [fileUrl copy];
	type = fileType;
    
    NSString* urlPath = fileUrl;
    
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]];
    
    __block NSURLSessionDownloadTask * task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [NSURL fileURLWithPath:[TTCacheManager cachePathForPath:urlPath]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (!error) {
            NSData *data = [TTCacheManager dataForURL:urlPath];
            [self requestDidFinishLoad:task responseObject:data];
        } else {
            [self request:task didFailLoadWithError:error];
        }
    }];
    [task resume];
    
    [tjrDicRequest setObject:task forKey:[NSString stringWithFormat:@"%p", task]];
}

#pragma mark - 网络成功

/**
 *    网络成功
 *    @param request
 */
- (void)requestDidFinishLoad:(NSURLSessionDownloadTask *)task responseObject:(id)responseObject{
    if (type == TJRImageAndDownFileType_Image) {

        UIImage *image = [[[UIImage alloc]initWithData:responseObject]autorelease];
        
        if (_delegate && [_delegate respondsToSelector:@selector(TJRDownloadFileFinish:url:)]) {
            [_delegate TJRDownloadFileFinish:image url:urlPath];
        }
    } else if (type == TJRImageAndDownFileType_Voice_Amr) {
        NSData *data = (NSData*)responseObject;
        [self convertVoice:data voiceUrl:urlPath];
    } else if (type == TJRImageAndDownFileType_Voice_Mp3) {
        NSData *data = (NSData*)responseObject;
        if (_delegate && [_delegate respondsToSelector:@selector(TJRDownloadFileFinish:url:)]) {
            [_delegate TJRDownloadFileFinish:data url:urlPath];
        }
    }
	[tjrDicRequest removeObjectForKey:[NSString stringWithFormat:@"%p", task]];
}

#pragma mark - 网络失败

/**
 *    网络失败
 *    @param request
 *    @param error
 */
- (void)request:(NSURLSessionDownloadTask *)task didFailLoadWithError:(NSError *)error {
	if (_delegate && [_delegate respondsToSelector:@selector(TJRDownloadFileFail:url:)]) {
		[_delegate TJRDownloadFileFail:error url:urlPath];
	}
	[tjrDicRequest removeObjectForKey:[NSString stringWithFormat:@"%p", task]];
}

#pragma mark - 转换语音格式

/**
 *    转换语音格式
 *    @param data 语音
 *    @param voiceFileName  语音url
 */
- (void)convertVoice:(NSData *)data voiceUrl:(NSString *)voiceUrl {
	NSString *voiceFileName = [TJRImageAndDownFileBaseView getVoiceNameFormUrl:voiceUrl];

	if (!TTIsStringWithAnyText(voiceFileName)) return;

	NSString *path = [CommonUtil TTPathForDocumentsResourceEtag:voiceFileName];

	[data writeToFile:path atomically:YES];	// 保存文件

	NSString *savePath = [path stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"];

	if ([VoiceConverter amrToWav:path savePath:savePath]) {	/* 转换格式 */
		NSData *dd = [[NSData alloc] initWithContentsOfFile:savePath];

		if (dd) {
			[TTCacheManager storeData:dd forKey:voiceFileName];
			NSFileManager *fileManager = [NSFileManager defaultManager];
			[fileManager removeItemAtPath:[CommonUtil TTPathForDocumentsResourceEtag:voiceFileName] error:nil];
			[fileManager removeItemAtPath:savePath error:nil];

			if (_delegate && [_delegate respondsToSelector:@selector(TJRDownloadFileFinish:url:)]) {
				[_delegate TJRDownloadFileFinish:dd url:voiceUrl];
			}
			RELEASE(dd);
			return;
		}
	} else {
		NSLog(@"下载的amr转wav失败");
	}

	if (_delegate && [_delegate respondsToSelector:@selector(TJRDownloadFileFail:url:)]) {
		[_delegate TJRDownloadFileFail:nil url:voiceUrl];
	}
}

/**
 *    通过音频文件的url来截取文件名?getVoice=后面的字符
 *    @param url
 *    @returns
 */
+ (NSString *)getVoiceNameFormUrl:(NSString *)url {
	return [self getVoiceNameFormUrl:url voiceType:nil];
}

/**
 *    通过音频文件的url来截取文件名?getVoice=后面的字符
 *    @param url
 *    @param voiceType  音频文件名以什么结尾(wav,amr,mp3自己定)
 *    @returns
 */
+ (NSString *)getVoiceNameFormUrl:(NSString *)url voiceType:(NSString *)voiceType {
	if (!TTIsStringWithAnyText(url)) return nil;

	NSRange rang = [url rangeOfString:@"?getVoice="];
	NSString *fName = nil;

	if (rang.location != NSNotFound) {
		fName = [url substringFromIndex:rang.location + rang.length];

		if (TTIsStringWithAnyText(fName) && TTIsStringWithAnyText(voiceType)) {
			NSArray *array = [fName componentsSeparatedByString:@"."];

			if (array && (array.count == 2)) {
				return [NSString stringWithFormat:@"%@.%@", [array firstObject], voiceType];
			}
		}
	}
	return fName;
}

- (void)dealloc {
	[self clearTjrDicRequest];

	if (tjrDicRequest) {
		[tjrDicRequest removeAllObjects];
	}
	RELEASE(tjrDicRequest);
	RELEASE(urlPath);
	[super dealloc];
}

- (void)clearTjrDicRequest {
	for (NSURLSessionDataTask *task in [tjrDicRequest objectEnumerator]) {
		[task cancel];
	}
}

@end

