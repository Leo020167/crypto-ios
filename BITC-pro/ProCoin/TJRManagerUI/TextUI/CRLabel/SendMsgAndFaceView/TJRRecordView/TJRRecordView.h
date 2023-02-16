//
//  TJRRecordView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 14-6-4.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PICircularProgressView.h"
#import "AudioToolbox/AudioToolbox.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "lame.h"

typedef enum RecordType {
	RecordType_Normal,	/* 正常状态 */
	RecordType_Record,	/* 按住录音状态 */
	RecordType_StopPlay,/* 没有播放状态 */
	RecordType_Play	/* 播放状态 */
} RecordType;

@protocol TJRRecordDelegate <NSObject>

- (void)TJRRecordViewRecordFinish:(BOOL)isSaveFile;

@end

@interface TJRRecordView : UIView <AVAudioRecorderDelegate, AVAudioPlayerDelegate>{
	RecordType recordType;
	NSInteger recordLength;	/* 录音时长,跨度为0.1秒 */
	NSInteger playLength;	/* 当前播放时长,,跨度为0.1秒 */
	NSTimer *recordTimer;
	NSTimer *playTimer;
	AVAudioRecorder *recorder;
	AVAudioPlayer *voicePlayer;
	NSString *fileName;
	NSMutableData *mp3Data;
}

@property (retain, nonatomic) IBOutlet UIView *allView;
@property (retain, nonatomic) IBOutlet UIImageView *ivBtnBg;
@property (retain, nonatomic) IBOutlet PICircularProgressView *progressView;
@property (retain, nonatomic) IBOutlet UIButton *btnRecord;
@property (retain, nonatomic) IBOutlet UIImageView *ivWaveL1;
@property (retain, nonatomic) IBOutlet UIImageView *ivWaveL2;
@property (retain, nonatomic) IBOutlet UIImageView *ivWaveL3;
@property (retain, nonatomic) IBOutlet UIImageView *ivWaveR1;
@property (retain, nonatomic) IBOutlet UIImageView *ivWaveR2;
@property (retain, nonatomic) IBOutlet UIImageView *ivWaveR3;
@property (retain, nonatomic) IBOutlet UILabel *lbShowText;
@property (retain, nonatomic) IBOutlet UIButton *btnReRecord;
@property (retain, nonatomic) IBOutlet UILabel *lbShowTime;

@property (copy, nonatomic) NSString *userId;	/* 录音用户的Id,默认为当前用户的Id */
@property (assign, nonatomic) id <TJRRecordDelegate> delegate;


/**
 *   子类实现方法
 */
- (void)initData;
- (void)finish:(BOOL)hasData;



/**
 *   将当前语音保存到缓存
 *   @param url  语音url
 */
- (void)saveVoiceToCacheWithUrl:(NSString *)url;

/**
 *    当前语音长度
 *    @returns
 */
- (NSInteger)recordTimeLength;

/**
 *    生成路径
 *    @param fName 文件名
 *    @param type  文件类型
 *    @returns 路径
 */
- (NSString *)createFilePath:(NSString *)fName type:(NSString *)type;

/**
 *    获得MP3文件名
 *    @returns (不存在Mp3文件时,就为空)
 */
- (NSString *)getMp3FileName;

/**
 *     是否存在录音文件
 *    @returns Yes有录音文件,反之没有
 */
- (BOOL)isHasRecordFile;

/**
 *    是否存在amr文件
 *    @returns Yes有amr文件,反之没有
 */
- (BOOL)isHasAmrFile:(NSString *)fName;

/**
 *   文件是否存在
 *   @param path  路径
 *   @returns
 */
- (BOOL)isHasFile:(NSString *)path;

/**
 *    删除当前的语音文件
 */
- (void)deleteRecordFile;

/**
 *    删除文件
 *    @param fName 文件名
 *    @param type  文件类型
 */
- (void)deleteRecordFile:(NSString *)fName type:(NSString *)type;
@end

