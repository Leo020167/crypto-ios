//
//  TJRVoicePlayView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-6-6.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

// ////////////////////////////////////////////////////
//                      _ooOoo_                      //
//                     o8888888o                     //
//                     88" . "88                     //
//                     (| -_- |)                     //
//                     O\  =  /O                     //
//                  ____/`---'\____                  //
//                .'  \\|     |//  `.                //
//               /  \\|||  :  |||//  \               //
//              /  _||||| -:- |||||-  \              //
//              |   | \\\  -  /// |   |              //
//              | \_|  ''\---/''  |   |              //
//              \  .-\__  `-`  ___/-. /              //
//            ___`. .'  /--.--\  `. . __             //
//         ."" '<  `.___\_<|>_/___.'  >'"".          //
//        | | :  `- \`.;`\ _ /`;.`/ - ` : | |        //
//        \  \ `-.   \_ __\ /__ _/   .-` /  /        //
//   ======`-.____`-.___\_____/___.-`____.-'======   //
//                      `=---='                      //
//  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^    //
//               佛祖保佑       永无BUG                //
//                                                   //
// ////////////////////////////////////////////////////

#import "TJRVoicePlayView.h"
#import "TJRImageAndDownFileBaseView.h"
#import "CommonUtil.h"
#import "TTCacheManager.h"

NSString *const TJRVoicePlayViewPlayKey = @"TJRVoicePlayViewPlayKey";
NSString *const TJRVoicePlayViewOverKey = @"TJRVoicePlayViewOverKey";
NSString *const TJRVoicePlayViewKey = @"TJRVoicePlayViewKey";


NSString *const TJRStockTalkPlayVCNotification = @"TJRStockTalkPlayVCNotification";

extern NSString *const TJRVoicePlayViewMemoryAddressKey;
NSString *const TJRVoicePlayViewMemoryAddressKey = @"TJRVoicePlayViewMemoryAddressKey";


NSString *const TJRVoicePlayViewVoiceUrlKey = @"TJRVoicePlayViewVoiceUrlKey";

static NSMutableArray *slideShowArray;	/* 连播数组 */

@interface TJRVoicePlayViewSomeData : NSObject
@property (assign, nonatomic) NSInteger downloadType;	/* 0表示还没下载,1表示在下载,但还没完成,2表示完成,3表示失败 */
@property (assign, nonatomic) BOOL afterDownToPlay;	/* 是否是下载完成后自动播放 */
@property (copy, nonatomic) NSString *voiceUrl;	/* 语音文件的url */
@property (assign, nonatomic) BOOL isSlideShow;	/* 是否需要连续播放 */
@property (assign, nonatomic) NSInteger slidShowIndex;	/* 连播序号,不一定要号码连续,但只能从小到大 */
@end

@implementation TJRVoicePlayViewSomeData

- (void)dealloc {
	RELEASE(_voiceUrl);
	[super dealloc];
}

@end

@implementation TJRVoicePlayView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		[self initTJRVoicePlayView];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

	if (self) {
		[self initTJRVoicePlayView];
	}
	return self;
}

- (void)initTJRVoicePlayView {
	[[NSBundle mainBundle] loadNibNamed:@"TJRVoicePlayView" owner:self options:nil];
	CGRect frame = self.allView.frame;
	frame.size = self.frame.size;
	self.allView.frame = frame;
	[self addSubview:self.allView];
	self.backgroundColor = [UIColor clearColor];
	self.allView.backgroundColor = [UIColor clearColor];
	self.ivDownVoice.delegate = self;
	_voiceMaxLength = 50;
	_voiceMinLength = 1;
	[self addOrRemoveObserver:YES];
	self.playWaveImages = [NSArray arrayWithObjects:
		[UIImage imageNamed:@"talkietalkie_voice_play_wave_0"],
		[UIImage imageNamed:@"talkietalkie_voice_play_wave_1"],
		[UIImage imageNamed:@"talkietalkie_voice_play_wave_2"],
		[UIImage imageNamed:@"talkietalkie_voice_play_wave_3"], nil];
	someDataDic = [[NSMutableDictionary alloc] init];

	/* static dispatch_once_t onceToken;
	 *   dispatch_once(&onceToken, ^{
	 *        slideShowArray = [NSMutableArray new];
	 *        NSLog (@"创建连播记录数组");
	 *    }); */
}

