//
//  RZSmallVideoPlayController.m
//  MyWorkProject
//
//  Created by Hay on 2018/9/11.
//  Copyright © 2018年 Hay. All rights reserved.
//

#import "RZSmallVideoPlayController.h"
#import <AVFoundation/AVFoundation.h>
#import "RZWebImageView.h"
#import "CommonUtil.h"

@interface RZSmallVideoPlayController ()
{
    BOOL isPlay;                        //是否播放状态
    BOOL isTapGestureFinished;          //tap手势操作是否完成
    BOOL isShowView;                    //是否正在显示opeview和navigationview
}

@property (retain, nonatomic) RZWebImageView *coverImageView;   //加载视频时显示的封面
@property (retain, nonatomic) AVPlayer *videoPlayer;            //视频播放控制器
@property (retain, nonatomic) AVPlayerLayer *playerLayer;       //视频画面
@property (retain, nonatomic) AVPlayerItem *playerItem;         //视频元素
@property (retain, nonatomic) id timeObser;                     //video player的播放时间观察器

@property (retain, nonatomic) UIView *navigationView;       //顶部导航栏view
@property (retain, nonatomic) UIView *opeView;              //视频进度条操作view
@property (retain, nonatomic) UILabel *leftTimeLabel;       //左边时间文本
@property (retain, nonatomic) UILabel *rightTimeLabel;      //右边时间文本
@property (retain, nonatomic) UISlider *progressSlider;     //时间轴
@property (retain, nonatomic) UIButton *playPauseButton;    //播放暂停按钮
@property (retain, nonatomic) UIButton *closeButton;        //关闭按钮
@property (retain, nonatomic) UILabel *tipsLabel;           //提示文本

@end

