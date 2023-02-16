//
//  RecordToMp3.m
//  TJRtaojinroad
//
//  Created by Jeans on 4/16/13.
//  Copyright (c) 2018 Taojinroad. All rights reserved.
//

#import "RecordToMp3.h"
#import "lame.h"
#import "ConvertToMp3.h"
#import "CommonUtil.h"

#define kHeadSize           4*1024

@interface RecordToMp3()<AVAudioRecorderDelegate>{
    AVAudioRecorder         *recorder;
    BOOL                    isConverting;
    NSInteger               curBlockNum;
    BOOL                    isFirst;
    NSTimer                 *meterTimer;
    NSInteger               maxRecordTime;      //最大录音时间
    CGFloat                 curCount;           //当前计数,初始为0
}

@property (copy, nonatomic)     NSString                *wavName;
@property (copy, nonatomic)     NSString                *wavPath;
@property (retain, nonatomic)   NSMutableData           *mp3Data;
@end

@implementation RecordToMp3
@synthesize delegate,wavName,wavPath,mp3Data,recorder;

FILE    *pcm;
//FILE    *mp3;
const int PCM_SIZE = 8192;
const int MP3_SIZE = 8192;
short int pcm_buffer[PCM_SIZE*2];
unsigned char mp3_buffer[MP3_SIZE];
int read1, write1;
lame_t lame;

- (void)dealloc{
    [mp3Data release];
    [wavName release];
    [wavPath release];
    [recorder release];
    [super dealloc];
}

- (id)init{
    self = [super init];
    if (self) {
        maxRecordTime = kDefaultMaxRecordTime;
    }
    return self;
}