#pragma mark - 设置背景图片的拉伸参数

/**
 *    设置背景图片的拉伸参数
 *    @param capInsets
 */
- (void)setCapInsets:(UIEdgeInsets)capInsets {
	_capInsets = capInsets;
	_viewMinWidth = 60 + capInsets.left;
}

#pragma mark - 设置圆角颜色和半径

/**
 *    设置圆角颜色和半径
 *    @param borderColor 圆角颜色
 *    @param cornerRadius  圆角半径
 *   @param borderWidth  圆角线宽
 */
- (void)setBorderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth {
	self.layer.borderColor = [borderColor CGColor];
	self.layer.borderWidth = borderWidth;
	self.layer.cornerRadius = cornerRadius;
	self.layer.masksToBounds = YES;
}

#pragma mark - 设置语音控件的高度

/**
 *    设置语音控件的高度
 *    @param viewHeight
 */
- (void)setViewHeight:(CGFloat)viewHeight {
	_viewHeight = viewHeight;
	CGRect frame = self.frame;
	frame.size.height = viewHeight;
	self.frame = frame;
	frame = self.allView.frame;
	frame.size = self.frame.size;
	self.allView.frame = frame;

	frame = _lbTimeLength.frame;
	frame.size.height = viewHeight;
	_lbTimeLength.frame = frame;
}

#pragma mark - 设置播放时,声波的动画图片

/**
 *    设置播放时,声波的动画图片
 *    @param playWaveImages  图片数组中的第一张为默认背景
 */
- (void)setPlayWaveImages:(NSArray *)playWaveImages {
	RELEASE(_playWaveImages);
	_playWaveImages = [playWaveImages retain];

	if (_playWaveImages) {
		_ivWave.image = [_playWaveImages firstObject];

		if (_playWaveImages.count >= 2) {
			_ivWave.animationImages = _playWaveImages;
			_ivWave.animationDuration = _playWaveImages.count / 2.0f;
			_ivWave.animationRepeatCount = 0;
		}
	} else {
		_ivWave.image = nil;
	}
}

#pragma mark - 添加或移除播放监听

/**
 *    添加或移除播放监听
 *    @param isAdd  YES是添加,NO是移除
 */
- (void)addOrRemoveObserver:(BOOL)isAdd {
	if (isAdd) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceViewNotification:) name:TJRVoicePlayViewPlayKey object:nil];
	} else {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
	}
}

#pragma mark - 通知处理

/**
 *    通知处理
 *    @param notification
 */
- (void)voiceViewNotification:(NSNotification *)notification {
	NSDictionary *userInfo = notification.userInfo;
	NSString *url = [userInfo objectForKey:TJRVoicePlayViewVoiceUrlKey];

	for (TJRVoicePlayViewSomeData *data in someDataDic.allValues) {
		if (data && TTIsStringWithAnyText(data.voiceUrl) && ![data.voiceUrl isEqualToString:url]) {
			/* 当点击一个语音时,要把其他所有的语音准备下载完成后播放的,全部设置为下载完成后不播放 */
			data.afterDownToPlay = NO;
		}
	}

	[self stopVoice];
}

#pragma mark - 设置播放时,背景的图片变化

/**
 *    设置播放时,背景的图片变化
 *    @param playBgImages 第一张是默认时的背景
 */
- (void)setPlayBgImages:(NSArray *)playBgImages {
	RELEASE(_playBgImages);
	_playBgImages = [playBgImages retain];

	if (_playBgImages) {
		id value = [_playBgImages firstObject];

		if ([value isKindOfClass:[UIImage class]]) {
			self.backgroundImage = (UIImage *)value;
			_ivDownVoice.image = _backgroundImage;
		} else if ([value isKindOfClass:[UIColor class]]) {
			self.backgroundImage = [CommonUtil createImageWithColor:(UIColor *)value withViewForSize:_ivDownVoice];
			_ivDownVoice.image = _backgroundImage;
		}
		NSMutableArray *array = [NSMutableArray array];

		for (id value in _playBgImages) {
			if ([value isKindOfClass:[UIImage class]]) {
				[array addObject:[CommonUtil stretchableImageWithImage:(UIImage *)value edgeInsets:_capInsets]];
			} else if ([value isKindOfClass:[UIColor class]]) {
				[array addObject:[CommonUtil createImageWithColor:(UIColor *)value withViewForSize:_ivDownVoice]];
			}
		}

		_ivDownVoice.animationImages = array;
		_ivDownVoice.animationDuration = 1.0f;
		_ivDownVoice.animationRepeatCount = 0;
	}
}

