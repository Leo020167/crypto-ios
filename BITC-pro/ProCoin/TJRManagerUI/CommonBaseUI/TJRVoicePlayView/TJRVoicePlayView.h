//
//  TJRVoicePlayView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 14-6-6.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioToolbox/AudioToolbox.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "TJRImageAndDownFileBaseView.h"

typedef enum TJRVoicePlayViewShowType {
	/* 显示风格,纯色 */
	TJRVoicePlayViewShowType_Blue,
	TJRVoicePlayViewShowType_Yellow,

	/* 显示风格,图片 */
	TJRVoicePlayViewShowType_Image_Blue,
	TJRVoicePlayViewShowType_Image_Yellow,
	TJRVoicePlayViewShowType_Image_Pink,
	TJRVoicePlayViewShowType_Image_Gray,
    TJRVoicePlayViewShowType_Image_Circle
} TJRVoicePlayViewShowType;

extern NSString *const TJRVoicePlayViewPlayKey;
extern NSString *const TJRStockTalkPlayVCNotification;
extern NSString *const TJRVoicePlayViewVoiceUrlKey;
extern NSString *const TJRVoicePlayViewOverKey;
extern NSString *const TJRVoicePlayViewKey;

@interface TJRVoicePlayView : UIView <AVAudioPlayerDelegate, TJRImageAndDownFileBaseViewDelegate>{
	AVAudioPlayer *voicePlayer;
	NSString *voiceUrl;
	NSString *pastVoiceUrl;
	NSString *playVoiceUrl;
	/* NSInteger voiceLength; */
	BOOL isPlaying;
	NSInteger bgAnimaType;	/* 0表示停止播放,1表示开始播放,2表示不做任务操作 */
	NSMutableDictionary *someDataDic;
}

@property (retain, nonatomic) IBOutlet UIView *allView;
@property (retain, nonatomic) IBOutlet TJRImageAndDownFileBaseView *ivDownVoice;/* 背景 */
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityView;	/* 等待菊花 */
@property (retain, nonatomic) IBOutlet UIButton *btnPlay;	/* 播放按钮 */
@property (retain, nonatomic) IBOutlet UIImageView *ivWave;	/* 播放时的,声波图片 */
@property (retain, nonatomic) IBOutlet UIImageView *ivFalidIcon;/* 下载失败时的Icon,暂时没用 */
@property (retain, nonatomic) IBOutlet UILabel *lbTimeLength;	/* 显示语音时长 */

@property (retain, nonatomic) UIImage *backgroundImage;	/* 如果没有播放时的背景动画,就单独设置这个背景图片 */
@property (assign, nonatomic) CGFloat viewHeight;	/* 语音控件的高度 */
@property (assign, nonatomic) CGFloat viewMinWidth;	/* 如果要设置这个值,请在设置capInsets这个参数后,因为设置capInsets时会自动设置viewMinWidth */
@property (assign, nonatomic) CGFloat viewMaxWidth;	/* 语音控件的最大宽度 */
@property (assign, nonatomic) NSInteger voiceMinLength;	/* 默认为1 */
@property (assign, nonatomic) NSInteger voiceMaxLength;	/* 默认为60 */
@property (assign, nonatomic) UIEdgeInsets capInsets;	/* 背景图片的拉伸参数 */
@property (retain, nonatomic) NSArray *playWaveImages;	/* 播放时的声波图片数组,第一张为初始显示图片 */
@property (retain, nonatomic) NSArray *playBgImages;/* 播放时,背景的图片变化,第一张是默认时的背景 */
@property (assign, nonatomic) BOOL direction;	/* 方向,默认是NO(从左向右的),YES(从右向左的) */

/**
 *   设置圆角颜色和半径
 *   @param borderColor 圆角颜色
 *   @param cornerRadius  圆角半径
 *   @param borderWidth  圆角线宽
 */
- (void)setBorderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth;

/**
 *   设置语音文件的路径(不会下载,要点击播放时才会下载)
 *   @param url 语音文件的路径
 *   @param voiceLength  语音时长
 */
- (void)setVoiceFileUrl:(NSString *)url voiceLength:(NSString *)voiceLength;
- (void)setVoiceFileUrl:(NSString *)url voiceLength:(NSString *)voiceLength isAutoresize:(BOOL)autoresize;

/**
 *   下载语音文件,并设置为连播状态
 *   @param url
 *   @param slidShowIndex 连播序号,序号不一定要连续,但只能从小到大
 *   @param voiceLength
 */
- (void)downloadVoiceFileWithUrl:(NSString *)url slidShowIndex:(NSInteger)slidShowIndex voiceLength:(NSString *)voiceLength;

/**
 *    下载语音文件
 *    @param url 语音文件的URL
 *    @param voiceLength 语音时长
 */
- (void)downloadVoiceFileWithUrl:(NSString *)url voiceLength:(NSString *)voiceLength;
- (void)downloadVoiceFileWithUrl:(NSString *)url voiceLength:(NSString *)voiceLength autoPlay:(BOOL)autoPlay;

/**
 *    播放声音
 */
- (void)playVoice:(NSString *)url;
- (IBAction)playAction:(UIButton *)sender;
/**
 *    停止播放声音
 */
- (void)stopVoice;

#pragma mark - 设置语音控件的显示风格
- (void)setVoiceViewShowType:(TJRVoicePlayViewShowType)type;
@end

