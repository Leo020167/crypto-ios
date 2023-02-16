//
//  HomeBigVController.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/10/27.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "HomeBigVController.h"
#import "NetWorkManage+Home.h"
#import "NetWorkManage+Personal.h"
#import "CropymeBannerEntity.h"
#import "RZWebImageView.h"
#import "CommonUtil.h"
#import "RZSmallVideoManager.h"
#import "MHBannerView.h"
#import "RZWebImageView.h"
#import "PCAnnounceModel.h"
#import "LMJVerticalScrollText.h"
#import "HomeBigVRankingCell.h"

@interface HomeBigVController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,MHBannerViewDelegate,LMJVerticalScrollTextDelegate>
{
    NSMutableArray *bannerDataArr;
    
    NSMutableArray *announceDataArr;
    BOOL reqRankDataFinished;           //是否已经请求完排行榜数据
    NSInteger operationIndex;               //操作索引
    RZSmallVideoManager *videoManager;               //创建一个视频管理类
    CGPoint panGesturePoint;                //拖动手势坐标
    CGFloat defaultCoreTableViewTopConstant;        //开始coreTableView的头部约束值
    NSInteger preAppCount;          //之前应用的数量
}


@property (copy, nonatomic) NSString *bannerUrlsCache;          //banner缓存
@property (retain, nonatomic) UIPanGestureRecognizer *panGesture;           //拖动手势
@property (retain, nonatomic) MHBannerView *bannerView;

/** 懒加载*/
@property (assign, nonatomic) CGFloat rankNoDataCellHeight; //

@property (retain, nonatomic) UIView *tableHeaderView;
@property (retain, nonatomic) UIView *rankHeaderView;       //排行榜
@property (retain, nonatomic) UIView *announceHeaderView;   //公告

@property (nonatomic, strong) NSMutableArray *rankDataArr;

@property (nonatomic, strong) UIView *navView;

@property (nonatomic, strong) UIButton *backBtn;

/** UI*/
@property (retain, nonatomic) IBOutlet UITableView *coreTableView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *coreTableViewLayoutConstraintTop;        //coreTableView头部约束

@end

@implementation HomeBigVController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    reqRankDataFinished = NO;
    bannerDataArr = [[NSMutableArray alloc] init];
    self.rankDataArr = [[NSMutableArray alloc] init];
    announceDataArr = [[NSMutableArray alloc] init];
    _coreTableView.delegate = self;
    _coreTableView.dataSource = self;
    defaultCoreTableViewTopConstant = _coreTableViewLayoutConstraintTop.constant;
    videoManager = [[RZSmallVideoManager alloc] init];
    if (@available(iOS 11.0, *)) {
        self.coreTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.coreTableView registerClass:[HomeBigVRankingCell class] forCellReuseIdentifier:NSStringFromClass([HomeBigVRankingCell class])];
    self.coreTableView.scrollEnabled = NO;
    self.panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragCoreTableView:)] autorelease];
    [self.coreTableView addGestureRecognizer:_panGesture];
    
    self.coreTableView.tableHeaderView = self.tableHeaderView;
    
    [self setNav];
}

- (void)setNav{
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kUINormalNavBarHeight)];
    navView.hidden = YES;
    self.navView = navView;
    [self.view addSubview:navView];
    navView.backgroundColor = UIColor.whiteColor;
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kUIStatusBarHeight, 44, 44)];
    [backBtn setImage:UIImageMake(@"btn_back_black") forState:0];
    backBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
        [self.navigationController popViewControllerAnimated:YES];
    };
    [navView addSubview:backBtn];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedStringForKey(@"排行榜");
    titleLabel.textColor = UIColor.blackColor;
    titleLabel.font = UIFontMake(17);
    [navView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(navView);
        make.top.mas_equalTo(kUIStatusBarHeight);
        make.height.mas_equalTo(44);
    }];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if(_bannerView == nil){         //增加广告view
        [self.view addSubview:self.bannerView];
        [self.view sendSubviewToBack:self.bannerView];
    }
    [self.bannerView setAutoScroll:YES];
    
    if([bannerDataArr count] == 0 || [self.rankDataArr count] == 0){
        [self reqRankDataArr];
    }
    if([announceDataArr count] > 0){
        LMJVerticalScrollText *scrollText = [self.announceHeaderView viewWithTag:100];
        [scrollText startScrollBottomToTopWithNoSpace];
    }else{
        /** 获取公告*/
        [self reqTopAnnounce];
    }
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.bannerView setAutoScroll:NO];
    LMJVerticalScrollText *scrollText = [self.announceHeaderView viewWithTag:100];
    [scrollText stop];
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [bannerDataArr release];
    [announceDataArr release];
    RZReleaseSafe(videoManager);
    [_bannerUrlsCache release];
    [_panGesture release];
    [_coreTableView release];
    [_bannerView release];
    [_tableHeaderView release];
    [_rankHeaderView release];
    [_announceHeaderView release];
    [_coreTableViewLayoutConstraintTop release];
    [super dealloc];
}