#pragma mark - 设置语音控件的一些播放参数

/**
 *    设置语音控件的一些播放参数
 *    @param url
 *    @returns
 */
- (TJRVoicePlayViewSomeData *)getTJRVoicePlayViewSomeDataWithUrl:(NSString *)url {
	if (!TTIsStringWithAnyText(url)) {
		return [[TJRVoicePlayViewSomeData new] autorelease];
	}
	TJRVoicePlayViewSomeData *data = [someDataDic objectForKey:url];

	if (!data) {
		data = [TJRVoicePlayViewSomeData new];
		data.voiceUrl = url;
		[someDataDic setObject:data forKey:url];
		RELEASE(data);
		data = [someDataDic objectForKey:url];
	}
	return data;
}

#pragma mark - 设置语音文件的路径

/**
 *    设置语音文件的路径(不会下载,要点击播放时才会下载)
 *    @param url 语音文件的路径
 *    @param voiceLength  语音时长
 */
- (void)setVoiceFileUrl:(NSString *)url voiceLength:(NSString *)voiceLength{
	[_activityView stopAnimating];
	_activityView.hidden = YES;
	_ivWave.hidden = NO;
	_lbTimeLength.hidden = NO;
	_ivFalidIcon.hidden = YES;
	RELEASE(pastVoiceUrl);
	pastVoiceUrl = [voiceUrl copy];
	RELEASE(voiceUrl);
	voiceUrl = [url copy];
	_lbTimeLength.text = [NSString stringWithFormat:@"%@\"", voiceLength];
	[self startPlayBgAnimation:url];
	[self calculateViewWidthWithVoiceLength:[voiceLength integerValue]];
}

- (void)setVoiceFileUrl:(NSString *)url voiceLength:(NSString *)voiceLength isAutoresize:(BOOL)autoresize
{
    [_activityView stopAnimating];
    _activityView.hidden = YES;
    _ivWave.hidden = NO;
    _lbTimeLength.hidden = NO;
    _ivFalidIcon.hidden = YES;
    RELEASE(pastVoiceUrl);
    pastVoiceUrl = [voiceUrl copy];
    RELEASE(voiceUrl);
    voiceUrl = [url copy];
    _lbTimeLength.text = [NSString stringWithFormat:@"%@\"", voiceLength];
    [self startPlayBgAnimation:url];
    if(autoresize){
        [self calculateViewWidthWithVoiceLength:[voiceLength integerValue]];
    }
}

/**
 *    开始播放时的背景动画
 *    @param url
 */
- (void)startPlayBgAnimation:(NSString *)url {
	if (isPlaying && [url isEqualToString:playVoiceUrl]) {
		if (_ivWave.animationImages) [_ivWave startAnimating];

		if (_ivDownVoice.animationImages) [_ivDownVoice startAnimating];
	} else {
		[self stopPlayBgAnimation];
	}
}

/**
 *    停止播放时的背景动画
 */
- (void)stopPlayBgAnimation {
	[_ivWave stopAnimating];
	[_ivDownVoice stopAnimating];
}

#pragma mark - 下载语音文件

/**
 *    下载语音文件,并设置为连播状态
 *    @param url
 *    @param slidShowIndex 连播序号,序号不一定要连续,但只能从小到大
 *    @param voiceLength
 */
- (void)downloadVoiceFileWithUrl:(NSString *)url slidShowIndex:(NSInteger)slidShowIndex voiceLength:(NSString *)voiceLength {
	TJRVoicePlayViewSomeData *data = [slideShowArray lastObject];

	if (!data || (data.slidShowIndex < slidShowIndex)) {
		data.isSlideShow = YES;
		data.slidShowIndex = slidShowIndex;
	}
	[self downloadVoiceFileWithUrl:url voiceLength:voiceUrl];
}

/**
 *   下载语音文件
 *   @param url 语音文件的URL
 *   @param voiceLength 语音时长
 */
