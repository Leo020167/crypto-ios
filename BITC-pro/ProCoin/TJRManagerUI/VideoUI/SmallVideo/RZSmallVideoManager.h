//
//  RZSmallVideoManager.h
//  MyWorkProject
//
//  Created by Hay on 2018/9/6.
//  Copyright © 2018年 Hay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface RZSmallVideoManager : NSObject


- (instancetype)init;

/** 显示播放视频*/
- (void)showVideoViewWithUrlString:(NSString *)urlString coverImageUrl:(NSString *)coverImageUrl;

- (void)showVideoViewWithPHAsset:(PHAsset *)asset;


@end