#pragma mark - 懒加载
- (MHBannerView *)bannerView
{
    if(!_bannerView){
        _bannerView = [[MHBannerView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 250)];
        _bannerView.delegate = self;
        [_bannerView addSubview:self.backBtn];
    }
    return _bannerView;
}

- (UIView *)announceHeaderView
{
    if(!_announceHeaderView){
        self.announceHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeAnnounceHeaderView" owner:nil options:nil] lastObject];
        UIButton *button = (UIButton *)[_announceHeaderView viewWithTag:200];
        [button addTarget:self action:@selector(allAnnounceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        LMJVerticalScrollText *scrollText = [_announceHeaderView viewWithTag:100];
        scrollText.delegate            = self;
        scrollText.textStayTime        = 2;
        scrollText.scrollAnimationTime = 1;
        scrollText.backgroundColor     = [UIColor whiteColor];
        scrollText.textColor           = RGBA(61, 58, 80, 1.0);
        scrollText.textFont            = [UIFont boldSystemFontOfSize:14.f];
        scrollText.textAlignment       = NSTextAlignmentLeft;
        scrollText.touchEnable         = NO;
        scrollText.layer.cornerRadius  = 3;
    }
    return _announceHeaderView;
    
}

- (UIView *)tableHeaderView
{
    if(!_tableHeaderView){
        self.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 20)] autorelease];
        [_tableHeaderView setBackgroundColor:[UIColor whiteColor]];
        UIImageView *iv = [[[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 35)/2.0f, 5, 35, 5)] autorelease];
        [iv setBackgroundColor:RGBA(220, 220, 220, 1.0)];
        [_tableHeaderView addSubview:iv];
    }
    return _tableHeaderView;
}

- (CGFloat)rankNoDataCellHeight
{
    if(_rankNoDataCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeRankNoDataCell" owner:nil options:nil] lastObject];
        _rankNoDataCellHeight = cell.frame.size.height;
    }
    return _rankNoDataCellHeight;
}

- (UIView *)rankHeaderView
{
    if(_rankHeaderView == nil){
        _rankHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH, 50)];
        titleLabel.text = NSLocalizedStringForKey(@"大V排行榜");
        titleLabel.textColor = UIColor.blackColor;
        titleLabel.font = UIFontBoldMake(18);
        [_rankHeaderView addSubview:titleLabel];
    }
    return  _rankHeaderView;
}

#pragma mark - 按钮点击事件
- (void)allAnnounceButtonPressed:(UIButton *)sender
{
    [self pageToViewControllerForName:@"PCAnnounceController"];
}


#pragma mark - 请求数据
- (void)reqRankDataArr
{
    [[NetWorkManage shareSingleNetWork] reqHomeCropymeData:self finishedCallback:@selector(reqRankDataArrFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqRankDataArrFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        reqRankDataFinished = YES;
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *bannerList = [dataDic objectForKey:@"banner"];
        NSArray *scoreRankList = [dataDic objectForKey:@"scoreRank"];
        if(!checkIsStringWithAnyText(_bannerUrlsCache)){             //如果缓存不存在，则赋值
            self.bannerUrlsCache = [CommonUtil jsonToString:bannerList];
            [bannerDataArr removeAllObjects];
            NSMutableArray *urlArray = [NSMutableArray array];  //保存banner图片url临时数组
            for(NSDictionary *bannerDic in bannerList){
                CropymeBannerEntity *entity = [[[CropymeBannerEntity alloc] initWithJson:bannerDic] autorelease];
                [bannerDataArr addObject:entity];
                [urlArray addObject:entity.imageUrl];
            }
            _bannerView.dataArray = urlArray;
        }else{                                                      //如果缓存存在
            if(![self.bannerUrlsCache isEqualToString:[CommonUtil jsonToString:bannerList]]){
                [bannerDataArr removeAllObjects];
                NSMutableArray *urlArray = [NSMutableArray array];  //保存banner图片url临时数组
                for(NSDictionary *bannerDic in bannerList){
                    CropymeBannerEntity *entity = [[[CropymeBannerEntity alloc] initWithJson:bannerDic] autorelease];
                    [bannerDataArr addObject:entity];
                    [urlArray addObject:entity.imageUrl];
                }
                _bannerView.dataArray = urlArray;
            }
        }
        
        [self.rankDataArr removeAllObjects];
        for(NSDictionary *dic in scoreRankList){
            InfluencerRankEntity *entity = [InfluencerRankEntity yy_modelWithDictionary:dic];
            [self.rankDataArr addObject:entity];
        }

        [_coreTableView reloadData];
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqTopAnnounce
{
    [[NetWorkManage shareSingleNetWork] reqTopAnnounceData:self finishedCallback:@selector(reqTopAnnounceFinished:) failedCallback:@selector(reqPersonalLineChartData:targetUid:timeType:type:finishedCallback:failedCallback:)];
}

- (void)reqTopAnnounceFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataArr = [dataDic objectForKey:@"data"];
        [announceDataArr removeAllObjects];
        for(NSDictionary *announceDic in dataArr){
            PCAnnounceModel *entity = [[[PCAnnounceModel alloc] initWithJson:announceDic] autorelease];
            [announceDataArr addObject:entity.title];
        }
        //滚动数据
        LMJVerticalScrollText *scrollText = [self.announceHeaderView viewWithTag:100];
        [scrollText stopToEmpty];
        scrollText.textDataArr = announceDataArr;
        [scrollText startScrollBottomToTopWithNoSpace];
        [_coreTableView reloadData];
    }
}


#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return self.rankHeaderView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 50;
    }
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(reqRankDataFinished){
        if([self.rankDataArr count] == 0){          //没数据时候显示另一个cell
            return 1;
        }
        return [self.rankDataArr count];
    }
    return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.rankDataArr count] == 0){
        return self.rankNoDataCellHeight;
    }
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.rankDataArr.count > 0){
        HomeBigVRankingCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeBigVRankingCell class]) forIndexPath:indexPath];
