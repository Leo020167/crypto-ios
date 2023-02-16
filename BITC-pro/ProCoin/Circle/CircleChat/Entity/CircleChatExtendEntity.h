//
//  CircleChatExtendEntity.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12/7/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "CircleChatEntity.h"

@interface CircleChatExtendEntity : CircleChatEntity


@property (assign, nonatomic) BOOL isClicked;              //是否被选中
@property (assign, nonatomic) BOOL isDownloadFinish;       //图片下载完成
@property (assign, nonatomic) BOOL isUploading;            //信息正在上传
@property (assign, nonatomic) BOOL isUploadFailed;         //信息上传完成
@property (assign, nonatomic) BOOL isPlaying;              //语音cell专用，判断是否播放中
@property (assign, nonatomic) BOOL isResend;               //是否需要重发，只在链接断开时。


@property (retain, nonatomic) NSDictionary *componentsDictionary;
@property (assign, nonatomic) CGSize imgSize;
@property (copy, nonatomic) NSString* timeFormat;
@property (copy, nonatomic) NSString* voiceLength;

@property (assign, nonatomic) NSInteger timeout;           //计时器
@property (assign, nonatomic) float cellHeight;

+ (CircleChatExtendEntity*)toExtendEntity:(CircleChatEntity*)entity;
@end