- (void)beginRecordToMp3ByTalkId:(NSString*)_talkId{
    if ([CommonUtil canRecord]) {//是否有麦克风权限
        NSLog(@"开始录音");
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        self.wavName = [VoiceRecorderBaseVC getFileNameByUserId:ROOTCONTROLLER_USER.userId topicId:_talkId];
        
        NSURL *wavUrl = [NSURL fileURLWithPath:[VoiceRecorderBaseVC getPathByFileName:wavName ofType:@"wav"]];  //文件名的设置
        self.wavPath = [wavUrl absoluteString];
        
        NSLog(@"录音文件:%@",wavPath);
        
        NSError* recorderSetupError   = nil;
        self.recorder = [[[AVAudioRecorder alloc] initWithURL:wavUrl settings:[VoiceRecorderBaseVC getWavToMp3RecorderSettingDict] error:&recorderSetupError]autorelease];
        recorder.delegate = self;
        recorder.meteringEnabled = YES;
        
        if ([recorder prepareToRecord] == NO)
            NSLog(@"不能准备录音");
        
        if (recorderSetupError)
            NSLog(@"error:%@",[recorderSetupError localizedDescription]);
        
        [recorder record];
        
            //监听音频
        [self startMeterTimer];
        
            //还原计数
        curCount = 0;
        
            //还原
        curBlockNum = kHeadSize;
        
        self.mp3Data = [[[NSMutableData alloc]init]autorelease];
        isFirst = NO;
        
        lame = lame_init();
        lame_set_in_samplerate(lame, kLameSample);     //设置采样率
        lame_set_VBR_max_bitrate_kbps(lame,kLameKbs);//设置码率
        lame_set_VBR(lame, vbr_default);
        lame_set_num_channels(lame,kLameChannels);          //设置通道
        lame_init_params(lame);
        
        pcm = fopen([[[VoiceRecorderBaseVC getCacheDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",wavName] ]cStringUsingEncoding:1], "rb");  //source
        
            //边录边转
        [NSThread detachNewThreadSelector:@selector(recordingAndConverting) toTarget:self withObject:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringForKey(@"提示") message:@"录音需要您的麦克风权限,请允许访问您的麦克风" delegate:self cancelButtonTitle:NSLocalizedStringForKey(@"取消") otherButtonTitles:NSLocalizedStringForKey(@"设置"), nil];
        [alertView show];
        RELEASE(alertView);
    }
}

#pragma mark - 麦克风权限提示alertView回调
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)recordingAndConverting{
    if (recorder.isRecording) {
        
        isConverting = YES;
        
        NSData *data = [[NSData alloc]initWithContentsOfFile:[[VoiceRecorderBaseVC getCacheDirectory] stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.wav",wavName]]];
        
        NSLog(@"recording.当前总data:%lu",(unsigned long)data.length);
        
        if (data.length > curBlockNum + 4*PCM_SIZE) {
            //数据大过头信息
            NSLog(@"当前正在准备:%ld",(long)curBlockNum);
            if (isFirst == NO){
                fseek(pcm, 4*1024, SEEK_CUR);
                isFirst = YES;
            }else{
                fseek(pcm, curBlockNum,SEEK_SET);
            }
            
            curBlockNum += 4*PCM_SIZE;
            
            //
            read1 = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            
            write1 = lame_encode_buffer_interleaved(lame, pcm_buffer, read1, mp3_buffer, MP3_SIZE);
            
            [mp3Data appendBytes:mp3_buffer length:write1];
            
            NSLog(@"recording---read:%d,write:%d",read1,write1);
        }
        
        isConverting = NO;
        
        [data release];
        
        //0.6  0.8
        [NSThread sleepForTimeInterval:0.1];

        [self recordingAndConverting];
        
    }else{
        //已经停止录音
        if (isConverting)
            [self performSelector:@selector(convertTheLast) withObject:nil afterDelay:0.5];
        else
            @try {
                [self convertTheLast];
            }
        @catch (NSException *exception) {
        }
        
    }
}

- (void)convertTheLast{
    
    //完成剩下转码
    NSLog(@"完成剩下");
    fseek(pcm, curBlockNum,SEEK_SET);
    
    do {
        
        read1 = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
        
        if (read1 == 0)
            write1 = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
        else
            write1 = lame_encode_buffer_interleaved(lame, pcm_buffer, read1, mp3_buffer, MP3_SIZE);
        
        [mp3Data appendBytes:mp3_buffer length:write1];
        
        NSLog(@"---read:%d,write:%d",read1,write1);
        
    } while (read1 != 0);
    NSLog(@"全部完成");
    lame_close(lame);
    
    [mp3Data writeToFile:[VoiceRecorderBaseVC getPathByFileName:wavName ofType:@"mp3"] atomically:YES];
    
    fclose(pcm);
    
    //回调
    if ([delegate respondsToSelector:@selector(RecordToMp3Finish:filePath:)])
    {
        [delegate RecordToMp3Finish:wavName filePath:[VoiceRecorderBaseVC getPathByFileName:wavName ofType:@"mp3"]];
    }
    //删除wav文件
    if ([[NSFileManager defaultManager]fileExistsAtPath:[VoiceRecorderBaseVC getPathByFileName:wavName ofType:@"wav"]])
        [[NSFileManager defaultManager]removeItemAtPath:[VoiceRecorderBaseVC getPathByFileName:wavName ofType:@"wav"] error:nil];
}

- (void)stop{
    if (recorder.isRecording){
        //
        [self stopMeterTimer];

        [recorder stop];
        NSLog(@"停止录音");
    }
}
#pragma mark - 启动音波定时器
- (void)startMeterTimer{
    meterTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:meterTimer forMode:NSRunLoopCommonModes];
    [meterTimer fire];
}
#pragma mark - 更新音频峰值
- (void)updateMeters{
    if (recorder.isRecording){
        
        //倒计时       
        if ([delegate respondsToSelector:@selector(RecordToMp3CountDonwTime:)]){
            [delegate RecordToMp3CountDonwTime:(int)(maxRecordTime-curCount+1)];
        }
        
        if (curCount > maxRecordTime+0.5){
            //时间到
            [self stop];
        }
        //更新峰值
        [recorder updateMeters];
        
        if ([delegate respondsToSelector:@selector(RecordToMp3UpdateMetersByAvgPower:)])
            [delegate RecordToMp3UpdateMetersByAvgPower:[recorder averagePowerForChannel:0]];
        
        curCount += 0.1f;
    }
}

#pragma mark - 停止音波定时器
- (void)stopMeterTimer{
    if (meterTimer && meterTimer.isValid){
        [meterTimer invalidate];
        meterTimer = nil;
    }
}
#pragma mark - AVAudioRecorder Delegate Methods
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"录音停止");
    [self stopMeterTimer];
}
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    NSLog(@"录音开始中断");
    [self stopMeterTimer];
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags{
    NSLog(@"录音中断");
    [self stopMeterTimer];
}

@end