- (void)downloadVoiceFileWithUrl:(NSString *)url voiceLength:(NSString *)voiceLength {
	[self setVoiceFileUrl:url voiceLength:voiceLength];
	[self downloadVoiceFile:voiceUrl];
}

- (void)downloadVoiceFileWithUrl:(NSString *)url voiceLength:(NSString *)voiceLength autoPlay:(BOOL)autoPlay{
    [self setVoiceFileUrl:url voiceLength:voiceLength];
    [self downloadVoiceFile:voiceUrl];
    [self getTJRVoicePlayViewSomeDataWithUrl:url].afterDownToPlay = autoPlay;
}

/**
 *    下载语音文件
 *    @param url 语音文件的URL
 *    @param isCheckCache  是否检测本地是否存在下载文件和转换后的文件
 */
- (void)downloadVoiceFile:(NSString *)url {
	if (isPlaying && [url isEqualToString:playVoiceUrl]) {
		if (_ivDownVoice.animationImages) [_ivDownVoice startAnimating];
	} else {
		[_ivDownVoice stopAnimating];
	}
	_ivWave.hidden = YES;
	_ivFalidIcon.hidden = YES;
	_lbTimeLength.hidden = YES;
	RELEASE(pastVoiceUrl);
	pastVoiceUrl = [voiceUrl copy];
	RELEASE(voiceUrl);
	voiceUrl = [url copy];
	[self getTJRVoicePlayViewSomeDataWithUrl:url].downloadType = 1;
	_activityView.hidden = NO;
	[_activityView startAnimating];
	[_ivDownVoice downloadMp3VoiceFile:url];
}

#pragma mark - 计算并设置语音控件的长度

/**
 *    计算并设置语音控件的长度
 *    @param voiceLength  语音长度
 */
- (void)calculateViewWidthWithVoiceLength:(NSInteger)voiceLength {
	if ((_viewMaxWidth == 0) || (_voiceMaxLength == 0) || (voiceLength < _voiceMinLength)) return;

	CGFloat width = (CGFloat)voiceLength / _voiceMaxLength * _viewMaxWidth;
	width = MAX(width, _viewMinWidth);

	if (voiceLength < 10) width -= 5;
    if (self.translatesAutoresizingMaskIntoConstraints) {
        CGRect frame = self.frame;
        
        if (_direction) {
            frame.origin.x = frame.origin.x + frame.size.width - width;
        }
        frame.size.width = width;
        self.frame = frame;
    } else {
        for (NSLayoutConstraint *c in self.constraints) {
            if ((c.firstItem == self || c.secondItem == self) &&
                (c.firstAttribute == NSLayoutAttributeWidth ||c.secondAttribute  == NSLayoutAttributeWidth)) {
                c.constant = width;
                break;
            }
        }
    }
    
	

	CGRect frame = self.allView.frame;

	if (_direction) {
		frame.origin.x = frame.origin.x + frame.size.width - width;
	}
	frame.size = self.frame.size;
	self.allView.frame = frame;

	if (_backgroundImage) {
		_ivDownVoice.image = [CommonUtil stretchableImageWithImage:_backgroundImage edgeInsets:_capInsets];
	}
	frame = _ivDownVoice.frame;
	frame.size.width = self.frame.size.width;

	_ivDownVoice.frame = frame;
	frame = _ivWave.frame;
	frame.origin.x = _capInsets.left + 5;
	_ivWave.frame = frame;

	frame = _lbTimeLength.frame;
	frame.origin.x = self.frame.size.width - frame.size.width;
	frame.origin.x -= 6;

	_lbTimeLength.frame = frame;
}

#pragma mark - 下载成功回调

/**
 *    下载成功回调
 *    @param file 下载数据
 *    @param url  下载的url
 */
- (void)TJRDownloadFileFinish:(id)file url:(NSString *)url {
	[_activityView stopAnimating];
	_activityView.hidden = YES;
	[self getTJRVoicePlayViewSomeDataWithUrl:url].downloadType = 2;
	_ivWave.hidden = NO;
	_lbTimeLength.hidden = NO;

	if ([self getTJRVoicePlayViewSomeDataWithUrl:url].afterDownToPlay) {
		[self postNotification:url];
		[self playVoice:url];
	}
}

#pragma mark - 下载失败回调

/**
 *    下载失败回调
 *    @param error
 *    @param url
 */
