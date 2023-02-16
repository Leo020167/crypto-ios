//
//  VoiceRecorderBaseVC.h
//  TJRtaojinroad
//
//  Created by Jeans on 3/23/13.
//  Copyright (c) 2018 Taojinroad. All rights reserved.
//

#import "TJRBaseViewController.h"


//默认最大录音时间
#define kDefaultMaxRecordTime               60

@protocol VoiceRecorderBaseVCDelegate <NSObject>

- (void)VoiceRecorderBaseVCRecordFinish:(NSString *)_filePath fileName:(NSString*)_fileName;

@end

@interface VoiceRecorderBaseVC : TJRBaseViewController{
    
@protected
    NSInteger               maxRecordTime;  //最大录音时间
    NSString                *recordFileName;//录音文件名
    NSString                *recordFilePath;//录音文件路径
}

@property (assign, nonatomic)           id<VoiceRecorderBaseVCDelegate> vrbDelegate;

@property (assign, nonatomic)           NSInteger               maxRecordTime;//最大录音时间
@property (copy, nonatomic)             NSString                *recordFileName;//录音文件名
@property (copy, nonatomic)             NSString                *recordFilePath;//录音文件路径

/**
 生成当前时间字符串
 @returns 当前时间字符串
 */
+ (NSString*)getCurrentTimeString;

/**
 获取缓存路径
 @returns 缓存路径
 */
+ (NSString*)getCacheDirectory;

/**
 判断文件是否存在
 @param _path 文件路径
 @returns 存在返回yes
 */
+ (BOOL)fileExistsAtPath:(NSString*)_path;

/**
 删除文件
 @param _path 文件路径
 @returns 成功返回yes
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path;


#pragma mark -

/**
 生成文件名
 @param _userId 用户id
 @param _topicId 房间id
 @param _type 文件类型
 @returns 文件名
 */
+ (NSString*)getFileNameByUserId:(NSString*)_userId topicId:(NSString*)_topicId;
+ (NSString*)getFileNameByUserId:(NSString*)_userId topicId:(NSString*)_topicId type:(NSString*)_type;


/**
 生成文件路径
 @param _fileName 文件名
 @param _type 文件类型
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName;
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type;

/**
 获取录音设置
 @returns 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict;

//获取wav转MP3的录音设置
+ (NSDictionary*)getWavToMp3RecorderSettingDict;
@end
