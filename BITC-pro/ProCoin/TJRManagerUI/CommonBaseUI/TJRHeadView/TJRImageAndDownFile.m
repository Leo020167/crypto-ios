//
//  TJRImageAndDownFile.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-27.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRImageAndDownFile.h"
#import "AFNetworking.h"
#import "TTCacheManager.h"
#import "QuartzCore/QuartzCore.h"
#import "TTCacheManager.h"
#import "VoiceConverter.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TJRBaseViewController.h"
#import "CommonUtil.h"

NSString *const ImageDownLoadFinish = @"ImageDownLoadFinish";
NSString *const UserInfoUIImageView = @"UserInfoUIImageView";

@implementation TJRImageAndDownFile
@synthesize finishImageName;
@synthesize faildImageName;
@synthesize klingKey;
@synthesize tjrDelegate;
@synthesize voiceFileName;
@synthesize isPlaying;
@synthesize urlPath;
@synthesize noAnimation;
@synthesize canGoFriendPage;
@synthesize fileUrl;
@synthesize isCornerRadius;

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
	canGoFriendPage = YES;	// 默认头像能够进入好友主页
//    self.clipsToBounds = YES;
//    self.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundColor = RGBA(234,234,234, 1);
}

- (NSMutableDictionary *)tjrDicRequest {
    if (!tjrDicRequest) {
        tjrDicRequest = [NSMutableDictionary new];
    }
    return tjrDicRequest;
}

/**
 *	@brief	显示图片
 *
 *	@param  imageUrl    图片URL
 *	@param  imageName   默认图片名称
 */
- (void)showImageViewWithURL:(NSString *)imageUrl defaultImage:(id)imageName userId:(NSString*)userId{
    
    type = 1;
    if (TTIsStringWithAnyText(imageName)) {
        [self setImage:[UIImage imageNamed:imageName]];
    }else if([imageName isKindOfClass:[UIImage class]]){
        [self setImage:imageName];
    }

    self.userId = userId;
    
    if (canGoFriendPage && userId.length > 0 && ![userId isEqualToString:@"0"]) {
        [self addHeadmImageTap];// 添加头像点击事件
    }else{
        self.userInteractionEnabled = NO;
    }
    
    if (!TTIsStringWithAnyText(imageUrl)) return;//如果没有传入头像地址就不做操作
	self.urlPath = imageUrl;
    
    if (!tjrDicRequest) {
        tjrDicRequest = [[NSMutableDictionary alloc] init];
    }
    
	@try {
		if (nil != imageUrl && ![imageUrl isKindOfClass:[NSNull class]] && ![imageUrl isEqualToString:@"null"]) {
			NSData *date = [TTCacheManager dataForURL:imageUrl];

			if (nil != date) {
				UIImage *image = [UIImage imageWithData:date];

				if (_isFitImageView) {	// 将图片等比例拉伸后,截取一部分布满imageview
					image = [self extrudeAndInterceptionImage:image];
				}
				[self setImage:image];
                //图片加载完成时,通知下,其他地方可能要用
                [[NSNotificationCenter defaultCenter] postNotificationName:ImageDownLoadFinish object:nil userInfo:@{UserInfoUIImageView:self}];
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
                
				[self.tjrDicRequest setObject:task forKey:[NSString stringWithFormat:@"%p", task]];

                if ([tjrDelegate respondsToSelector:@selector(TJRDownloadFileStartLoad:)]) {
                    [tjrDelegate TJRDownloadFileStartLoad:imageUrl];
                }
                
                if (imageUrl) {
                    if (!_isContentMode) {
                        float area = self.frame.size.width * self.frame.size.height;
                        if (area > 64 * 64) {
                            self.contentMode = UIViewContentModeScaleAspectFit;
                        }else{
                            self.contentMode = UIViewContentModeScaleToFill;
                        }
                    }
                }
			}
		} else {
            [self setImage:[UIImage imageNamed:TTIsStringWithAnyText(imageName)?imageName:imgDefault]];
		}
	}
	@catch(NSException *exception) {
		NSLog(@"%@", exception.debugDescription);
		[self setImage:[UIImage imageNamed:TTIsStringWithAnyText(imageName)?imageName:imgDefault]];
	}
}