- (void)TJRDownloadFileFail:(NSError *)error url:(NSString *)url {
	[_activityView stopAnimating];
	_activityView.hidden = YES;
	[self getTJRVoicePlayViewSomeDataWithUrl:url].downloadType = 3;
	_ivFalidIcon.hidden = NO;
}

#pragma mark - 播放按钮
- (IBAction)playAction:(UIButton *)sender {
	NSInteger type = [self getTJRVoicePlayViewSomeDataWithUrl:voiceUrl].downloadType;

	if (type == 2) {
		if (isPlaying) {
			[self stopVoice];

			if (voiceUrl && pastVoiceUrl && ![voiceUrl isEqualToString:pastVoiceUrl]) {	/* 如果列表中上一个正在播放时,再点击下一条 */
				[self postNotification:voiceUrl];
				[self playVoice:voiceUrl];
			}
		} else {
			[self postNotification:voiceUrl];
			[self playVoice:voiceUrl];
		}
	} else if ((type == 0) || (type == 3)) {
		[self getTJRVoicePlayViewSomeDataWithUrl:voiceUrl].afterDownToPlay = YES;
		[self downloadVoiceFile:voiceUrl];
	}
}

#pragma mark - 播放声音

/**
 *   播放声音
 */
- (void)playVoice:(NSString *)url {
	NSAssert(TTIsStringWithAnyText(url) == YES, @"语音文件url为空");
	RELEASE(playVoiceUrl);
	playVoiceUrl = [url copy];
	NSData *voiceData = [TTCacheManager dataForURL:url];

	if (!voiceData) {
		NSLog(@"语音文件为空");
		return;
	}
	[self setCategoryPlay];	/* 设置扬声器播放 */
	voicePlayer = [[AVAudioPlayer alloc] initWithData:voiceData error:nil];
	voicePlayer.delegate = self;
	voicePlayer.volume = 1;//0.0~1.0之间
    
    //发起通知，通知Stocktalk play view要关闭当前播放的节目语音
    [[NSNotificationCenter defaultCenter] postNotificationName:TJRStockTalkPlayVCNotification object:nil];

	if ([voicePlayer prepareToPlay]) {
		[voicePlayer play];
		isPlaying = YES;
		[self startPlayBgAnimation:voiceUrl];
	}
}

#pragma mark - 停止播放声音

/**
 *    停止播放声音
 */
- (void)stopVoice {
	isPlaying = NO;
	[self stopPlayBgAnimation];

	if (voicePlayer && voicePlayer.isPlaying) {
		[voicePlayer stop];
		RELEASE(voicePlayer);
	}
	[self getTJRVoicePlayViewSomeDataWithUrl:voiceUrl].afterDownToPlay = NO;
}

/**
 *    停止播放声音
 *    @param isClean  是否清除所有的连播记录
 */
