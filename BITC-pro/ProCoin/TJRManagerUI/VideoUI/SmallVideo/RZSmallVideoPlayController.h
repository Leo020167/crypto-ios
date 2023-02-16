//
//  RZSmallVideoPlayController.h
//  MyWorkProject
//
//  Created by Hay on 2018/9/11.
//  Copyright © 2018年 Hay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRBaseViewController.h"
#import <Photos/Photos.h>

@interface RZSmallVideoPlayController : TJRBaseViewController

@property (copy, nonatomic) NSString * _Nullable videoUrl;                 //视频url
@property (copy, nonatomic) NSString * _Nullable coverImageUrl;            //封面url
@property (retain, nonatomic,nonnull) PHAsset *videoPHAsset;            //相册视频文件资源
@property (copy, nonatomic) void (^ _Nullable closePlayVideoEvent)(void);              //关闭block

@end
