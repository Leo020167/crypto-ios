//
//  VoiceRecorderBaseVC.m
//  TJRtaojinroad
//
//  Created by Jeans on 3/23/13.
//  Copyright (c) 2018 Taojinroad. All rights reserved.
//

#import "VoiceRecorderBaseVC.h"
#import "TTCacheManager.h"
#import "CommonUtil.h"
#import "TTURLCache.h"

#define kLameSample         11025            //采样率
#define kLameKbs            16              //码率
#define kLameChannels       2               //通道数

@interface VoiceRecorderBaseVC ()
@end

@implementation VoiceRecorderBaseVC
@synthesize vrbDelegate,maxRecordTime,recordFileName,recordFilePath;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        maxRecordTime = kDefaultMaxRecordTime;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [recordFilePath release];
    [recordFileName release];
    [super dealloc];
}

/**
	生成当前时间字符串
	@returns 当前时间字符串
 */
+ (NSString*)getCurrentTimeString
{
    NSDateFormatter *dateformat=[[[NSDateFormatter  alloc]init]autorelease];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    return [dateformat stringFromDate:[NSDate date]];
}


/**
	获取缓存路径
	@returns 缓存路径
 */
+ (NSString*)getCacheDirectory
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* cachesPath = [paths objectAtIndex:0];
//    NSString* cachePath = [[cachesPath stringByAppendingPathComponent:kDefaultCacheName] stringByAppendingPathComponent:VoiceDefaultCacheName];

    NSString* cachePath = [cachesPath stringByAppendingPathComponent:kDefaultCacheName];
    
    return cachePath;
}

/**
	判断文件是否存在
	@param _path 文件路径
	@returns 存在返回yes
 */
+ (BOOL)fileExistsAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:_path];
}

/**
	删除文件
	@param _path 文件路径
	@returns 成功返回yes
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}
/**
 生成文件名
 @param _userId 用户id
 @param _topicId 房间id
 @returns 文件名
 */
+ (NSString*)getFileNameByUserId:(NSString*)_userId topicId:(NSString*)_topicId{
    return [NSString stringWithFormat:@"%@_%@_%@",[VoiceRecorderBaseVC getCurrentTimeString],_topicId,_userId];
}

/**
	生成文件名
	@param _userId 用户id
	@param _topicId 房间id
	@param _type 文件类型
	@returns 文件名
 */
+ (NSString*)getFileNameByUserId:(NSString*)_userId topicId:(NSString*)_topicId type:(NSString*)_type
{
    return [NSString stringWithFormat:@"%@_%@_%@.%@",[VoiceRecorderBaseVC getCurrentTimeString],_topicId,_userId,_type];
}

/**
	生成文件路径
	@param _fileName 文件名
	@param _type 文件类型
	@returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString* fileDirectory = @"";
    if ([VoiceRecorderBaseVC getCacheDirectory] && [[VoiceRecorderBaseVC getCacheDirectory] isKindOfClass:[NSString class]]) {
        fileDirectory = [[[VoiceRecorderBaseVC getCacheDirectory]stringByAppendingPathComponent:_fileName]stringByAppendingPathExtension:_type];
    }
    return fileDirectory;
}

/**
 生成文件路径
 @param _fileName 文件名
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName{
    NSString* fileDirectory = [[VoiceRecorderBaseVC getCacheDirectory]stringByAppendingPathComponent:_fileName];
    return fileDirectory;
}

/**
	获取录音设置
	@returns 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
//                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
//                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
//                                   [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   nil];
    return [recordSetting autorelease];
    
//    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                   [NSNumber numberWithFloat: 44100],AVSampleRateKey, //采样率
//                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
////                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
//                                   [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,//通道的数目
////                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
//                                   [NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,
//                                   nil];//采样信号是整数还是浮点数
//    return [recordSetting autorelease];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100],                  AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatLinearPCM],                   AVFormatIDKey,
                              [NSNumber numberWithInt: 2],                              AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMedium],                       AVEncoderAudioQualityKey,
                              nil];
    return settings;
}

//获取wav转MP3的录音设置
+ (NSDictionary*)getWavToMp3RecorderSettingDict{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: kLameSample],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:kLameKbs],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: kLameChannels], AVNumberOfChannelsKey,//通道的数目
                                   //                                       [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   //                                       [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   nil];
    return [recordSetting autorelease];
}

@end
