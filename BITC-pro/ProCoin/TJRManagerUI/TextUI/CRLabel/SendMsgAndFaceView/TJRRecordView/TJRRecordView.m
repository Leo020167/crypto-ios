//
//  TJRRecordView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-6-4.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRRecordView.h"
#import "CommonUtil.h"
#import "TTCacheManager.h"
#import "TJRImageAndDownFileBaseView.h"
#import "ConvertToMp3.h"
#import "TJRVoicePlayView.h"

const NSInteger maxRecordTime = 599;
const CGFloat timerInterval = 0.2;

int const PCMSIZE = 8192;
int const MP3SIZE = 8192;
int const KHEADSIZE = 4096 /* 4*1024 */;

FILE *r_pcm;
short int r_pcm_buffer[PCMSIZE * 2];
unsigned char r_mp3_buffer[MP3SIZE];
int r_read1, r_write1;
lame_t r_lame;
NSInteger curBlockNum;

@implementation TJRRecordView

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

	if (self) {
		[self initTJRRecordView];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		[self initTJRRecordView];
	}
	return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.allView.frame = self.bounds;
}

- (void)initTJRRecordView {
	[[NSBundle mainBundle] loadNibNamed:@"TJRRecordView" owner:self options:nil];
	self.allView.frame = self.bounds;
	[self addSubview:self.allView];
    [self initData];
}

- (void)initData {
    recordType = RecordType_Normal;
    _progressView.roundedHeadName = @"TJRRecordView_icon_header";
    self.userId = ROOTCONTROLLER_USER.userId;
    _ivBtnBg.animationImages = [NSArray arrayWithObjects:
                                [UIImage imageNamed:@"TJRRecordView_btn_bg_record_gray"],
                                [UIImage imageNamed:@"TJRRecordView_btn_bg_record_red"], nil];
    _ivBtnBg.animationDuration = 0.5;
    _ivBtnBg.animationRepeatCount = 0;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startRecordAction:)];
    [_btnRecord addGestureRecognizer:longPress];
    RELEASE(longPress);
}

- (void)startRecordAction:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            break;
        default:
            if (recordType == RecordType_Record) {
                [self stopRecord];	/* 停止录音 */
            }
            break;
    }
}

- (IBAction)recordDownAction:(UIButton *)sender {
    if (recordType == RecordType_Normal) {
        [self startRecord];	/* 开始录音 */
    }
}

- (IBAction)recordAction:(UIButton *)sender {
    if (recordType == RecordType_Record) {
        [self stopRecord];	/* 停止录音 */
    } else if (recordType == RecordType_StopPlay) {
		[self startPlayRecord];	/* 播放 */
	} else if (recordType == RecordType_Play) {
		[self stopPlayRecord];	/* 暂停 */
	}
}

#pragma mark - 重录按钮
- (IBAction)reRecordAction:(id)sender {
	if (recordType == RecordType_Play) {
		[self stopPlayRecord];
	}

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:@"重录将删除刚才的录音" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"重录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self deleteRecordFile];
        [self finish:NO];
    }]];
    [ROOTCONTROLLER presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - 开始录音

/**
 *    开始录音
 */
- (void)startRecord {
    if ([CommonUtil canRecord]) {//是否有麦克风权限
        [[NSNotificationCenter defaultCenter] postNotificationName:TJRVoicePlayViewPlayKey object:nil userInfo:nil];
        recordType = RecordType_Record;
        [self setBtnRecordImageWithRecordType:recordType];
        [self deleteRecordFile:fileName type:@"wav"];	/* 删除旧录音文件 */
        [self createFileName];	/* 生成录音文件的文件名 */
        NSString *path = [self createFilePath:fileName type:@"wav"];
        
        NSError* recorderSetupError   = nil;
        recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:path] settings:[self getAudioRecorderSettingDict] error:&recorderSetupError];
        recorder.delegate = self;
        recorder.meteringEnabled = YES;
        if (recorderSetupError) {
            NSLog(@"error:%@",[recorderSetupError localizedDescription]);
            printf("%s",[[recorderSetupError localizedDescription] UTF8String]);
        }
        
        [recorder prepareToRecord];
        recordLength = 0;	/* 还原计数 */
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [recorder record];	/* 开始录音 */
        [self startRecordTimer];
        
            //还原
        curBlockNum = KHEADSIZE;
        
        RELEASE(mp3Data);
        mp3Data = [NSMutableData new];
        
        r_lame = lame_init();
        lame_set_in_samplerate(r_lame, kLameSample);     //设置采样率
        lame_set_VBR_max_bitrate_kbps(r_lame,kLameKbs);//设置码率
        lame_set_VBR(r_lame, vbr_default);
        lame_set_num_channels(r_lame,kLameChannels);          //设置通道
        lame_init_params(r_lame);
        
        r_pcm = fopen([path cStringUsingEncoding:1], "rb");  //source
        
            //边录边转
        [NSThread detachNewThreadSelector:@selector(converToMp3ByRecordWithIsFirst:) toTarget:self withObject:[NSNumber numberWithBool:YES]];
    } else {

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:@"录音需要您的麦克风权限,请允许访问您的麦克风" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"设置") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }]];
        [ROOTCONTROLLER presentViewController:alertController animated:YES completion:nil];
    }
}