@implementation RZSmallVideoPlayController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    isPlay = YES;
    isTapGestureFinished = YES;
    
    [self.view addSubview:self.coverImageView];
    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.opeView];
    
    [self.navigationView addSubview:self.closeButton];
    [self.opeView addSubview:self.playPauseButton];
    [self.opeView addSubview:self.leftTimeLabel];
    [self.opeView addSubview:self.progressSlider];
    [self.opeView addSubview:self.rightTimeLabel];
    
    [self.closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.playPauseButton addTarget:self action:@selector(playPauseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.progressSlider addTarget:self action:@selector(progressSliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.progressSlider addTarget:self action:@selector(progressSliderWillTouch:) forControlEvents:UIControlEventTouchDown];
    [self.progressSlider addTarget:self action:@selector(progresSliderOperationDidEnd:) forControlEvents:UIControlEventTouchCancel | UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    self.tipsLabel.hidden = YES;
    [self.view addSubview:self.tipsLabel];
    
    
    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowBackgroundTapGesture:)] autorelease];
    [self.view addGestureRecognizer:tapGesture];
    [self performSelector:@selector(hideNavigationAndOperationView) withObject:nil afterDelay:3];
    
    /** 播放完成监听*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayerDidFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat closeButtonWidth = 60;              //关闭按钮宽
    CGFloat buttonWidth = 60;                   //暂停播放按钮宽
    CGFloat timeLabelWidth = 60;            //左边右边时间label宽
    self.coverImageView.frame = self.view.bounds;
    self.navigationView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 60);
    self.opeView.frame = CGRectMake(0.0, self.view.bounds.size.height - 60,self.view.bounds.size.width,50 );
    self.playPauseButton.frame = CGRectMake(0.0, 0.0, buttonWidth, _opeView.frame.size.height);
    self.leftTimeLabel.frame = CGRectMake(buttonWidth, 0.0, timeLabelWidth, _opeView.frame.size.height);
    self.progressSlider.frame = CGRectMake(buttonWidth + timeLabelWidth, 10, self.view.bounds.size.width - buttonWidth - timeLabelWidth * 2, _opeView.frame.size.height - 20);
    self.rightTimeLabel.frame = CGRectMake(self.view.bounds.size.width - buttonWidth, 0.0, buttonWidth, _opeView.frame.size.height);
    self.closeButton.frame = CGRectMake(self.view.bounds.size.width - closeButtonWidth, 0.0, closeButtonWidth, closeButtonWidth);
    if(_playerLayer){
        _playerLayer.frame = self.view.bounds;
    }
    
}

//- (BOOL)prefersStatusBarHidden
//{
//    return  NO;
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showVideoViewWithUrlStringInViewController];
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [_videoUrl release];
    [_coverImageUrl release];
    [_videoPHAsset release];
    [_coverImageView release];
    [_videoPlayer release];
    [_playerLayer release];
    [_playerItem release];
    [_timeObser release];
    [_navigationView release];
    [_opeView release];
    [_leftTimeLabel release];
    [_rightTimeLabel release];
    [_progressSlider release];
    [_playPauseButton release];
    [_closeButton release];
    [_tipsLabel release];
    RZReleaseSafe(_closePlayVideoEvent);
    [super dealloc];
}

/** 懒加载UI*/
- (RZWebImageView *)coverImageView
{
    if(!_coverImageView){
        _coverImageView = [[RZWebImageView alloc] init];
        _coverImageView.userInteractionEnabled = NO;
        _coverImageView.clipsToBounds = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImageView;
}

- (UIView *)navigationView
{
    if(!_navigationView){
        _navigationView = [[UIView alloc] init];
        _navigationView.clipsToBounds = YES;
        _navigationView.backgroundColor = RGBA(0, 0, 0, 0.3);
    }
    return _navigationView;
}

- (UIView *)opeView
{
    if(_opeView == nil){
        _opeView = [[UIView alloc] init];
        _opeView.clipsToBounds = YES;
        _opeView.backgroundColor = RGBA(0, 0, 0, 0.3);
    }
    return _opeView;
}

- (UILabel *)leftTimeLabel
{
    if(_leftTimeLabel == nil){
        _leftTimeLabel = [[UILabel alloc] init];
        _leftTimeLabel.textAlignment = NSTextAlignmentCenter;
        _leftTimeLabel.textColor = [UIColor whiteColor];
        _leftTimeLabel.text = @"00:00";
        _leftTimeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _leftTimeLabel;
}

- (UILabel *)rightTimeLabel
{
    if(!_rightTimeLabel){
        _rightTimeLabel = [[UILabel alloc] init];
        _rightTimeLabel.textAlignment = NSTextAlignmentCenter;
        _rightTimeLabel.textColor = [UIColor whiteColor];
        _rightTimeLabel.text = @"00:00";
        _rightTimeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _rightTimeLabel;
}

- (UISlider *)progressSlider
{
    if(!_progressSlider){
        _progressSlider = [[UISlider alloc] init];
        [_progressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
        [_progressSlider setMaximumTrackTintColor:[UIColor grayColor]];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"smallvideo_icon_progress_dot"] forState:UIControlStateNormal];
        [_progressSlider setMaximumValue:1.0];
        [_progressSlider setMinimumValue:0.0];
        _progressSlider.continuous = YES;
    }
    return _progressSlider;
}

- (UIButton *)playPauseButton
{
    if(!_playPauseButton){
        _playPauseButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [_playPauseButton setImage:[UIImage imageNamed:@"smallvideo_button_pause"] forState:UIControlStateNormal];
    }
    return _playPauseButton;
}

- (UIButton *)closeButton
{
    if(!_closeButton){
        _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [_closeButton setImage:[UIImage imageNamed:@"smallvideo_button_close"] forState:UIControlStateNormal];
    }
    return _closeButton;
}

- (UILabel *)tipsLabel
{
    if(!_tipsLabel){
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.font = [UIFont systemFontOfSize:15.0f];
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.backgroundColor = [UIColor blackColor];
        _tipsLabel.layer.masksToBounds = YES;
        _tipsLabel.layer.cornerRadius = 3;
    }
    return _tipsLabel;
}

#pragma mark - 显示视频
- (void)showVideoViewWithUrlStringInViewController
{
    if(self.videoUrl.length > 0 && self.videoUrl != nil){
        if(_videoPlayer == nil){
            [self.coverImageView showImageWithUrl:_coverImageUrl];
            
            [self showProgressDefaultText];
            
            NSURL *url = [NSURL URLWithString:_videoUrl];
            self.playerItem = [[[AVPlayerItem alloc] initWithURL:url] autorelease];
            self.videoPlayer = [[[AVPlayer alloc] initWithPlayerItem:_playerItem] autorelease];
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_videoPlayer];
            _playerLayer.frame = self.view.bounds;
            [self.view.layer addSublayer:_playerLayer];
            [self.view bringSubviewToFront:_navigationView];
            [self.view bringSubviewToFront:_opeView];
            
            [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            
            __block typeof(self) weakSelf = self;
            self.timeObser = [_videoPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                NSInteger current= CMTimeGetSeconds(time);
                NSInteger total = CMTimeGetSeconds(weakSelf.playerItem.asset.duration);
                [weakSelf updateLeftTimeLabel:current];
                [weakSelf updateProgressSlider:current totalDuration:total];
            }];
            
            
        }
    }else{
        PHVideoRequestOptions* options = [[[PHVideoRequestOptions alloc] init] autorelease];
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestAVAssetForVideo:self.videoPHAsset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
             dispatch_async(dispatch_get_main_queue(), ^{
                 AVURLAsset *videoAsset = (AVURLAsset*)avasset;
                 if(_videoPlayer == nil){
                     self.playerItem = [[[AVPlayerItem alloc] initWithAsset:videoAsset] autorelease];
                     self.videoPlayer = [[[AVPlayer alloc] initWithPlayerItem:_playerItem] autorelease];
                     self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_videoPlayer];
                     _playerLayer.frame = self.view.bounds;
                     [self.view.layer addSublayer:_playerLayer];
                     [self.view bringSubviewToFront:_navigationView];
                     [self.view bringSubviewToFront:_opeView];
                     
                     [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
                     
                     __block typeof(self) weakSelf = self;
                     self.timeObser = [_videoPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                         NSInteger current= CMTimeGetSeconds(time);
                         NSInteger total = CMTimeGetSeconds(weakSelf.playerItem.asset.duration);
                         [weakSelf updateLeftTimeLabel:current];
                         [weakSelf updateProgressSlider:current totalDuration:total];
                     }];
                 }
                
             });
        }];
    }
   
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = _playerItem.status;
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                [self dismissProgress];
                self.coverImageView.hidden = YES;
                [self initRightTimeLabel];
                [_videoPlayer play];
            }
                break;
            case AVPlayerItemStatusUnknown:
                
                break;
            case AVPlayerItemStatusFailed:
                [self dismissProgress];
                [self updatePlayPauseButtonState:YES];
                [self showTipsLabelWithText:@"加载视频失败"];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - 隐藏显示
