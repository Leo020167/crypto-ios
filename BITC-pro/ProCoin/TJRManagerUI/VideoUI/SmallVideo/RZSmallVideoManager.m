//
//  RZSmallVideoManager.m
//  MyWorkProject
//
//  Created by Hay on 2018/9/6.
//  Copyright © 2018年 Hay. All rights reserved.
//

#import "RZSmallVideoManager.h"
#import "RZSmallVideoPlayController.h"

@interface RZSmallVideoManager()
{
    
}
@property (retain, nonatomic) UIWindow *videoWindow;                      //视频播放页面

@end

@implementation RZSmallVideoManager

- (instancetype)init
{
    self = [super init];
    if(self){
        
    }
    return self;
}



- (void)dealloc
{
    RZReleaseSafe(_videoWindow);
    [super dealloc];
}

- (void)showVideoViewWithUrlString:(NSString *)urlString coverImageUrl:(NSString *)coverImageUrl
{
    self.videoWindow = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    RZSmallVideoPlayController *videoPlayer = [[[RZSmallVideoPlayController alloc] init] autorelease];
    videoPlayer.videoUrl = urlString;
    videoPlayer.coverImageUrl = coverImageUrl;
    __block typeof(self) weakSelf = self;
    videoPlayer.closePlayVideoEvent = ^{
        [weakSelf playViewClosedButtonPressed];
    };
    _videoWindow.rootViewController = videoPlayer;
    _videoWindow.windowLevel = UIWindowLevelAlert;
    _videoWindow.backgroundColor = [UIColor blackColor];
    [_videoWindow makeKeyAndVisible];
    
}

- (void)showVideoViewWithPHAsset:(PHAsset *)asset
{
    self.videoWindow = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    RZSmallVideoPlayController *videoPlayer = [[[RZSmallVideoPlayController alloc] init] autorelease];
    videoPlayer.videoPHAsset = asset;
    __block typeof(self) weakSelf = self;
    videoPlayer.closePlayVideoEvent = ^{
        [weakSelf playViewClosedButtonPressed];
    };
    _videoWindow.rootViewController = videoPlayer;
    _videoWindow.windowLevel = UIWindowLevelAlert;
    _videoWindow.backgroundColor = [UIColor blackColor];
    [_videoWindow makeKeyAndVisible];
}


#pragma mark - rzSmallVideoPlayView delegate
- (void)playViewClosedButtonPressed
{
    [UIView animateWithDuration:0.3 animations:^{
        _videoWindow.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.videoWindow = nil;
        //因为window已经允许旋转了，所以退出这个页面必须强行转回来
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    }];
}



@end