- (void)converToMp3ByRecordWithIsFirst:(NSNumber *)number {
    BOOL isFirst = number ? number.boolValue : NO;
    if (recorder.isRecording) {
        NSData *data = [[NSData alloc]initWithContentsOfFile:[self createFilePath:fileName type:@"wav"]];
        /* NSLog(@"recording.当前总data:%d",data.length); */
        if (data.length > curBlockNum + 4*PCMSIZE) { /* 数据大过头信息 */
            /* NSLog(@"当前正在准备:%d",curBlockNum); */
            if (isFirst == NO){
                fseek(r_pcm, 4*1024, SEEK_CUR);
                isFirst = YES;
            }else{
                fseek(r_pcm, curBlockNum,SEEK_SET);
            }//unsigned long
            curBlockNum += 4*PCMSIZE;
            r_read1 = (int)fread(r_pcm_buffer, 2*sizeof(short int), PCMSIZE, r_pcm);
            r_write1 = lame_encode_buffer_interleaved(r_lame, r_pcm_buffer, r_read1, r_mp3_buffer, MP3SIZE);
            [mp3Data appendBytes:r_mp3_buffer length:r_write1];
            NSLog(@"recording---read:%d,write:%d",r_read1,r_write1);
        }
        RELEASE(data);
        [NSThread sleepForTimeInterval:timerInterval];
        [self converToMp3ByRecordWithIsFirst:nil];
    } else {
        /* NSLog(@"完成剩下"); */
        fseek(r_pcm, curBlockNum,SEEK_SET);
        do {
            r_read1 = (int)fread(r_pcm_buffer, 2*sizeof(short int), PCMSIZE, r_pcm);
            if (r_read1 == 0) {
                 r_write1 = lame_encode_flush(r_lame, r_mp3_buffer, MP3SIZE);
            } else {
                r_write1 = lame_encode_buffer_interleaved(r_lame, r_pcm_buffer, r_read1, r_mp3_buffer, MP3SIZE);
            }
            [mp3Data appendBytes:r_mp3_buffer length:r_write1];
            /* NSLog(@"---read:%d,write:%d",r_read1,r_write1); */
        } while (r_read1 != 0);
        /* NSLog(@"全部完成"); */
        lame_close(r_lame);
        if (mp3Data.length>0) {
            [mp3Data writeToFile:[self createFilePath:fileName type:@"mp3"] atomically:YES];
        }
        RELEASE(mp3Data);
        fclose(r_pcm);
        
        // 提交至main queue的任务会在主线程中执行
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_delegate && [_delegate respondsToSelector:@selector(TJRRecordViewRecordFinish:)]) {
                [_delegate TJRRecordViewRecordFinish:TTIsStringWithAnyText([self getMp3FileName])];
            }
            [self finish:(recordLength > 10)];
        });
        
    }
}

/**
 *   子类实现方法
 */
- (void)finish:(BOOL)hasData{
}

/**
 *   获取录音设置(MP3的参数)
 *   @returns 录音设置
 */