- (void)showNavigationAndOperationView
{
    isShowView = YES;
    [UIView animateWithDuration:0.3 animations:^{
        _opeView.alpha = 1.0;
        _navigationView.alpha = 1.0;
    }completion:^(BOOL finished) {
        isTapGestureFinished = YES;
    }];
}

- (void)hideNavigationAndOperationView
{
    if(_videoPlayer.rate == 0){         //如果已经停止了播放，则不需要隐藏
        isTapGestureFinished = YES;
        return;
    }
    isShowView = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _opeView.alpha = 0.0;
        _navigationView.alpha = 0.0;
    } completion:^(BOOL finished) {
        isTapGestureFinished = YES;
    }];
    
}

#pragma mark -
/** 设置时间*/
- (void)initRightTimeLabel
{
    NSInteger seconds = 0;
    NSInteger minutes = 0;
    seconds = (NSInteger)(_playerItem.asset.duration.value / _playerItem.asset.duration.timescale);
    
    if(seconds >= 60){
        minutes = seconds / 60;
        seconds = seconds % 60;
    }
    
    _leftTimeLabel.text = @"00:00";
    if(minutes < 10){
        if(seconds < 10){
            _rightTimeLabel.text = [NSString stringWithFormat:@"0%@:0%@",@(minutes),@(seconds)];
        }else{
            _rightTimeLabel.text = [NSString stringWithFormat:@"0%@:%@",@(minutes),@(seconds)];
        }
    }else{
        if(seconds < 10){
            _rightTimeLabel.text = [NSString stringWithFormat:@"0%@:0%@",@(minutes),@(seconds)];
        }else{
            _rightTimeLabel.text = [NSString stringWithFormat:@"%@:%@",@(minutes),@(seconds)];
        }
    }
    
}

- (void)updateLeftTimeLabel:(NSInteger)duration
{
    NSInteger currentSeconds = 0;
    NSInteger currentMinutes = 0;
    currentSeconds = (NSInteger)(_playerItem.currentTime.value / _playerItem.currentTime.timescale);
    if(currentSeconds >= 60){
        currentMinutes = currentSeconds / 60;
        currentSeconds = currentSeconds % 60;
    }
    
    if(currentMinutes < 10){
        if(currentSeconds < 10){
            _leftTimeLabel.text = [NSString stringWithFormat:@"0%@:0%@",@(currentMinutes),@(currentSeconds)];
        }else{
            _leftTimeLabel.text = [NSString stringWithFormat:@"0%@:%@",@(currentMinutes),@(currentSeconds)];
        }
    }else{
        if(currentSeconds < 10){
            _leftTimeLabel.text = [NSString stringWithFormat:@"0%@:0%@",@(currentMinutes),@(currentSeconds)];
        }else{
            _leftTimeLabel.text = [NSString stringWithFormat:@"%@:%@",@(currentMinutes),@(currentSeconds)];
        }
    }
}

- (void)updateProgressSlider:(NSInteger)currentDuration totalDuration:(NSInteger)totalDuration
{
    CGFloat percentage = (CGFloat)currentDuration / totalDuration;
    [_progressSlider setValue:percentage];
}


#pragma mark - 按钮点击事件
/** 关闭页面时候一定要注意将所有的注册信息等等释放掉，要不不能正常地释放*/
- (void)closeButtonPressed:(id)sender
{
    [self dismissProgress];                     //为了保证能立即释放在关闭时一定要消失加载框
    [[self class] cancelPreviousPerformRequestsWithTarget:self];            //取消本类所有的延迟函数
    [_videoPlayer removeTimeObserver:_timeObser];                           //取消video player对视频每秒的观察
    _closePlayVideoEvent ? _closePlayVideoEvent():nil;
}