#pragma mark - 拉伸并截取图片
- (UIImage *)extrudeAndInterceptionImage:(UIImage *)image {
	if (!image) return nil;

	CGSize imageSize = image.size;
	CGSize viewSize = self.frame.size;
    CGFloat viewScale = viewSize.width / viewSize.height;
    CGFloat imageScale = imageSize.width / imageSize.height;
    if (viewScale > imageScale) {
        imageSize.height = imageSize.width / viewScale;
    } else if (viewScale < imageScale) {
        imageSize.width = imageSize.height * viewScale;
    }
    
	CGRect drawRect = CGRectZero;
	drawRect.size = imageSize;
    
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, drawRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
        //为了在列表中,点击头像时那行变色不能消除
}

#pragma mark - 头像点击事件
- (void)addHeadmImageTap {
	self.userInteractionEnabled = YES;	// 开启touches事件
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageOntouchesEnd)];
	tapGestureRecognizer.cancelsTouchesInView = NO;
	[self addGestureRecognizer:tapGestureRecognizer];
	[tapGestureRecognizer release];
}

- (void)headImageOntouchesEnd {
	if (_userId.length > 0 && ![_userId isEqualToString:@"0"]) {
        if (_clickDelegate && [_clickDelegate respondsToSelector:@selector(imageHeadClicked:userId:)]) {
            [_clickDelegate imageHeadClicked:self userId:_userId];
        }
        
		TJRBaseViewController *control = (TJRBaseViewController *)[self getRootController].navigationController.topViewController;
		NSString *key = @"targetUid";
		NSString *param = PersonalDict;
		NSString *pageToName = @"PersonViewController";

		if ([_userId isEqualToString:ROOTCONTROLLER_USER.userId]) {
			if (TTIsStringWithAnyText(_paramKey) && TTIsStringWithAnyText(_paramDictionary) && TTIsStringWithAnyText(_pageToName)) {
				key = self.paramKey;
				param = self.paramDictionary;
				pageToName = self.pageToName;
				[control putValueToParamDictionary:param value:_userId forKey:key];

				if (TTIsStringWithAnyText(_paramKeyForUserName) && TTIsStringWithAnyText(_userName)) {
					[control putValueToParamDictionary:param value:_userName forKey:_paramKeyForUserName];
				}
                [control pageToOrBackWithName:pageToName];
			}
		} else {
			if (TTIsStringWithAnyText(_paramKey) && TTIsStringWithAnyText(_paramDictionary) && TTIsStringWithAnyText(_pageToName)) {
				key = self.paramKey;
				param = self.paramDictionary;
				pageToName = self.pageToName;
			}

			if (TTIsStringWithAnyText(_paramKeyForUserName) && TTIsStringWithAnyText(_userName)) {
				[control putValueToParamDictionary:param value:_userName forKey:_paramKeyForUserName];
			}
            [control putValueToParamDictionary:param value:_userId forKey:key];
            [control pageToOrBackWithName:pageToName];
		}
	} else {
		self.userInteractionEnabled = NO;
	}

	NSLog(@"userId:%@", _userId);
}

#pragma mark - 获取RootController
- (RootController *)getRootController {
	return [self getTJRAppDelegate].rootController;
}

- (TJRAppDelegate *)getTJRAppDelegate {
	return (TJRAppDelegate *)[[UIApplication sharedApplication] delegate];
}

/**
 *	@brief	下载文件
 *
 *	@param  fileUrl     文件Url
 *	@param  imageName   下载中的显示图片
 *	@param  finishName  下载成功后显示图片
 *	@param  faildName   下载失败后显示图片
 */