- (NSDictionary *)getAudioRecorderSettingDict {
	return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat: kLameSample],AVSampleRateKey,/* 采样率 */
            [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
            [NSNumber numberWithInt:kLameKbs],AVLinearPCMBitDepthKey,/* 采样位数 默认 16 */
            [NSNumber numberWithInt: kLameChannels], AVNumberOfChannelsKey,/* 通道的数目 */
            nil];
}

#pragma mark - 停止录音

/**
 *    停止录音
 */
- (void)stopRecord {
	[self stopRecordTimer];
	[_ivBtnBg stopAnimating];
    if (!recorder || !recorder.isRecording) return;
    
    [recorder stop];
    RELEASE(recorder);

	if (recordLength > 10) {
		recordType = RecordType_StopPlay;
		[self setBtnRecordImageWithRecordType:recordType];
	} else {
		recordType = RecordType_Normal;
		[self setBtnRecordImageWithRecordType:recordType];
	}
}

#pragma mark - 根据type设置按钮的样子
- (void)setBtnRecordImageWithRecordType:(RecordType)type {
	NSString *imageName = nil;

	switch (type) {
		case RecordType_Normal:
			imageName = @"TJRRecordView_icon_record";
			_btnReRecord.hidden = YES;
			_lbShowText.text = @"长按开始录音";
			_lbShowTime.hidden = YES;
			_progressView.hidden = YES;
            _progressView.progress = 1.0f;
			[self hideWavesImage:NO];
			break;

		case RecordType_Record:
			imageName = @"TJRRecordView_icon_record_select";
			_lbShowText.text = @"松开停止录音";
			_progressView.hidden = NO;
			break;

		case RecordType_StopPlay:
			imageName = @"TJRRecordView_icon_play";
			_lbShowTime.hidden = NO;
			_lbShowTime.text = [NSString stringWithFormat:@"%ld''", (long)[self recordTimeLength]];
			_lbShowText.text = @"点击播放";
			_btnReRecord.hidden = NO;
			_progressView.hidden = YES;
            _progressView.progress = 0.0f;
			[self hideWavesImage:YES];
			break;

		case RecordType_Play:
			imageName = @"TJRRecordView_icon_stop";
			_progressView.hidden = NO;
			_lbShowText.text = @"点击停止";
			break;

		default:
			break;
	}

	if (TTIsStringWithAnyText(imageName)) {
		[_btnRecord setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
	}
}

- (void)createFileName {
	RELEASE(fileName);
	fileName = [[NSString stringWithFormat:@"%.0f_%@", [[NSDate date] timeIntervalSince1970] * 1000, _userId] copy];
}

/**
	将当前语音保存到缓存
	@param url  语音url
 */
- (void)saveVoiceToCacheWithUrl:(NSString *)url {
    NSString *fName = [TJRImageAndDownFileBaseView getVoiceNameFormUrl:url voiceType:@"wav"];
    if (!TTIsStringWithAnyText(url) || ![self isHasAmrFile:fName]) return;
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self createFilePath:fName type:@""]];
    [TTCacheManager storeData:data forKey:[TJRImageAndDownFileBaseView getVoiceNameFormUrl:url]];
    RELEASE(data);
}

/**
	获取当前语音时长
	@returns
 */
- (NSInteger)recordTimeLength {
    return ceilf((CGFloat)recordLength/10);
}

/**
 *    生成路径
 *    @param fName 文件名
 *    @param type  文件类型
 *    @returns 路径
 */
- (NSString *)createFilePath:(NSString *)fName type:(NSString *)type {
    if (TTIsStringWithAnyText(type)) {
        return [CommonUtil TTPathForDocumentsResourceEtag:[NSString stringWithFormat:@"%@.%@", fName, type]];
    } else {
        return [CommonUtil TTPathForDocumentsResourceEtag:[NSString stringWithFormat:@"%@", fName]];
    }
}

#pragma mark - 开启记录录音时间的timer

/**
 *    开启记录录音时间的timer
 */
- (void)startRecordTimer {
	if (!recordTimer) {
		[self stopRecordTimer];
		recordTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(recordLengthCount) userInfo:nil repeats:YES];
	}
}

#pragma mark -停止记录录音时间的timer

/**
 *    停止记录录音时间的timer
 */
- (void)stopRecordTimer {
	if (recordTimer) {
		[recordTimer invalidate];
		recordTimer = Nil;
	}
}

#pragma mark - 录音时间记数