- (void)playPauseButtonPressed:(id)sender
{
    /** 取消之前设置的延迟函数 */
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNavigationAndOperationView) object:nil];
    isPlay = !isPlay;
    if(isPlay){
        [_videoPlayer play];
        [self.playPauseButton setImage:[UIImage imageNamed:@"smallvideo_button_pause"] forState:UIControlStateNormal];
        [self performSelector:@selector(hideNavigationAndOperationView) withObject:nil afterDelay:3];           //启动延迟函数，保证show view后会自动隐藏
    }else{
        [_videoPlayer pause];
        [self.playPauseButton setImage:[UIImage imageNamed:@"smallvideo_button_play"] forState:UIControlStateNormal];
    }
}

#pragma mark - progress slider
/** 准备点击*/
- (void)progressSliderWillTouch:(UISlider *)slider
{
    /** 取消之前设置的延迟函数 */
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNavigationAndOperationView) object:nil];
}
/** 拖动进度条*/
- (void)progressSliderValueDidChange:(UISlider *)slider
{
    [_videoPlayer pause];
    CGFloat percentage = slider.value;
    NSInteger sliderScale = percentage *  _playerItem.asset.duration.value;
    
    [_videoPlayer seekToTime:CMTimeMake(sliderScale, _playerItem.asset.duration.timescale) toleranceBefore:CMTimeMake(1, 1000) toleranceAfter:CMTimeMake(1, 1000)];
}
/** 操作完毕*/
- (void)progresSliderOperationDidEnd:(UISlider *)slider
{
    [_videoPlayer play];
    [self performSelector:@selector(hideNavigationAndOperationView) withObject:nil afterDelay:3];           //启动延迟函数，保证show view后会自动隐藏
}

#pragma mark - video 通知
- (void)videoPlayerDidFinished
{
    [_videoPlayer seekToTime:CMTimeMake(0, 1)];
    [self updatePlayPauseButtonState:YES];
    [self showNavigationAndOperationView];
}

#pragma mark - gesture
- (void)windowBackgroundTapGesture:(UIGestureRecognizer *)recognizer
{
    /** 每次点击先取消之前设置的延迟函数 */
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNavigationAndOperationView) object:nil];
    if(isTapGestureFinished){
        isTapGestureFinished = NO;
        if(isShowView){
            [self hideNavigationAndOperationView];
        }else{
            [self performSelector:@selector(hideNavigationAndOperationView) withObject:nil afterDelay:3];           //启动延迟函数，保证show view后会自动隐藏
            [self showNavigationAndOperationView];
        }
    }
}

#pragma mark - 设置play pause button状态
/** finish: true为完成播放，false为未完成播放*/
- (void)updatePlayPauseButtonState:(BOOL)finish
{
    if(finish){
        isPlay = NO;
        [_playPauseButton setImage:[UIImage imageNamed:@"smallvideo_button_play"] forState:UIControlStateNormal];
    }else{
        isPlay = YES;
        [_playPauseButton setImage:[UIImage imageNamed:@"smallvideo_button_pause"] forState:UIControlStateNormal];
    }
}

#pragma mark - 旋转
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - 显示与隐藏tips文本
- (void)showTipsLabelWithText:(NSString *)text
{
    CGFloat width = [CommonUtil getPerfectLabelTextWidth:text andFontSize:15.0f andHeight:30].width + 10;
    [self.tipsLabel setFrame:CGRectMake((SCREEN_WIDTH / 2.0f) - (width / 2.0f), (SCREEN_HEIGHT / 2.0f) - (21 /2.0f), width, 30)];
    self.tipsLabel.text = text;
    self.tipsLabel.hidden = NO;
    [self performSelector:@selector(tipsLabelHidden) withObject:nil afterDelay:3.0f];
}

- (void)tipsLabelHidden
{
    self.tipsLabel.hidden = YES;
}


////电话中断的通知
//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
////中断事件
//- (void)handleInterruption:(NSNotification *)notification{
//
//    NSDictionary *info = notification.userInfo;
//    //一个中断状态类型
//    AVAudioSessionInterruptionType type =[info[AVAudioSessionInterruptionTypeKey] integerValue];
//
//    //判断开始中断还是中断已经结束
//    if (type == AVAudioSessionInterruptionTypeBegan) {
//        //停止播放
//        [self.player pause];
//
//    }else {
//        //如果中断结束会附带一个KEY值，表明是否应该恢复音频
//        AVAudioSessionInterruptionOptions options =[info[AVAudioSessionInterruptionOptionKey] integerValue];
//        if (options == AVAudioSessionInterruptionOptionShouldResume) {
//            //恢复播放
//            [self.player play];
//        }
//
//    }
//
//}

@end
