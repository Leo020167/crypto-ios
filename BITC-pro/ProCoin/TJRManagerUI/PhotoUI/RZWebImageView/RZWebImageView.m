//
//  RZWebImageView.m
//  Redz
//
//  Created by Hay on 2018/9/30.
//  Copyright © 2018年 淘金路. All rights reserved.
//

#import "RZWebImageView.h"
#import <SDWebImageManager.h>
#import <SDImageCache.h>
#import <UIImageView+WebCache.h>

@interface RZWebImageView()
{
    
}

@property (copy, nullable,nonatomic) void (^imageDidTouchEvent)(void);

@end

@implementation RZWebImageView

- (void)dealloc
{
    RZReleaseSafe(_imageDidTouchEvent);
    [super dealloc];
}

#pragma mark - 判断该图片是否已存缓存
+ (BOOL)checkImageHasCache:(NSString *)urlStr
{
    BOOL hasCache = NO;
    SDImageCache *cache = [SDImageCache sharedImageCache];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    hasCache = [cache diskImageDataExistsWithKey:[manager cacheKeyForURL:[NSURL URLWithString:urlStr]]];
    
    return hasCache;
}

#pragma mark - 获取某网络图片的缓存UIImage数据类型
+ (UIImage *)getUIImageTypeFromUrl:(NSString *)urlStr
{
    UIImage *imageData = nil;
    if([RZWebImageView checkImageHasCache:urlStr]){
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        imageData = [(SDImageCache *)[manager imageCache] imageFromCacheForKey:urlStr];
        return imageData;
    }else{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        UIImage *imageData = [UIImage imageWithData:data];
        return imageData;
    }
}

#pragma mark - 显示网络图片
- (void)showImageWithUrl:(NSString *)urlStr imageCanTouch:(BOOL)canTouch imageDidTouchEvent:(void (^)(void))touchEvent
{
    if(canTouch){
        self.imageDidTouchEvent = touchEvent;
        [self showImageWithUrl:urlStr placeholderImage:RZWebImageViewDefaultPlaceHolderImage];
        self.userInteractionEnabled = YES;    // 开启touches事件
        UITapGestureRecognizer *gesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTapGestureRecognizer:)] autorelease];
        [self addGestureRecognizer:gesture];
    }else{
        [self showImageWithUrl:urlStr placeholderImage:RZWebImageViewDefaultPlaceHolderImage];
    }

}

- (void)showImageWithUrl:(NSString *)urlStr
{
    [self showImageWithUrl:urlStr imageCanTouch:NO imageDidTouchEvent:nil];
}

- (void)showImageWithUrl:(NSString *)urlStr placeholderImage:(UIImage *)placeholderImage
{
    [self sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:placeholderImage];
}

#pragma mark - 显示头像图片
- (void)showHeaderImageViewWithUrl:(NSString *)urlStr imageCanTouch:(BOOL)canTouch headerImageDidTouchEvent:(void (^)(void))touchEvent
{
    if(canTouch){
        self.imageDidTouchEvent = touchEvent;
        [self showImageWithUrl:urlStr placeholderImage:RZWebImageViewDefaultPlaceHolderImage];
        self.userInteractionEnabled = YES;    // 开启touches事件
        UITapGestureRecognizer *gesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTapGestureRecognizer:)] autorelease];
        [self addGestureRecognizer:gesture];
    }else{
        [self showHeaderImageViewWithUrl:urlStr placeholderImage:RZWebImageViewDefaultUserHeaderImage];
    }
}

- (void)showHeaderImageViewWithUrl:(NSString *)urlStr
{
    [self showHeaderImageViewWithUrl:urlStr imageCanTouch:NO headerImageDidTouchEvent:nil];
}

- (void)showHeaderImageViewWithUrl:(NSString *)urlStr placeholderImage:(UIImage *)placeholderImage
{
    [self sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:placeholderImage];
}

#pragma mark - 手势
- (void)imageDidTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    !_imageDidTouchEvent ? : _imageDidTouchEvent();
}

@end
