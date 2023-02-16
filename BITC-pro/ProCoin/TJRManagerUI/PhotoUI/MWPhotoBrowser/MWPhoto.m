//
//  MWPhoto.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"
#import "TTCacheManager.h"
#import "AFNetworking.h"
#import "TJRImageAndDownFile.h"

// Private
@interface MWPhoto () {
	// Image Sources
	NSURL *_photoURL;

	// Image
	UIImage *_underlyingImage;

	// Other
	NSString *_caption;
	BOOL _loadingInProgress;
}

// Properties
@property (nonatomic, retain) UIImage *underlyingImage;

// Methods
- (void)imageDidFinishLoadingSoDecompress;
- (void)imageLoadingComplete;

@end

// MWPhoto
@implementation MWPhoto

// Properties
@synthesize underlyingImage = _underlyingImage, caption = _caption;
@synthesize tag;

#pragma mark Class Methods

+ (MWPhoto *)photoWithImage:(UIImage *)image {
	return [[[MWPhoto alloc] initWithImage:image] autorelease];
}

+ (MWPhoto *)photoWithFilePath:(NSString *)path {
	return [[[MWPhoto alloc] initWithFilePath:path] autorelease];
}

+ (MWPhoto *)photoWithURL:(NSURL *)url {
	return [[[MWPhoto alloc] initWithURL:url] autorelease];
}

#pragma mark NSObject

- (id)initWithImage:(UIImage *)image {
	if ((self = [super init])) {
		self.underlyingImage = image;
	}
	return self;
}

- (id)initWithImage:(UIImage *)image andImageView:(UIImageView*)imageView{
    if ((self = [super init])) {
        self.underlyingImage = image;
        self.srcImageView = imageView;
    }
    return self;
}

- (id)initWithFilePath:(NSString *)path {
	if ((self = [super init])) {
		_photoPath = [path copy];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url {
	if ((self = [super init])) {
		_photoURL = [url copy];
	}
	return self;
}

- (void)dealloc {
	[self clearTjrDicRequest];

	if (tjrDicRequest) {
		[tjrDicRequest removeAllObjects];
	}
	TT_RELEASE_SAFELY(tjrDicRequest)

	[_caption release];
	[_photoPath release];
	[_photoURL release];
	[_underlyingImage release];
	[super dealloc];
}

#pragma mark MWPhoto Protocol Methods

- (UIImage *)underlyingImage {
	return _underlyingImage;
}

- (void)loadUnderlyingImageAndNotify {
	NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
	_loadingInProgress = YES;

	if (self.underlyingImage) {
		// Image already loaded
		[self imageLoadingComplete];
	} else {
		if (_photoPath) {
			// Start an async download
			// Load async from web (using SDWebImage)
			UIImage *cachedImage = [UIImage imageWithData:[TTCacheManager dataForURL:_photoPath]];

			if (cachedImage) {
				// Use the cached image immediatly
				self.underlyingImage = cachedImage;
				[self imageDidFinishLoadingSoDecompress];
			} else {
				[self loadImageWithURL:_photoPath];
			}
		} else {
			// Failed - no source
			self.underlyingImage = nil;
			[self imageLoadingComplete];
		}
	}
}

// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
	_loadingInProgress = NO;

	if (self.underlyingImage && (_photoPath || _photoURL)) {
		self.underlyingImage = nil;
	}
}

#pragma mark - Async Loading

// Called in background
// Load image in background from local file
- (void)loadImageFromFileAsync {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	@try {
		NSError *error = nil;
		NSData *data = [NSData dataWithContentsOfFile:_photoPath options:NSDataReadingUncached error:&error];

		if (!error) {
			self.underlyingImage = [[[UIImage alloc] initWithData:data] autorelease];
		} else {
			self.underlyingImage = nil;
			MWLog(@"Photo from file error: %@", error);
		}
	} @catch(NSException *exception) {} @finally {
		[self performSelectorOnMainThread:@selector(imageDidFinishLoadingSoDecompress) withObject:nil waitUntilDone:NO];
		[pool drain];
	}
}

// Called on main
- (void)imageDidFinishLoadingSoDecompress {
	NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");

	if (self.underlyingImage) {
		// Decode image async to avoid lagging when UIKit lazy loads
	} else {
		// Failed
		[self imageLoadingComplete];
	}
}

- (void)imageLoadingComplete {
	NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
	// Complete so notify
	_loadingInProgress = NO;
	[[NSNotificationCenter defaultCenter]	postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
											object				:self];
}

- (void)loadImageWithURL:(NSString *)imageUrl {
	if (!tjrDicRequest) tjrDicRequest = [[NSMutableDictionary alloc] init];

	if (nil != imageUrl) {
		NSData *data = [TTCacheManager dataForURL:imageUrl];

		if (nil != data) {
			self.underlyingImage = [[[UIImage alloc] initWithData:data] autorelease];
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

            if (imageUrl) {
                self.underlyingImage = [UIImage imageNamed:imgDefault];
            }
		}
	}
}

- (void)requestDidStartLoad{

}

- (void)requestDidFinishLoad:(NSURLSessionDownloadTask *)task responseObject:(id)responseObject {
    
	UIImage *image = [[[UIImage alloc]initWithData:responseObject]autorelease];
	self.underlyingImage = image;
	[tjrDicRequest removeObjectForKey:[NSString stringWithFormat:@"%p", task]];
	[self imageLoadingComplete];
}

- (void)request:(NSURLSessionDownloadTask *)task didFailLoadWithError:(NSError *)error {
    
	[tjrDicRequest removeObjectForKey:[NSString stringWithFormat:@"%p", task]];
	[self imageLoadingComplete];
}

- (void)clearTjrDicRequest {
	for (NSURLSessionDataTask *task in [tjrDicRequest objectEnumerator]) {
		[task cancel];
	}
}

@end