/**
 *     录音时间记数
 */
- (void)recordLengthCount {
	if (recorder.isRecording) {
		recordLength += timerInterval*10;
		[recorder updateMeters];/* 更新峰值 */
		[self updateMetersByAvgPower:[recorder averagePowerForChannel:0]];
		_progressView.progress = (CGFloat)(maxRecordTime - recordLength) / maxRecordTime;

		if (recordLength >= maxRecordTime) {	/* 时间到 */
			[self stopRecord];
		} else if (recordLength == maxRecordTime - 100) {	/* 剩下10秒 */
			[_ivBtnBg startAnimating];
		}
	}
}

#pragma mark - 设置声音波浪
- (void)updateMetersByAvgPower:(CGFloat)_avgPower {
	UIImage *grayImage = [UIImage imageNamed:@"TJRRecordView_bg_record_gray"];
	UIImage *lightBlueImage = [UIImage imageNamed:@"TJRRecordView_bg_record_lightblue"];
	UIImage *blueImage = [UIImage imageNamed:@"TJRRecordView_bg_record_blue"];

	if (_avgPower < -49) {
		_ivWaveL1.image = grayImage;
		_ivWaveR1.image = grayImage;
		_ivWaveL2.image = grayImage;
		_ivWaveR2.image = grayImage;
		_ivWaveL3.image = grayImage;
		_ivWaveR3.image = grayImage;
	} else if (_avgPower < -42) {
		_ivWaveL1.image = lightBlueImage;
		_ivWaveR1.image = lightBlueImage;
		_ivWaveL2.image = grayImage;
		_ivWaveR2.image = grayImage;
		_ivWaveL3.image = grayImage;
		_ivWaveR3.image = grayImage;
	} else if (_avgPower < -35) {
		_ivWaveL1.image = blueImage;
		_ivWaveR1.image = blueImage;
		_ivWaveL2.image = grayImage;
		_ivWaveR2.image = grayImage;
		_ivWaveL3.image = grayImage;
		_ivWaveR3.image = grayImage;
	} else if (_avgPower < -28) {
		_ivWaveL1.image = blueImage;
		_ivWaveR1.image = blueImage;
		_ivWaveL2.image = lightBlueImage;
		_ivWaveR2.image = lightBlueImage;
		_ivWaveL3.image = grayImage;
		_ivWaveR3.image = grayImage;
	} else if (_avgPower < -21) {
		_ivWaveL1.image = blueImage;
		_ivWaveR1.image = blueImage;
		_ivWaveL2.image = blueImage;
		_ivWaveR2.image = blueImage;
		_ivWaveL3.image = grayImage;
		_ivWaveR3.image = grayImage;
	} else if (_avgPower < -14) {
		_ivWaveL1.image = blueImage;
		_ivWaveR1.image = blueImage;
		_ivWaveL2.image = blueImage;
		_ivWaveR2.image = blueImage;
		_ivWaveL3.image = lightBlueImage;
		_ivWaveR3.image = lightBlueImage;
	} else {
		_ivWaveL1.image = blueImage;
		_ivWaveR1.image = blueImage;
		_ivWaveL2.image = blueImage;
		_ivWaveR2.image = blueImage;
		_ivWaveL3.image = blueImage;
		_ivWaveR3.image = blueImage;
	}
}

#pragma mark - 开始播放录音

/**
 *    开始播放录音
 */
- (void)startPlayRecord {
	recordType = RecordType_Play;
	[self setBtnRecordImageWithRecordType:recordType];
	NSString *path = [self createFilePath:fileName type:@"wav"];
	NSData *voiceData = [NSData dataWithContentsOfFile:path];
	[self setCategoryPlay];	/* 设置扬声器播放 */
	voicePlayer = [[AVAudioPlayer alloc] initWithData:voiceData error:nil];
	voicePlayer.delegate = self;
	voicePlayer.volume = 1;

	if ([voicePlayer prepareToPlay]) {
		[voicePlayer play];
		[self startPlayTimer];
	}
}

- (void)startPlayTimer {
	if (!playTimer) {
		[self stopRecordTimer];
		playLength = 0;
		playTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(playTimeCount) userInfo:nil repeats:YES];
	}
}