- (void)stopVoiceWithCleanSlidShowArray:(BOOL)isClean {
	/* isPlaying = NO;
	 *   [self stopPlayBgAnimation];
	 *
	 *   if (voicePlayer && voicePlayer.isPlaying) {
	 *    [voicePlayer stop];
	 *    RELEASE(voicePlayer);
	 *   }
	 *   [self getTJRVoicePlayViewSomeDataWithUrl:voiceUrl].afterDownToPlay = NO;
	 *   if (isClean) {
	 *    for (TJRVoicePlayViewSomeData *dd in slideShowArray) {
	 *        dd.isSlideShow = NO;
	 *    }
	 *   } */
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

#pragma mark - 播放回调
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	[self stopVoice];
    if (flag) {
        //发起通知，播放完成通知
        [[NSNotificationCenter defaultCenter] postNotificationName:TJRVoicePlayViewOverKey object:nil  userInfo:
         [NSDictionary dictionaryWithObjectsAndKeys: self, TJRVoicePlayViewKey,
          voiceUrl, TJRVoicePlayViewVoiceUrlKey,
          nil]];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
	[self stopVoice];
}

#pragma mark - 获取当前语音控件的内存地址

/**
 *    获取当前语音控件的内存地址
 *    @returns
 */
- (NSString *)getSelfMemoryAddress {
	return [NSString stringWithFormat:@"%p", self];
}

#pragma mark - post通知

/**
 *    post通知
 *    @param url  语音文件的url
 */
- (void)postNotification:(NSString *)url {
	[[NSNotificationCenter defaultCenter] postNotificationName:TJRVoicePlayViewPlayKey
														object:nil
													  userInfo:
		[NSDictionary dictionaryWithObjectsAndKeys:
			[self getSelfMemoryAddress], TJRVoicePlayViewMemoryAddressKey,
			url, TJRVoicePlayViewVoiceUrlKey,
			nil]];
}

/**
 *    设置整个控件的方向,默认是从左向右的
 *    @param isRightToLeft
 */
- (void)setDirection:(BOOL)direction {
	if (_direction == direction) return;

	_direction = direction;
	CGAffineTransform at = CGAffineTransformMakeRotation(M_PI);
	at = CGAffineTransformTranslate(at, 0, 0);
	[self setTransform:at];
	[_lbTimeLength setTransform:at];
	[_lbTimeLength setTextAlignment:direction ? NSTextAlignmentLeft:NSTextAlignmentRight];
}

#pragma mark - 设置语音控件的显示风格
- (void)setVoiceViewShowType:(TJRVoicePlayViewShowType)type {
	switch (type) {
		case TJRVoicePlayViewShowType_Blue :
			{
				self.capInsets = UIEdgeInsetsMake(0, 0, 64, 15);
				self.playBgImages = [NSArray arrayWithObjects:
				RGBA(255, 255, 255, 1),
				RGBA(140, 221, 255, 1),
				RGBA(140, 221, 255, 0.9),
				RGBA(140, 221, 255, 0.8),
				RGBA(140, 221, 255, 0.7),
				RGBA(140, 221, 255, 0.6),
				RGBA(140, 221, 255, 0.5),
				RGBA(140, 221, 255, 0.4),
				RGBA(140, 221, 255, 0.3),
				RGBA(140, 221, 255, 0.2),
				RGBA(140, 221, 255, 0.1),
				nil];
				[self setBorderColor:RGBA(140, 221, 255, 1) cornerRadius:5.5 borderWidth:0.5f];
				break;
			}

		case TJRVoicePlayViewShowType_Yellow:
			{
				self.capInsets = UIEdgeInsetsMake(0, 0, 64, 15);
				self.playBgImages = [NSArray arrayWithObjects:
				RGBA(255, 255, 255, 1),
				RGBA(214.0, 195.0, 151.0, 1),
				RGBA(214.0, 195.0, 151.0, 0.9),
				RGBA(214.0, 195.0, 151.0, 0.8),
				RGBA(214.0, 195.0, 151.0, 0.7),
				RGBA(214.0, 195.0, 151.0, 0.6),
				RGBA(214.0, 195.0, 151.0, 0.5),
				RGBA(214.0, 195.0, 151.0, 0.4),
				RGBA(214.0, 195.0, 151.0, 0.3),
				RGBA(214.0, 195.0, 151.0, 0.2),
				RGBA(214.0, 195.0, 151.0, 0.1),
				nil];
				[self setBorderColor:RGBA(214.0, 195.0, 151.0, 1) cornerRadius:5.5 borderWidth:0.5f];
				break;
			}

		case TJRVoicePlayViewShowType_Image_Blue:
			{
				self.backgroundImage = [UIImage imageNamed:@"voice_play_wave_blue_bg"];
				self.playWaveImages = [NSArray arrayWithObjects:
				[UIImage imageNamed:@"voice_play_wave_blue_0"],
				[UIImage imageNamed:@"voice_play_wave_blue_1"],
				[UIImage imageNamed:@"voice_play_wave_blue_2"],
				[UIImage imageNamed:@"voice_play_wave_blue_3"], nil];
				self.capInsets = UIEdgeInsetsMake(0, 10, 34, 13);
				self.lbTimeLength.textColor = RGBA(88.0, 200.0, 237.0, 1.0);
				CGRect frame = self.ivWave.frame;
				frame.size.width += 8;
				self.ivWave.frame = frame;
				break;
			}

		case TJRVoicePlayViewShowType_Image_Yellow:
			{
				self.backgroundImage = [UIImage imageNamed:@"voice_play_wave_yellow_bg"];
				self.playWaveImages = [NSArray arrayWithObjects:
				[UIImage imageNamed:@"voice_play_wave_yellow_0"],
				[UIImage imageNamed:@"voice_play_wave_yellow_1"],
				[UIImage imageNamed:@"voice_play_wave_yellow_2"],
				[UIImage imageNamed:@"voice_play_wave_yellow_3"], nil];
				self.capInsets = UIEdgeInsetsMake(0, 10, 34, 13);
				self.lbTimeLength.textColor = RGBA(214.0, 195.0, 151.0, 1.0);
				CGRect frame = self.ivWave.frame;
				frame.size.width += 8;
				self.ivWave.frame = frame;
				break;
			}

		case TJRVoicePlayViewShowType_Image_Pink:
			{
				self.backgroundImage = [UIImage imageNamed:@"voice_play_wave_pink_bg"];
				self.playWaveImages = [NSArray arrayWithObjects:
				[UIImage imageNamed:@"voice_play_wave_pink_0"],
				[UIImage imageNamed:@"voice_play_wave_pink_1"],
				[UIImage imageNamed:@"voice_play_wave_pink_2"],
				[UIImage imageNamed:@"voice_play_wave_pink_3"], nil];
				self.capInsets = UIEdgeInsetsMake(0, 10, 34, 13);
				self.lbTimeLength.textColor = RGBA(255.0, 120.0, 120.0, 1.0);
				CGRect frame = self.ivWave.frame;
				frame.size.width += 8;
				self.ivWave.frame = frame;
				break;
			}

		case TJRVoicePlayViewShowType_Image_Gray:
			{
				self.backgroundImage = [UIImage imageNamed:@"voice_play_wave_gray_bg"];
				self.playWaveImages = [NSArray arrayWithObjects:
				[UIImage imageNamed:@"voice_play_wave_gray_0"],
				[UIImage imageNamed:@"voice_play_wave_gray_1"],
				[UIImage imageNamed:@"voice_play_wave_gray_2"],
				[UIImage imageNamed:@"voice_play_wave_gray_3"], nil];
				self.capInsets = UIEdgeInsetsMake(0, 12, 40, 13);
				self.lbTimeLength.textColor = RGBA(112.0, 254.0, 242.0, 1.0);
				CGRect frame = self.ivWave.frame;
				frame.size.width += 8;
				self.ivWave.frame = frame;
				break;
			}
        case TJRVoicePlayViewShowType_Image_Circle:
        {
            if (_direction){
                CGAffineTransform at = CGAffineTransformMakeRotation(M_PI);
                at = CGAffineTransformTranslate(at, 0, 0);
                [_ivDownVoice setTransform:at];
                [self.ivWave setTransform:at];
                self.backgroundImage = [UIImage imageNamed:@"circleChat_bubble_bg_right"];
                self.playWaveImages = [NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"voice_play_wave_circle_right_0"],
                                       [UIImage imageNamed:@"voice_play_wave_circle_right_1"],
                                       [UIImage imageNamed:@"voice_play_wave_circle_right_2"],
                                       [UIImage imageNamed:@"voice_play_wave_circle_right_3"], nil];
            }else{
               self.backgroundImage = [UIImage imageNamed:@"circleChat_bubble_bg_left"];
               self.playWaveImages =  [NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"voice_play_wave_circle_0"],
                                       [UIImage imageNamed:@"voice_play_wave_circle_1"],
                                       [UIImage imageNamed:@"voice_play_wave_circle_2"],
                                       [UIImage imageNamed:@"voice_play_wave_circle_3"], nil];
            }
            
            self.capInsets = UIEdgeInsetsMake(10, 15, 12, 15);
            self.lbTimeLength.textColor = RGBA(112.0, 254.0, 242.0, 1.0);
            CGRect frame = self.ivWave.frame;
            frame.size.width += 8;
            self.ivWave.frame = frame;
            break;
        }
		default:
			break;
	}
}

- (void)dealloc {
    [self addOrRemoveObserver:NO];
    [self stopVoice];
	[someDataDic removeAllObjects];
	RELEASE(someDataDic);
	RELEASE(pastVoiceUrl);
	RELEASE(playVoiceUrl);
	RELEASE(_playBgImages);
	RELEASE(_playWaveImages);
	RELEASE(voiceUrl);
	RELEASE(_backgroundImage);
	[_ivDownVoice release];
	[_activityView release];
	[_btnPlay release];
	[_allView release];
	[_ivWave release];
	[_ivFalidIcon release];
	[_lbTimeLength release];
	[super dealloc];
}

@end