//        cell.backgroundColor = UIColor.redColor;
        InfluencerRankEntity *model = [self.rankDataArr objectAtIndex:indexPath.row];
        cell.model = model;
        return cell;
    }
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeRankNoDataCell" owner:nil options:nil] lastObject];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if([self.rankDataArr count] == 0){
        return;
    }
    if(![ROOTCONTROLLER getLoginStatus]){
        return;
    }
    InfluencerRankEntity *rankEntity = [self.rankDataArr objectAtIndex:indexPath.row];
    [self putValueToParamDictionary:ProCoinBaseDict value:rankEntity.userId forKey:@"PersonalMainTargetUid"];
    [self pageToViewControllerForName:@"PersonalMainController"];


}

#pragma mark - banner view delegate
- (void)bannerViewDidTapImage:(NSInteger)index
{
    if(index >= [bannerDataArr count]){
        return;
    }
    CropymeBannerEntity *entity = [bannerDataArr objectAtIndex:index];
    if(entity.type == 1){           //视频播放
        [videoManager showVideoViewWithUrlString:entity.videoUrl coverImageUrl:entity.imageUrl];
    }else{     //站内页面
        if(checkIsStringWithAnyText(entity.pview)){
            [self putValueToParamDictionary:MSG_PARAMS value:entity.params forKey:MSG_PARAMS];
            [self pageToViewControllerForName:entity.pview];
        }
    }
}


#pragma mark - pan gesture
- (void)dragCoreTableView:(UIGestureRecognizer *)rec
{
    if(rec.state == UIGestureRecognizerStateBegan){
        panGesturePoint = [rec locationInView:self.view];
    }else if(rec.state == UIGestureRecognizerStateChanged){
        CGPoint currentPoint = [rec locationInView:self.view];
        CGFloat distace = panGesturePoint.y - currentPoint.y;
        if(distace > 0){
            _coreTableViewLayoutConstraintTop.constant = 235 - distace;
        }
    }else if(rec.state == UIGestureRecognizerStateEnded){
        CGPoint currentPoint = [rec locationInView:self.view];
        CGFloat distace = panGesturePoint.y - currentPoint.y;
        if(distace > 0){
            [self setCoretableViewTopConstantWithAnimation:STATUS_BAR_HEIGHT];
        }else{
            [self setCoretableViewTopConstantWithAnimation:defaultCoreTableViewTopConstant];
        }
    }
}

#pragma mark - core table view animation
- (void)setCoretableViewTopConstantWithAnimation:(CGFloat)constant
{
    [UIView animateWithDuration:0.3 animations:^{
        _coreTableViewLayoutConstraintTop.constant = constant;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if(constant == STATUS_BAR_HEIGHT){
            _coreTableView.scrollEnabled = YES;
            [_coreTableView removeGestureRecognizer:_panGesture];
        }else if(constant == defaultCoreTableViewTopConstant){
            _coreTableView.scrollEnabled = NO;
            [_coreTableView addGestureRecognizer:_panGesture];
        }
    }];
}

#pragma mark - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == _coreTableView){
        CGPoint point = _coreTableView.contentOffset;
        if(point.y < 0){
            _coreTableView.scrollEnabled = NO;
            [self setCoretableViewTopConstantWithAnimation:defaultCoreTableViewTopConstant];
        }
    }
}

- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kUIStatusBarHeight, 44, 44)];
        [_backBtn setImage:UIImageMake(@"btn_back_black") forState:0];
        _backBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
    return _backBtn;
}
@end