- (void)playTimeCount {
	playLength += timerInterval*10;

	CGFloat progress = (CGFloat)playLength / recordLength;
	_progressView.progress = progress;
}

- (void)stopPlayTimer {
	if (playTimer) {
		[playTimer invalidate];
		playTimer = Nil;
	}
}

#pragma mark - 停止播放录音

/**
 *    停止播放录音
 */
- (void)stopPlayRecord {
	[self stopPlayTimer];

	if (recordType != RecordType_StopPlay) {
		recordType = RecordType_StopPlay;
		[self setBtnRecordImageWithRecordType:recordType];

		if (voicePlayer && voicePlayer.isPlaying) {
			[voicePlayer stop];
			RELEASE(voicePlayer);
		}
	}
}

#pragma mark - 设置扬声器播放

/**
 *    设置扬声器播放
 */
- (void)setCategoryPlay {
    
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    //强制设置为扬声器播放
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
}

#pragma mark - 录音回调
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
	[self stopRecord];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
	[self stopRecord];
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags {
	[self stopRecord];
}

#pragma mark - 播放回调
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	[self stopPlayRecord];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
	[self stopPlayRecord];
}

#pragma mark - 是否存在录音文件

/**
 *    是否存在录音文件
 *    @returns Yes有录音文件,反之没有
 */
- (BOOL)isHasRecordFile {
    return [self isHasFile:[self createFilePath:fileName type:@"wav"]];
}

/**
 *    获得MP3文件名
 *    @returns (不存在Mp3文件时,就为空)
 */
- (NSString *)getMp3FileName {
    NSString *mp3Name = [NSString stringWithFormat:@"%@.mp3",fileName];
    if ([self isHasFile:[self createFilePath:mp3Name type:nil]]) {
        return mp3Name;
    } else{
        return nil;
    }
}

/**
 *    是否存在amr文件
 *    @returns Yes有amr文件,反之没有
 */
- (BOOL)isHasAmrFile:(NSString *)fName {
	if (!TTIsStringWithAnyText(fName)) return NO;

	return [self isHasFile:[self createFilePath:fName type:@""]];
}

/**
 *     文件是否存在
 *    @param path  路径
 *    @returns
 */
- (BOOL)isHasFile:(NSString *)path {
	if (!TTIsStringWithAnyText(path)) return NO;

	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

/**
 *    删除当前的语音文件
 */
- (void)deleteRecordFile {
    if (recordType == RecordType_Play) {
        [self stopPlayRecord];
    }
	[self deleteRecordFile:fileName type:@"wav"];
    [self deleteRecordFile:fileName type:@"mp3"];
    recordType = RecordType_Normal;
    [self setBtnRecordImageWithRecordType:recordType];
}

/**
 *    删除文件
 *    @param fName 文件名
 *    @param type  文件类型
 */
- (void)deleteRecordFile:(NSString *)fName type:(NSString *)type {
	if (!TTIsStringWithAnyText(fName) || !TTIsStringWithAnyText(type)) return;

	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL success = [fileManager removeItemAtPath:[self createFilePath:fName type:type] error:NULL];
	NSLog(@"删除  %@.%@ 文件%@,不用管这条打印信息",fName,type, success ? @"成功" : @"失败");
}

- (void)hideWavesImage:(BOOL)isHide {
	_ivWaveL1.hidden = isHide;
	_ivWaveL2.hidden = isHide;
	_ivWaveL3.hidden = isHide;
	_ivWaveR1.hidden = isHide;
	_ivWaveR2.hidden = isHide;
	_ivWaveR3.hidden = isHide;

	if (!isHide) [self updateMetersByAvgPower:-100];
}

- (void)dealloc {
    RELEASE(mp3Data);
	[self deleteRecordFile];
	[self stopRecord];
    [self stopPlayRecord];
	RELEASE(_userId);
	[_allView release];
	[_ivBtnBg release];
	[_progressView release];
	[_btnRecord release];
	[_ivWaveL1 release];
	[_ivWaveL2 release];
	[_ivWaveL3 release];
	[_ivWaveR1 release];
	[_ivWaveR2 release];
	[_ivWaveR3 release];
	[_lbShowText release];
	[_btnReRecord release];
	[_lbShowTime release];
	[super dealloc];
}

@end