- (void)downloadFile:(NSString *)_fileUrl defaultImage:(NSString *)imageName finishImage:(NSString *)finishName faildImage:(NSString *)faildName {
    if (!tjrDicRequest) {
        tjrDicRequest = [[NSMutableDictionary alloc] init];
    }

	if (imageName && TTIsStringWithAnyText(imageName)) {
		[self setImage:[UIImage imageNamed:imageName]];
	} else {
        [self setImage:nil];
    }

	self.finishImageName = finishName;
	self.faildImageName = faildName;

	if (TTIsStringWithAnyText(_fileUrl)) {
		type = 2;
        NSData *data = [TTCacheManager dataForKey:_fileUrl];
        if (!data) {

            NSString* urlPath = _fileUrl;
            
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
            
            [self.tjrDicRequest setObject:task forKey:[NSString stringWithFormat:@"%p", task]];
        } else {
            if ([tjrDelegate respondsToSelector:@selector(TJRDownloadFileFinish)]) {
                [tjrDelegate TJRDownloadFileFinish];
            }
        }
	}
}


- (void)requestDidFinishLoad:(NSURLSessionDownloadTask *)task responseObject:(id)responseObject{
	if ([tjrDelegate respondsToSelector:@selector(TJRVoiceHideHud)]) {
		[tjrDelegate TJRVoiceHideHud];
	}
    if (!_isContentMode) {
        self.contentMode = UIViewContentModeScaleToFill;
    }
    
	if (type == 1) {

		if ([tjrDelegate respondsToSelector:@selector(TJRDownloadFileFinish)]) {
			[tjrDelegate TJRDownloadFileFinish];
		}

        UIImage *image = [[[UIImage alloc]initWithData:responseObject]autorelease];
        
        if (_isFitImageView) {    // 将图片等比例拉伸后,截取一部分布满imageview
            image = [self extrudeAndInterceptionImage:image];
        }
        [self setImage:image];
        //图片加载完成时,通知下,其他地方可能要用
        [[NSNotificationCenter defaultCenter] postNotificationName:ImageDownLoadFinish object:nil userInfo:@{UserInfoUIImageView:self}];
        
        if (!noAnimation) {
            self.alpha = 0;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            self.alpha = 1;
            [UIView commitAnimations];
        }
        
	} else if (type == 2) {
		if ([tjrDelegate respondsToSelector:@selector(TJRDownloadFileFinish)]) {
			[tjrDelegate TJRDownloadFileFinish];
		} else {
			if (finishImageName && TTIsStringWithAnyText(finishImageName)) {
				[self setImage:[UIImage imageNamed:finishImageName]];
			} else {
				[self setImage:nil];
			}
		}
	}

	[self.tjrDicRequest removeObjectForKey:[NSString stringWithFormat:@"%p", task]];
}

- (void)request:(NSURLSessionDownloadTask *)task didFailLoadWithError:(NSError *)error {
	if ([tjrDelegate respondsToSelector:@selector(TJRVoiceHideHud)]) {
		[tjrDelegate TJRVoiceHideHud];
	}
    
    if (!_isContentMode) {
        float area = self.frame.size.width * self.frame.size.height;
        if (area > 64 * 64) {
            self.contentMode = UIViewContentModeScaleAspectFit;
        }else{
            self.contentMode = UIViewContentModeScaleToFill;
        }
    }

    if ([tjrDelegate respondsToSelector:@selector(TJRDownloadFileFail)]) {
        [tjrDelegate TJRDownloadFileFail];
    } else {
        if (faildImageName && TTIsStringWithAnyText(faildImageName)) {
            [self setImage:[UIImage imageNamed:faildImageName]];
        } else {
            [self setImage:[UIImage imageNamed:imgDefault]];
        }
    }

	[self.tjrDicRequest removeObjectForKey:[NSString stringWithFormat:@"%p", task]];
}

- (void)clearTjrDicRequest {
	for (NSURLSessionDataTask *task in [tjrDicRequest objectEnumerator]) {
		[task cancel];
	}
}

- (NSData *)getImageFromView:(UIView *)view {
	UIGraphicsBeginImageContext(view.bounds.size);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	NSData *imageData = UIImagePNGRepresentation(image);

	if (klingKey && imageData) {
		[TTCacheManager storeData:imageData forKey:klingKey];
	}

	return imageData;
}

