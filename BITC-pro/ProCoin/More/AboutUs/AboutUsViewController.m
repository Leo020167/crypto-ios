//
//  AboutUsViewController.m
//  TJRtaojinroad
//
//  Created by taojinroad on 13-8-12.
//  Copyright (c) 2017年 币吧. All rights reserved.
//

#import "AboutUsViewController.h"
#import "HomeViewController.h"
#import "CommonUtil.h"
#import <MediaPlayer/MediaPlayer.h>


#define SetUpIconName @"SetUpIconName"
#define SetUpName  @"SetUpName"

@interface AboutUsViewController (){
    NSMutableArray *dataArray;
}

@property (retain, nonatomic) IBOutlet UIView *playView;
@property (retain, nonatomic) IBOutlet UIImageView *ivPlayerOpt;
@property (retain, nonatomic) IBOutlet UIImageView *ivPlayerBG;
@property (retain, nonatomic) MPMoviePlayerController *moviePlayer;
@property (retain, nonatomic) IBOutlet UIView *headerView;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation AboutUsViewController
@synthesize appInfo;
@synthesize timer;

- (void)viewDidLoad {
	[super viewDidLoad];

	bReqFinished = YES;

    [CommonUtil viewMasksToBounds:_updateView cornerRadius:4.0 borderColor:nil];
	
    [[NSBundle mainBundle] loadNibNamed:@"AboutUsCellHeader" owner:self options:nil];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _versionLabel.text = [NSString stringWithFormat:@"当前版本  %@", version];
    
    dataArray = [NSMutableArray new];
    [self createDataArray];
    
    [self setExtraCellLineHidden:_tableView];
    
    [_tableView reloadData];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [_playView addGestureRecognizer:tap];
    RELEASE(tap);
}

- (void)createDataArray {
    NSArray *array = @[@{SetUpIconName:@"aboutus_icon_introduction",SetUpName:@"欢迎页"},@{SetUpIconName:@"account_setup_icon_otherAccount",SetUpName:@"帮助说明"},@{SetUpIconName:@"aboutus_icon_review",SetUpName:@"给币吧评分"},@{SetUpIconName:@"aboutus_icon_ader",SetUpName:@"广告与商务合作"}];
    [dataArray addObject:array];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
    if (_moviePlayer) [_moviePlayer stop];
    [_moviePlayer release];
	self.timer = nil;
	[appInfo release];
	[_versionLabel release];
    [_updateView release];
    [_tableView release];
    [_headerView release];
    [_playView release];
    [_ivPlayerOpt release];
    [_ivPlayerBG release];
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addMoviePlayerNotification];
    if (_moviePlayer && (_moviePlayer.playbackState == MPMoviePlaybackStatePaused)) {
        [_moviePlayer play];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self removeMoviePlayerNotification];
    if (_moviePlayer && (_moviePlayer.playbackState == MPMoviePlaybackStatePlaying)) {
        [_moviePlayer pause];
    }
    [super viewDidDisappear:animated];
}


- (void)viewDidUnload {
	self.timer = nil;
	[self setVersionLabel:nil];
	[super viewDidUnload];
}

- (IBAction)leftButtonClicked:(id)sender {
	[self goBackOrPop];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataArray.count + 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return _headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return _headerView.frame.size.height;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 1) {
        NSArray *array = dataArray[section - 1];
        return array.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AboutUsCellIdentifier"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"AboutUsCell" owner:self options:nil] lastObject];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.textColor = RGBA(119, 119, 119, 1);
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
            cell.detailTextLabel.textColor = RGBA(12, 166, 242, 1);
        }
        NSArray *a = dataArray[indexPath.section - 1];
        NSDictionary *dic = a[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:dic[SetUpIconName]];
        cell.textLabel.text = dic[SetUpName];
            
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self panelIntroLogin];
        }else if (indexPath.row == 1) {
            [self helpAction];
        }else if (indexPath.row == 2) {
            [self praiseAction];
        }else if (indexPath.row == 3) {
            [self pageToViewControllerForName:@"AdvertiserViewController"];
        }
    }
}


- (void)panelIntroLogin{
    [CommonUtil setPageToAnimation];
    [self putValueToParamDictionary:FeedbackDict value:[NSNumber numberWithBool:YES] forKey:@"aboutUsIn"];
    [self pageToViewControllerForName:@"TJRIntroductionController" animated:NO];
}

- (void)helpAction{
    NSString* url = @"https://web.redflea.com/pervalsys/html/showQuestion.html";
    [self putValueToParamDictionary:TJRWebViewDict value:url forKey:@"webURL"];
    [self pageToViewControllerForName:@"TJRWebViewController"];
}

- (void)praiseAction{
    NSString *str;
    
    if (CURRENT_DEVICE_VERSION >= 7.0) {
        str = @"itms-apps://itunes.apple.com/app/id1270673451";
    } else {
        str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1270673451";
    }
    NSURL *url = [NSURL URLWithString:str];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)setExtraCellLineHidden:(UITableView *)tView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tView setTableFooterView:view];
    [view release];
}

#pragma mark - 图片 视频点击事件
- (void)tapGestureAction:(UITapGestureRecognizer *)rec
{
    if (rec.state == UIGestureRecognizerStateEnded) {
        _ivPlayerBG.hidden = true;
        _ivPlayerOpt.hidden = true;
        NSString* file = @"http://video.redflea.com/redflea_intro_video.mp4";
        [self createVideoPlayerWithView:_playView urlString:file];
    }
}

#pragma mark - 播放视频
- (void)createVideoPlayerWithView:(UIView *)view urlString:(NSString *)urlString
{
    if (!TTIsStringWithAnyText(urlString)) return;
    if (_moviePlayer) {
        [self resetVedioPlayState];
        [_moviePlayer stop];
        [_moviePlayer.view removeFromSuperview];
        RELEASE(_moviePlayer);
    }
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    player.view.frame = view.bounds;
    player.scalingMode = MPMovieScalingModeNone;
    [view addSubview:player.view];
    [player play];
    self.moviePlayer = player;
    RELEASE(player);
}


#pragma mark - 重新设置视频的Icon等
- (void)resetVedioPlayState
{
    _playView.hidden = false;
    _ivPlayerOpt.hidden = false;
}

#pragma mark - 视频播放监听 添加
- (void)addMoviePlayerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerNotification:) name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
}

#pragma mark - 视频播放监听 移除
- (void)removeMoviePlayerNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerWillExitFullscreenNotification object:nil];
}

#pragma mark - 视频播放监听 处理
- (void)moviePlayerNotification:(NSNotification *)noti {
    if (_moviePlayer) {
        [_moviePlayer play];
    }
}


@end

