//
//  RecordToMp3.h
//  TJRtaojinroad
//
//  Created by Jeans on 4/16/13.
//  Copyright (c) 2018 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiceRecorderBaseVC.h"
#import "AudioToolbox/AudioToolbox.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@protocol RecordToMp3Delegate <NSObject>

- (void)RecordToMp3Finish:(NSString*)_fileName filePath:(NSString*)_path;
- (void)RecordToMp3UpdateMetersByAvgPower:(float)_avgPower;
- (void)RecordToMp3CountDonwTime:(NSInteger)_time;
@end

@interface RecordToMp3 : NSObject

@property (assign, nonatomic)   id<RecordToMp3Delegate>     delegate;
@property (retain, nonatomic)   AVAudioRecorder         *recorder;

- (void)beginRecordToMp3ByTalkId:(NSString*)_talkId;

- (void)stop;

@end