/**
 *	@brief	显示图片
 *
 *	@param  imageUrl    图片URL
 */
- (void)showImageViewWithURL:(NSString *)imageUrl {

	[self showImageViewWithURL:imageUrl defaultImage:imgDefault userId:@""];
}

/**
 *	@brief	显示图片没有动画
 *
 *	@param  imageUrl    图片URL
 */
- (void)showImageViewWithNoAnimation:(NSString *)imageUrl {
	[self showImageViewWithURL:imageUrl canTouch:NO];
}

/**
 *    显示头像
 *    @param imageUrl 头像地址
 */

#pragma mark - 显示头像
- (void)showHeadImageViewWithURL:(NSString *)imageUrl userId:(NSString*)userId{

	[self showImageViewWithURL:imageUrl defaultImage:HeadImagePath userId:userId];
}

- (void)showImageViewWithURL:(NSString *)imageUrl canTouch:(BOOL)_canTouch {
	canGoFriendPage = _canTouch;
	[self showImageViewWithURL:imageUrl];
}

- (void)showHeadImageViewWithURL:(NSString *)imageUrl userId:(NSString*)userId canTouch:(BOOL)_canTouch {
    canGoFriendPage = _canTouch;
    [self showHeadImageViewWithURL:imageUrl userId:userId];
}

- (void)showImageViewWithURL:(NSString *)imageUrl canTouch:(BOOL)_canTouch isCornerRadius:(BOOL)_isCornerRadius {
	canGoFriendPage = _canTouch;
	self.isCornerRadius = _isCornerRadius;
	if (_isCornerRadius) {
		float radius = 0;
		float area = self.frame.size.width * self.frame.size.height;
		self.layer.masksToBounds = YES;

		if (area > 50 * 50) {
			radius = 4;
		} else if ((area <= 50 * 50) && (area > 40 * 40)) {
			radius = 3;
		} else if ((area <= 40 * 40) && (area > 30 * 30)) {
			radius = 2;
		} else if ((area <= 30 * 30) && (area > 20 * 20)) {
			radius = 1;
		}
		self.layer.cornerRadius = radius;
	}
	[self showImageViewWithURL:imageUrl];
}

- (void)showImageViewWithURL:(NSString *)imageUrl canTouch:(BOOL)_canTouch userid:(NSString *)_userid isCornerRadius:(BOOL)_isCornerRadius {
    canGoFriendPage = _canTouch;
	self.isCornerRadius = _isCornerRadius;
	if (_isCornerRadius) {
		float radius = 0;
		float area = self.frame.size.width * self.frame.size.height;
		self.layer.masksToBounds = YES;
        
		if (area > 50 * 50) {
			radius = 4;
		} else if ((area <= 50 * 50) && (area > 40 * 40)) {
			radius = 3;
		} else if ((area <= 40 * 40) && (area > 30 * 30)) {
			radius = 2;
		} else if ((area <= 30 * 30) && (area > 20 * 20)) {
			radius = 1;
		}
		self.layer.cornerRadius = radius;
	}
	[self showImageViewWithURL:imageUrl defaultImage:HeadImagePath userId:_userid];
}

- (void)dealloc {
    [self clearTjrDicRequest];
    
    if (tjrDicRequest) {
        [tjrDicRequest removeAllObjects];
    }
    
    [_userId release];
    TT_RELEASE_SAFELY(tjrDicRequest)
    [fileUrl release];
    [voiceFileName release];
    RELEASE(_pageToName);
    RELEASE(_paramDictionary);
    RELEASE(_paramKey);
    TT_RELEASE_SAFELY(urlPath);
    TT_RELEASE_SAFELY(finishImageName);
    TT_RELEASE_SAFELY(faildImageName)
    TT_RELEASE_SAFELY(klingKey);
    RELEASE(_paramKeyForUserName);
    RELEASE(_userName);
    [super dealloc];
}

@end

