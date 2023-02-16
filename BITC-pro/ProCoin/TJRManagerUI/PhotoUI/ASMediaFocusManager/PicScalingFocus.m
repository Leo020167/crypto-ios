//
//  PicScalingFocus.m
//  TJRtaojinroad
//
//  Created by road taojin on 12-10-12.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "PicScalingFocus.h"
#import "TTCacheManager.h"
#import "AFNetworking.h"

@interface PicScalingFocus () {}

@end

@implementation PicScalingFocus
@synthesize chatTopicId;
@synthesize focusManager;
@synthesize picPath;
@synthesize delegate;

- (id)init {
	self = [super init];
	if (self) {
		self.focusManager = [[ASMediaFocusManager alloc] init];
		self.focusManager.delegate = self;
	}
	return self;
}

- (void)dealloc {
	[picPath release];
	[focusManager release];
	[chatTopicId release];
	[super dealloc];
}

#pragma mark - ASMediaFocusDelegate
- (UIImage *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager imageForView:(UIView *)view {
	UIImage *image = Nil;

	if ([delegate respondsToSelector:@selector(picScalingFocus:onTouchPic:)]) {
		image = [delegate picScalingFocus:self onTouchPic:view];
		self.focusManager = mediaFocusManager;
		self.focusManager.bDownload = (picPath.length > 0 && [TTCacheManager dataForKey:picPath] == NULL);
	}
	return image;
}

- (CGRect)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager finalFrameforView:(UIView *)view {
	CGRect frame = ROOTCONTROLLER.navigationController.topViewController.view.bounds;

	frame.origin.x = 0;
	frame.origin.y = frame.size.height > 480 ? frame.size.height / 4 : (CURRENT_DEVICE_VERSION >= 7.0 ? frame.size.height / 5 : (frame.size.height - 20) / 5);
	frame.size.height = frame.size.height > 480 ? frame.size.height / 2 : 568 / 2;	// 防止图片缩放时抖动

	return frame;
}

- (UIViewController *)parentViewControllerForMediaFocusManager:(ASMediaFocusManager *)mediaFocusManager {
//    return ROOTCONTROLLER.navigationController.topViewController;
    
    UINavigationController *navigationVC = ROOTCONTROLLER.navigationController;
    if ([navigationVC presentedViewController]) {
        if ([[navigationVC presentedViewController] isKindOfClass:[UINavigationController class]]) {
            navigationVC = (UINavigationController *)[navigationVC presentedViewController];
            return navigationVC.topViewController;
        }else {
            return [navigationVC presentedViewController];
        }
    }
    return navigationVC.topViewController;
    
    
    
}

- (NSString *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager mediaPathForView:(UIView *)view {
	NSString *path = @"";

	if ([TTCacheManager dataForURL:picPath]) {
		path = [TTCacheManager cachePathForPath:picPath];
	}
	return path;
}

- (void)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager downloadFile:(UIView *)view {
	if ([delegate respondsToSelector:@selector(picScalingFocus:downloadFile:)]) {
		[delegate picScalingFocus:self downloadFile:view];
	}
}

- (void)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager editBtnClicked:(UIButton *)editBtn editImage:(UIImage *)image {
	if ([delegate respondsToSelector:@selector(picScalingFocus:editBtnClicked:)]) {
		[delegate picScalingFocus:self editBtnClicked:image];
	}
}

- (void)mediaFocusManagerUninstall {
	if ([delegate respondsToSelector:@selector(focusManagerUninstall)]) {
		[delegate focusManagerUninstall];
	}
}

- (void)loadImageWithURL:(NSString *)imageUrl {
	if (!tjrDicRequest) tjrDicRequest = [[NSMutableDictionary alloc] init];

	if (nil != imageUrl) {
		NSData *data = [TTCacheManager dataForURL:imageUrl];
		if (nil != data) {
			self.focusManager.focusViewController.mainImageView.image  = [[[UIImage alloc] initWithData:data] autorelease];
			[focusManager installZoomView];
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
            
            [self requestDidStartLoad];
		}
	}
}

- (void)requestDidStartLoad{
	[self.focusManager startAnimating];
}

- (void)requestDidFinishLoad:(NSURLSessionDownloadTask *)task responseObject:(id)responseObject {
    
	UIImage *image = [[[UIImage alloc]initWithData:responseObject]autorelease];

	self.focusManager.focusViewController.mainImageView.image = image;
	[tjrDicRequest removeObjectForKey:[NSString stringWithFormat:@"%p", task]];
	[focusManager installZoomView];

	[self.focusManager stopAnimating];
}

- (void)request:(NSURLSessionDownloadTask *)task didFailLoadWithError:(NSError *)error {
	[tjrDicRequest removeObjectForKey:[NSString stringWithFormat:@"%p", task]];
	self.focusManager.focusViewController.mainImageView.image = [UIImage imageNamed:@"tjr_badimage_img.png"];
}

@end
