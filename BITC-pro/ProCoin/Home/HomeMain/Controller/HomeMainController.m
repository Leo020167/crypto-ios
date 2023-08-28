//
//  HomeMainController.m
//  Cropyme
//
//  Created by Hay on 2019/5/29.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "HomeMainController.h"
#import "HomeMainListViewController.h"
#import "JXCategoryView.h"
#import "HomeMainHeaderView.h"
#import "JXCategoryView.h"

#import "NetWorkManage+Home.h"
#import "NetWorkManage+Personal.h"
#import "CropymeBannerEntity.h"
#import "InfluencerRankEntity.h"
#import "RZWebImageView.h"
#import "CommonUtil.h"
#import "RZSmallVideoManager.h"
#import "SDCycleScrollView.h"
#import "RZWebImageView.h"
#import "PCAnnounceModel.h"
#import "HomeNewPurchaseBaseViewController.h"
#import "PrivateChatDataEntity.h"
#import "TJRBaseParserJson.h"
#import "NetWorkManage+Circle.h"
#import "PrivateChatSQL.h"
#import "UserInfoSQL.h"
#import "ServiceQRController.h"
#import "LanguageManager.h"
#import "PledgeIndexViewController.h"

@interface HomeMainController ()<JXPagerViewDelegate, JXCategoryViewDelegate, JXPagerMainTableViewGestureDelegate>

@property (nonatomic, strong) HomeMainHeaderView *headerView;

@property (nonatomic, strong) JXCategoryTitleView *categoryView;

@property (nonatomic, strong) JXPagerView *pagingView;

@property (nonatomic, strong) NSMutableArray *bannerArray;

@property (nonatomic, strong) NSMutableArray *quoteArray;

@property (nonatomic, strong) NSTimer *requestDataTimer;

@property (nonatomic, strong) HomeMainListViewController *list1;

@property (nonatomic, strong) HomeMainListViewController *list2;

@end

@implementation HomeMainController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self startRequestTimer];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self closeRequestTimer];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.pagingView.frame = CGRectMake(10, 0, SCREEN_WIDTH - 20, SCREEN_HEIGHT);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [self setNav];
    
    [self getData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reqRankDataArr) name:@"refreshHomeBanner" object:nil];

}

- (void)setNav{
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kUINormalNavBarHeight)];
    [self.view addSubview:navView];
    navView.backgroundColor = UIColorMakeWithHex(@"#E2E6F2");
    
//    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
//    [navView addSubview:bgView];
//    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(navView);
//        make.top.mas_equalTo(kUIStatusBarHeight + 10);
//        make.size.mas_equalTo(CGSizeMake(120, 24));
//    }];
    
//    UIImageView *wordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(31, 3.5, 87, 17)];
//    wordImageView.image = UIImageMake(@"home_main_logo_word");
//    [bgView addSubview:wordImageView];
    
//    UIImageView *logoImageView = [[UIImageView alloc] init];
//    logoImageView.image = UIImageMake(@"home_main_logo");
//    [bgView addSubview:logoImageView];
    
    UIButton *iconBtn = [[UIButton alloc] init];
    [iconBtn setImage:UIImageMake(@"home_main_icon") forState:0];
    [navView addSubview:iconBtn];
    iconBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
        if(ROOTCONTROLLER_USER.userId){
            self.tabBarController.selectedIndex = 4;
        }else{
            [ROOTCONTROLLER gotoLogin];
        }
    };
    [iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(kUIStatusBarHeight);
        make.height.mas_equalTo(44);
    }];
//    UIImageView *logoImageView = [[UIImageView alloc] init];
//    logoImageView.image = UIImageMake(@"home_main_logo_word");
//    [navView addSubview:logoImageView];
//    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(iconBtn);
//        make.centerX.mas_equalTo(navView);
//        make.size.mas_equalTo(CGSizeMake(74, 30));
//    }];
    // 语言设置
    UIButton *languageBtn = [[UIButton alloc] init];
    [languageBtn setImage:UIImageMake(@"home_main_icon") forState:0];
    [navView addSubview:languageBtn];
    languageBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
        [self pageToOrBackWithName:@"LanguageViewController"];
    };
    [languageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(kUIStatusBarHeight);
        make.width.height.mas_equalTo(44);
    }];
    languageBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    NSInteger index = [LanguageManager currentLanguageIndex];
    NSString *code = [LanguageManager languageCountryCodes][index];
    [languageBtn setImage:[UIImage imageNamed:code] forState: UIControlStateNormal];
}

- (void)initUI{
    self.view.backgroundColor = UIColorMakeWithHex(@"#E2E6F2");
    NSMutableArray *titlesArray = [NSMutableArray arrayWithArray:@[NSLocalizedStringForKey(@"涨幅榜"), NSLocalizedStringForKey(@"跌幅榜")]];
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.backgroundColor = UIColorClear;
    lineView.indicatorColor = UIColorClear;
    lineView.indicatorHeight = 8;
    lineView.verticalMargin = 22;
    lineView.lineStyle = JXCategoryIndicatorLineStyle_LengthenOffset;
    
    self.categoryView.indicators = @[lineView];
    self.categoryView.titles = titlesArray;
    
    _pagingView = [[JXPagerView alloc] initWithDelegate:self];
    self.pagingView.mainTableView.gestureDelegate = self;
    self.pagingView.mainTableView.backgroundColor = UIColorMakeWithHex(@"#E2E6F2");
    self.pagingView.mainTableView.showsVerticalScrollIndicator = NO;
    self.pagingView.pinSectionHeaderVerticalOffset = kUINormalNavBarHeight;
    self.pagingView.frame = CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight - kUINormalTabBarHeight);
    if (@available(iOS 15.0, *)) {
        self.pagingView.mainTableView.sectionHeaderTopPadding = 0;
    }
    [self.view addSubview:self.pagingView];

    //FIXME:如果和JXPagingView联动
    self.categoryView.listContainer = (id<JXCategoryViewListContainer>)self.pagingView.listContainerView;
    self.navigationController.interactivePopGestureRecognizer.enabled = (self.categoryView.selectedIndex == 0);
    self.categoryView.layer.cornerRadius = 10;
    self.categoryView.layer.masksToBounds = YES;
    self.categoryView.collectionView.layer.qmui_maskedCorners = QMUILayerMinXMaxYCorner | QMUILayerMinXMinYCorner;
    self.categoryView.collectionView.layer.cornerRadius = 10;
}

- (void)getData{
    [self reqRankDataArr];
    
    [self getQuoteData];
    
    [self reqTopAnnounce];
    
}
#pragma mark - 请求数据
- (void)reqRankDataArr{
    [YYRequestUtility Post:@"home/config.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            self.bannerArray = [NSMutableArray array];
            NSMutableArray *imageUrlArray = [NSMutableArray array];
            for(NSDictionary *bannerDic in responseDict[@"data"][@"banner"]){
                CropymeBannerEntity *entity = [[[CropymeBannerEntity alloc] initWithJson:bannerDic] autorelease];
                [self.bannerArray addObject:entity];
                [imageUrlArray addObject:entity.imageUrl];
            }
            self.headerView.bannerArray = imageUrlArray;
            [[NSUserDefaults standardUserDefaults] setObject:responseDict[@"data"] forKey:@"banner"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
            [self cacheAction];
        }
    } failure:^(NSError *error) {
        [self cacheAction];
    }];

//    if(!ROOTCONTROLLER_USER.userId){
//        [self cacheAction];
//        return;
//    }
//    [YYRequestUtility Post:@"home/account.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
//        if ([responseDict[@"code"] intValue] == 200) {
//            self.bannerArray = [NSMutableArray array];
//            NSMutableArray *imageUrlArray = [NSMutableArray array];
//            for(NSDictionary *bannerDic in responseDict[@"data"][@"banner"]){
//                CropymeBannerEntity *entity = [[[CropymeBannerEntity alloc] initWithJson:bannerDic] autorelease];
//                [self.bannerArray addObject:entity];
//                [imageUrlArray addObject:entity.imageUrl];
//            }
//            self.headerView.bannerArray = imageUrlArray;
//            [[NSUserDefaults standardUserDefaults] setObject:responseDict[@"data"] forKey:@"banner"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }else{
//            [QMUITips showError:responseDict[@"msg"]];
//            [self cacheAction];
//        }
//    } failure:^(NSError *error) {
//        [self cacheAction];
//    }];
}

- (void)cacheAction{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"banner"]) {
        NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"banner"];
        self.bannerArray = [NSMutableArray array];
        NSMutableArray *imageUrlArray = [NSMutableArray array];
        for(NSDictionary *bannerDic in data[@"banner"]){
            CropymeBannerEntity *entity = [[[CropymeBannerEntity alloc] initWithJson:bannerDic] autorelease];
            [self.bannerArray addObject:entity];
            [imageUrlArray addObject:entity.imageUrl];
        }
        self.headerView.bannerArray = imageUrlArray;
    }
}

- (void)getQuoteData{
    if (self.list1) {
        [self.list1 getData];
    }
    if (self.list2) {
        [self.list2 getData];
    }
    [YYRequestUtility Post:@"quote/homePage.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            self.quoteArray = [NSMutableArray array];
            for (NSDictionary *dict in responseDict[@"data"][@"quotes"]) {
                HomeQuoteModel *model = [HomeQuoteModel yy_modelWithDictionary:dict];
                [self.quoteArray addObject:model];
            }
            self.headerView.quoteArray = self.quoteArray;
            [self startRequestTimer];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {

    }];
}

/// 获取公告数据
- (void)reqTopAnnounce{
    [YYRequestUtility Post:@"article/noticeTop.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            NSMutableArray *announceDataArr = [NSMutableArray array];
            for(NSDictionary *announceDic in responseDict[@"data"][@"data"]){
                PCAnnounceModel *entity = [[[PCAnnounceModel alloc] initWithJson:announceDic] autorelease];
                [announceDataArr addObject:entity.title];
            }
            self.headerView.announceDataArr = announceDataArr;
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        [QMUITips showError:NSLocalizedStringForKey(@"Request Failed")];
    }];
}


#pragma mark - 开启关闭定时器
- (void)startRequestTimer
{
    if(self.requestDataTimer && [self.requestDataTimer isValid]){
        [self closeRequestTimer];
    }
    self.requestDataTimer = [NSTimer timerWithTimeInterval:ROOTCONTROLLER.quotationRefreshTime target:self selector:@selector(getQuoteData) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.requestDataTimer forMode:NSRunLoopCommonModes];
}

- (void)closeRequestTimer
{
    if(self.requestDataTimer && [self.requestDataTimer isValid]){
        [self.requestDataTimer invalidate];
        self.requestDataTimer = nil;
    }
}

#pragma mark - 请求客服数据
- (void)reqPrivateChatService
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqGetPrivateChatService:self finishedCallback:@selector(reqPrivateChatServiceFinished:) failedCallback:@selector(reqPrivateChatServiceFailed:)];
}

- (void)reqPrivateChatServiceFinished:(NSDictionary *)json
{
    [self dismissProgress];
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc]init] autorelease];
    
    if([parser parseBaseIsOk:json]){
        
        NSDictionary *data = [json objectForKey:@"data"];
        NSString *chatTopicId = [parser stringParser:data name:@"chatTopic"];
        
        if (TTIsStringWithAnyText(chatTopicId)) {
            
            NSString* userId =  [parser stringParser:data name:@"userId"];
            NSString* headUrl =  [parser stringParser:data name:@"headUrl"];
            NSString* userName =  [parser stringParser:data name:@"userName"];
            NSInteger type = [parser integerParser:data name:@"type"];
            
            if(type == 0){                  //私聊
                PrivateChatDataEntity * item = [[[PrivateChatDataEntity alloc]init]autorelease];
                item.chatTopic = chatTopicId;
                item.userId = userId;
                item.headurl = headUrl;
                item.name = userName;
                [PrivateChatSQL createPrivateChatSQL:item];
                [UserInfoSQL insertOrUpdateUserInfoWithUserId:userId userName:userName userLevel:0 headerUrl:headUrl];
                
                [self putValueToParamDictionary:ChatDict value:item.chatTopic forKey:@"chatTopic"];
                [self putValueToParamDictionary:ChatDict value:item.name forKey:@"userName"];
                [self putValueToParamDictionary:ChatDict value:item.userId forKey:@"taUserId"];
                [self pageToOrBackWithName:@"ChatViewController"];

            }else if(type == 1){        //二维码
                ServiceQRController *qrController = [[ServiceQRController alloc] init];
                [qrController showServiceQRControllerInController:self.tabBarController title:chatTopicId content:userName qrUrl:headUrl];
            }
            
        }
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqPrivateChatServiceFailed:(NSDictionary *)json
{
    [self  dismissProgress];
    [self showToast:NSLocalizedStringForKey(@"请求失败")];
}


- (UIView *)tableHeaderViewInPagerView:(JXPagerView *)pagerView {
    return self.headerView;
}

- (NSUInteger)tableHeaderViewHeightInPagerView:(JXPagerView *)pagerView {
    return ceil((SCREEN_WIDTH - 20) / 2.1) + 20 + 55 + 240 + kUINormalNavBarHeight;
}

- (NSUInteger)heightForPinSectionHeaderInPagerView:(JXPagerView *)pagerView {
    return 50;
}

- (UIView *)viewForPinSectionHeaderInPagerView:(JXPagerView *)pagerView {
    return self.categoryView;
}

- (NSInteger)numberOfListsInPagerView:(JXPagerView *)pagerView {
    return 2;
}

- (id<JXPagerViewListViewDelegate>)pagerView:(JXPagerView *)pagerView initListAtIndex:(NSInteger)index {
    HomeMainListViewController *intro = [[HomeMainListViewController alloc] init];
    intro.index = index;
    if (index == 0) {
        self.list1 = intro;
    }else if (index == 1){
        self.list2 = intro;
    }
    return intro;
}
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    //侧滑手势处理
    self.navigationController.interactivePopGestureRecognizer.enabled = (index == 0);
}

#pragma mark =========================== 懒加载 ===========================
- (JXCategoryTitleView *)categoryView{
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(50, 0, SCREEN_WIDTH - 100, 50)];
        _categoryView.backgroundColor = UIColor.whiteColor;
        _categoryView.delegate = self;
        _categoryView.layer.qmui_maskedCorners = QMUILayerMaxXMinYCorner | QMUILayerMinXMinYCorner;
        _categoryView.layer.cornerRadius = 10;
        _categoryView.titleSelectedColor = UIColorMakeWithHex(@"#333333");
        _categoryView.titleColor = UIColorMakeWithHex(@"#333333");
        _categoryView.titleSelectedFont = UIFontBoldMake(16);
        _categoryView.titleFont = [UIFont systemFontOfSize:15];
        _categoryView.titleColorGradientEnabled = YES;
        _categoryView.averageCellSpacingEnabled = YES;
        _categoryView.titleLabelAnchorPointStyle = JXCategoryTitleLabelAnchorPointStyleBottom;
    }
    return _categoryView;
}

- (HomeMainHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[HomeMainHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 440 + ceil((SCREEN_WIDTH - 20) / 2.1))];
        _headerView.announceViewActionBlock = ^{
            [self pageToViewControllerForName:@"PCAnnounceController"];
        };
        _headerView.quotationsDataBlock = ^(HomeQuoteModel * _Nonnull model) {
//            [self putValueToParamDictionary:@"CoinTradeDic" value:model.symbol forKey:@"CoinQuotationsDetailSymbol"];
//            [self putValueToParamDictionary:@"CoinTradeDic" value:model.marketType forKey:@"CoinQuotationDetailMarketType"];
//            [self pageToViewControllerForName:@"CoinQuotationsDetailController"];
            
            [self putValueToParamDictionary:CoinTradeDic value:model.symbol forKey:@"CoinQuotationsDetailSymbol"];
            [self putValueToParamDictionary:CoinTradeDic value:model.marketType forKey:@"CoinQuotationDetailMarketType"];
            [self pageToViewControllerForName:@"TYQuotationsDetailController"];

        };
        _headerView.clickActionBlock = ^(NSUInteger type) {
            if (type == 1) {
                [self pageToViewControllerForName:@"HomeBigVController"];
            }else if (type == 2){
                HomeNewPurchaseBaseViewController *purchase = [[HomeNewPurchaseBaseViewController alloc] init];
                [QMUIHelper.visibleViewController.navigationController pushViewController:purchase animated:YES];
            }else if (type == 3){
                if(ROOTCONTROLLER_USER.userId){
                    [self pageToViewControllerForName:@"PledgeIndexViewController"];
//                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Pledge" bundle:nil];
//                    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PledgeIndexViewController"];
//                    [[self getTJRAppDelegate].navigation pushViewController:vc animated:YES];
                }else{
                    [ROOTCONTROLLER gotoLogin];
                }
            }else if (type == 4){
                if(ROOTCONTROLLER_USER.userId){
                    [self pageToViewControllerForName:@"P2PMainController"];
                }else{
                    [ROOTCONTROLLER gotoLogin];
                }
            }else if (type == 5){
                if(ROOTCONTROLLER_USER.userId){
                    [self reqPrivateChatService];
                }else{
                    [ROOTCONTROLLER gotoLogin];
                }
            }
        };
    }
    return _headerView;
}

#pragma mark - JXPagerMainTableViewGestureDelegate

- (BOOL)mainTableViewGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //禁止categoryView左右滑动的时候，上下和左右都可以滚动
    if (otherGestureRecognizer == self.categoryView.collectionView.panGestureRecognizer) {
        return NO;
    }
    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

//@interface HomeMainController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,LMJVerticalScrollTextDelegate,UICollectionViewDelegate,UICollectionViewDataSource, SDCycleScrollViewDelegate>
//{
//    NSMutableArray *bannerDataArr;
//    NSMutableArray *rankDataArr;
//    NSArray *otcarra;
//
//    IBOutlet UILabel *logo_lbl;
//
//    IBOutlet UICollectionView *collection_View;
//    NSMutableArray *announceDataArr;
//    BOOL reqRankDataFinished;           //是否已经请求完排行榜数据
//    NSInteger operationIndex;               //操作索引
//    RZSmallVideoManager *videoManager;               //创建一个视频管理类
//    CGPoint panGesturePoint;                //拖动手势坐标
//    CGFloat defaultCoreTableViewTopConstant;        //开始coreTableView的头部约束值
//    NSInteger preAppCount;          //之前应用的数量
//}
//
///// LOGO
//@property (retain, nonatomic) IBOutlet UIView *firstview;
//
///// V
//@property (retain, nonatomic) IBOutlet UIView *thirdv_View;
//
///// BTC
//@property (retain, nonatomic) IBOutlet UIView *secondview;
//
//@property (nonatomic, strong) HomeMainSecondView *secondSubview;
//
//
//@property (retain, nonatomic) IBOutlet UICollectionView *collectionview;
//
//@property (retain, nonatomic) IBOutlet UIView *fourth_Globalview;
//
///// OTC
//@property (retain, nonatomic) IBOutlet UIView *fifth_visaview;
//
//@property (copy, nonatomic) NSString *bannerUrlsCache;          //banner缓存
//@property (retain, nonatomic) UIPanGestureRecognizer *panGesture;           //拖动手势
//
//
//
//@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
//
///** 懒加载*/
//@property (assign, nonatomic) CGFloat rankNoDataCellHeight; //
//@property (assign, nonatomic) CGFloat rankCellHeight;
//@property (retain, nonatomic) UIView *tableHeaderView;
//@property (retain, nonatomic) UIView *rankHeaderView;
//@property (retain, nonatomic) UIView *rankHeaderView1;       //排行榜
////排行榜
//@property (retain, nonatomic) UIView *announceHeaderView;   //公告
//
//@property (nonatomic, strong) NSTimer *requestDataTimer;
//
//
///** UI*/
//@property (retain, nonatomic) IBOutlet UITableView *coreTableView;
//@property (retain, nonatomic) IBOutlet NSLayoutConstraint *coreTableViewLayoutConstraintTop;        //coreTableView头部约束
//
//@end
//
//@implementation HomeMainController
//@synthesize  scroll_View;
//
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    otcarra = @[@"OTC"];
//
//    [self setNav];
//
//    _firstview.clipsToBounds = true;
//    _firstview.layer.cornerRadius = 10;
//    _thirdv_View.clipsToBounds = true;
//    _thirdv_View.layer.cornerRadius = 10;
//    _fourth_Globalview.clipsToBounds = true;
//    _fourth_Globalview.layer.cornerRadius = 10;
//    _fifth_visaview.clipsToBounds = true;
//    _fifth_visaview.layer.cornerRadius = 10;
//    _secondview.clipsToBounds = true;
//    _secondview.layer.cornerRadius = 10;
//
////    _firstview.backgroundColor = UIColor.redColor;
////    _secondview.backgroundColor = UIColor.orangeColor;
////    _thirdv_View.backgroundColor = UIColor.yellowColor;
////    _fourth_Globalview.backgroundColor = UIColor.greenColor;
////    _fifth_visaview.backgroundColor = UIColor.blueColor;
//
//    [self.secondview addSubview:self.secondSubview];
//    [self.firstview addSubview:self.announceHeaderView];
//    [self.announceHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
//    }];
//
//    [scroll_View addSubview:self.cycleScrollView];
//
//    self.collectionview.delegate = self;
//    self.collectionview.dataSource = self;
//
//
//    [_thirdv_View addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thirdTapAction)]];
//
//    [_fifth_visaview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fifthTapAction)]];
//
//
//
//
//
//    // Do any additional setup after loading the view from its nib.
//    reqRankDataFinished = NO;
//    bannerDataArr = [[NSMutableArray alloc] init];
//    rankDataArr = [[NSMutableArray alloc] init];
//    otcarra = [[NSMutableArray alloc] init];
//    [scroll_View setScrollEnabled:YES];
//    [scroll_View setContentSize:CGSizeMake(375, 950)];
//
//    announceDataArr = [[NSMutableArray alloc] init];
//    _coreTableView.delegate = self;
//    _coreTableView.dataSource = self;
//    defaultCoreTableViewTopConstant = _coreTableViewLayoutConstraintTop.constant;
//    videoManager = [[RZSmallVideoManager alloc] init];
//    if (@available(iOS 11.0, *)) {
//        self.coreTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    }
//    self.coreTableView.scrollEnabled = NO;
//    self.panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragCoreTableView:)] autorelease];
//    [self.coreTableView addGestureRecognizer:_panGesture];
//    [self.collectionview reloadData];
//    self.coreTableView.tableHeaderView = self.tableHeaderView;
//
//    UINib *nib2 = [UINib nibWithNibName:@"CollectionViewCell" bundle:nil];
//       [self.collectionview registerNib:nib2 forCellWithReuseIdentifier:@"CollectionViewCell"];
//
//
//       UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//       [flowLayout setItemSize:CGSizeMake(300, 230)];
//       flowLayout.minimumInteritemSpacing = 0;
//       [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
//    [self.collectionview  setCollectionViewLayout:flowLayout];
//
//    [self.collectionview  reloadData];
//}
//
//- (void)setNav{
//
//    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kUINormalNavBarHeight)];
//    navView.backgroundColor = UIColorMakeWithHex(@"#505F9E");
//    [self.view addSubview:navView];
//    UILabel *titleLabel = [[UILabel alloc] init];
//    titleLabel.text = @"TF Global";
//    titleLabel.textColor = UIColor.whiteColor;
//    titleLabel.font = UIFontBoldMake(17);
//    [navView addSubview:titleLabel];
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(navView);
//        make.bottom.mas_equalTo(0);
//        make.height.mas_equalTo(44);
//    }];
//}
//
//- (void)getData{
//    [YYRequestUtility Post:@"quote/homePage.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
//        if ([responseDict[@"code"] intValue] == 200) {
//            NSMutableArray *dataArray = [NSMutableArray array];
//            for (NSDictionary *dict in responseDict[@"data"][@"quotes"]) {
//                HomeQuoteModel *model = [HomeQuoteModel yy_modelWithDictionary:dict];
//                [dataArray addObject:model];
//            }
//            self.secondSubview.dataArray = dataArray;
//            self.secondSubview.clickDataBlock = ^(HomeQuoteModel * _Nonnull model) {
//                [self putValueToParamDictionary:@"CoinTradeDic" value:model.symbol forKey:@"CoinQuotationsDetailSymbol"];
//                [self putValueToParamDictionary:@"CoinTradeDic" value:model.marketType forKey:@"CoinQuotationDetailMarketType"];
//                [self pageToViewControllerForName:@"CoinQuotationsDetailController"];
//            };
//        }else{
//            [QMUITips showError:responseDict[@"msg"]];
//        }
//    } failure:^(NSError *error) {
//
//    }];
//}
//
//#pragma mark - 开启关闭定时器
//- (void)startRequestTimer
//{
//    if(self.requestDataTimer && [self.requestDataTimer isValid]){
//        [self closeRequestTimer];
//    }
//    self.requestDataTimer = [NSTimer timerWithTimeInterval:ROOTCONTROLLER.quotationRefreshTime target:self selector:@selector(getData) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.requestDataTimer forMode:NSRunLoopCommonModes];
//}
//
//- (void)closeRequestTimer
//{
//    if(self.requestDataTimer && [self.requestDataTimer isValid]){
//        [self.requestDataTimer invalidate];
//        self.requestDataTimer = nil;
//    }
//}
//
//- (void)thirdTapAction{
//    HomeNewPurchaseViewController *purchase = [[HomeNewPurchaseViewController alloc] init];
//    [QMUIHelper.visibleViewController.navigationController pushViewController:purchase animated:YES];
//}
//
//- (void)fifthTapAction{
//    [self pageToViewControllerForName:@"P2PMainController"];
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    return 2;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//
////    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
//    static NSString *cellIdentifier = @"CollectionViewCell";
//    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
//
//    // configuring cell
//    // cell.customLabel.text = [yourArray objectAtIndex:indexPath.row]; // comment this line if you do not want add label from storyboard
//
//    // if you need to add label and other ui component programmatically
////    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)];
////    label.tag = 200;
////    label.text = [yourArray objectAtIndex:indexPath.row];
////
////    // this adds the label inside cell
////    [cell.contentView addSubview:label];
//
//    return cell;
//}
//
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    if([bannerDataArr count] == 0 || [rankDataArr count] == 0){
//        [self reqRankDataArr];
//    }
//    if([announceDataArr count] > 0){
//        LMJVerticalScrollText *scrollText = [self.announceHeaderView viewWithTag:100];
//        [scrollText startScrollBottomToTopWithNoSpace];
//    }else{
//        /** 获取公告*/
//        [self reqTopAnnounce];
//    }
//    [logo_lbl setAlpha:0.f];
//
//    [UIView animateWithDuration:2.f
//                           delay:1.5f
//                         options:UIViewAnimationOptionCurveEaseIn
//                               | UIViewAnimationOptionAutoreverse
//                      animations:^{
//                                    [logo_lbl setAlpha:1.f];
//
//
//                                  }
//                      completion:nil];
//    [self startRequestTimer];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    LMJVerticalScrollText *scrollText = [self.announceHeaderView viewWithTag:100];
//    [scrollText stop];
//    [super viewWillDisappear:animated];
//    [logo_lbl setAlpha:0.f];
//
//    [UIView animateWithDuration:2.f
//                           delay:1.5f
//                         options:UIViewAnimationOptionCurveEaseIn
//                               | UIViewAnimationOptionAutoreverse
//                      animations:^{
//                                    [logo_lbl setAlpha:1.f];
//
//
//                                  }
//                      completion:nil];
//    [self closeRequestTimer];
//}
//
//- (void)dealloc
//{
//    [bannerDataArr release];
//    [rankDataArr release];
//    [announceDataArr release];
//    RZReleaseSafe(videoManager);
//    [_bannerUrlsCache release];
//    [_panGesture release];
//    [_coreTableView release];
//    [_tableHeaderView release];
//    [_rankHeaderView release];
//    [_announceHeaderView release];
//    [_coreTableViewLayoutConstraintTop release];
//    [_firstview release];
//    [_thirdv_View release];
//    [_fourth_Globalview release];
//    [_fifth_visaview release];
//    [UICollectionView release];
//    [collection_View release];
//    [_collectionview release];
//    [logo_lbl release];
//    [super dealloc];
//}
//
//- (UIView *)announceHeaderView
//{
//    if(!_announceHeaderView){
//        self.announceHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeAnnounceHeaderView" owner:nil options:nil] lastObject];
//        UIButton *button = (UIButton *)[_announceHeaderView viewWithTag:200];
//        [button addTarget:self action:@selector(allAnnounceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//        LMJVerticalScrollText *scrollText = [_announceHeaderView viewWithTag:100];
//        scrollText.delegate            = self;
//        scrollText.textStayTime        = 2;
//        scrollText.scrollAnimationTime = 1;
//        scrollText.backgroundColor     = [UIColor whiteColor];
//        scrollText.textColor           = RGBA(61, 58, 80, 1.0);
//        scrollText.textFont            = [UIFont boldSystemFontOfSize:14.f];
//        scrollText.textAlignment       = NSTextAlignmentLeft;
//        scrollText.touchEnable         = NO;
//        scrollText.layer.cornerRadius  = 3;
//    }
//    return _announceHeaderView;
//
//}
//
//- (UIView *)tableHeaderView
//{
//    if(!_tableHeaderView){
//        self.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 20)] autorelease];
//        [_tableHeaderView setBackgroundColor:[UIColor whiteColor]];
//        UIImageView *iv = [[[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 35)/2.0f, 5, 35, 5)] autorelease];
//        [iv setBackgroundColor:RGBA(220, 220, 220, 1.0)];
//        [_tableHeaderView addSubview:iv];
//    }
//    return _tableHeaderView;
//}
//
//- (CGFloat)rankNoDataCellHeight
//{
//    if(_rankNoDataCellHeight == 0){
//        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeRankNoDataCell" owner:nil options:nil] lastObject];
//        _rankNoDataCellHeight = cell.frame.size.height;
//    }
//    return _rankNoDataCellHeight;
//}
//
//- (CGFloat)rankCellHeight
//{
//    if(_rankCellHeight == 0){
//        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeRankCell" owner:nil options:nil] lastObject];
//        _rankCellHeight = cell.frame.size.height;
//    }
//    return _rankCellHeight;
//}
//
//- (UIView *)rankHeaderView
//{
//    if(_rankHeaderView == nil){
//        _rankHeaderView = [[UIView alloc] init];
//    }
//    return  _rankHeaderView;
//}
//- (UIView *)rankHeaderView1
//{
//    if(_rankHeaderView == nil){
//        _rankHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"OTCCEll" owner:nil options:nil] lastObject] retain];
//    }
//    return  _rankHeaderView1;
//}
//
//#pragma mark - 按钮点击事件
//- (void)allAnnounceButtonPressed:(UIButton *)sender
//{
//    [self pageToViewControllerForName:@"PCAnnounceController"];
//}
//
//
//#pragma mark - 请求数据
//- (void)reqRankDataArr
//{
//    [[NetWorkManage shareSingleNetWork] reqHomeCropymeData:self finishedCallback:@selector(reqRankDataArrFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
//}
//
//- (void)reqRankDataArrFinished:(NSDictionary *)json
//{
//    [self dismissProgress];
//    if([self checkJsonIsSuccess:json]){
//        reqRankDataFinished = YES;
//        NSDictionary *dataDic = [json objectForKey:@"data"];
//        NSArray *bannerList = [dataDic objectForKey:@"banner"];
//        NSArray *scoreRankList = [dataDic objectForKey:@"scoreRank"];
//        if(!checkIsStringWithAnyText(_bannerUrlsCache)){             //如果缓存不存在，则赋值
//            self.bannerUrlsCache = [CommonUtil jsonToString:bannerList];
//            [bannerDataArr removeAllObjects];
//            NSMutableArray *urlArray = [NSMutableArray array];  //保存banner图片url临时数组
//            for(NSDictionary *bannerDic in bannerList){
//                CropymeBannerEntity *entity = [[[CropymeBannerEntity alloc] initWithJson:bannerDic] autorelease];
//                [bannerDataArr addObject:entity];
//                [urlArray addObject:entity.imageUrl];
//            }
//            self.cycleScrollView.imageURLStringsGroup = urlArray;
//        }else{                                                      //如果缓存存在
//            if(![self.bannerUrlsCache isEqualToString:[CommonUtil jsonToString:bannerList]]){
//                [bannerDataArr removeAllObjects];
//                NSMutableArray *urlArray = [NSMutableArray array];  //保存banner图片url临时数组
//                for(NSDictionary *bannerDic in bannerList){
//                    CropymeBannerEntity *entity = [[[CropymeBannerEntity alloc] initWithJson:bannerDic] autorelease];
//                    [bannerDataArr addObject:entity];
//                    [urlArray addObject:entity.imageUrl];
//                }
//                self.cycleScrollView.imageURLStringsGroup = urlArray;
//            }
//        }
//
//        [rankDataArr removeAllObjects];
//        for(NSDictionary *dic in scoreRankList){
//            InfluencerRankEntity *entity = [[[InfluencerRankEntity alloc] initWithJson:dic] autorelease];
//            [rankDataArr addObject:entity];
//        }
//
//        [_coreTableView reloadData];
//
//    }else{
//        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"Request Data Exceptions")];
//    }
//}
//
//- (void)reqTopAnnounce
//{
//    [[NetWorkManage shareSingleNetWork] reqTopAnnounceData:self finishedCallback:@selector(reqTopAnnounceFinished:) failedCallback:@selector(reqPersonalLineChartData:targetUid:timeType:type:finishedCallback:failedCallback:)];
//}
//
//- (void)reqTopAnnounceFinished:(NSDictionary *)json
//{
//    if([self checkJsonIsSuccess:json]){
//        NSDictionary *dataDic = [json objectForKey:@"data"];
//        NSArray *dataArr = [dataDic objectForKey:@"data"];
//        [announceDataArr removeAllObjects];
//        for(NSDictionary *announceDic in dataArr){
//            PCAnnounceModel *entity = [[[PCAnnounceModel alloc] initWithJson:announceDic] autorelease];
//            [announceDataArr addObject:entity.title];
//        }
//        //滚动数据
//        LMJVerticalScrollText *scrollText = [self.announceHeaderView viewWithTag:100];
//        [scrollText stopToEmpty];
//        scrollText.textDataArr = announceDataArr;
//        [scrollText startScrollBottomToTopWithNoSpace];
//        [_coreTableView reloadData];
//    }
//}
//
//
//#pragma mark - table view delegate and data source
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 2;
//}
////- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
////{
//////    if(section == 0 && [announceDataArr count] > 0){
//////        return self.announceHeaderView;
////    //}
//// if(section == 0){
////        return self.rankHeaderView;
////    }
////    else if(section == 1){
////           return self.rankHeaderView1;
////       }
////    return nil;
////}
//
////- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
////{
//////    if(section == 0 && [announceDataArr count] > 0){
//////        return self.announceHeaderView.frame.size.height;
//////    }else
////        if(section == 0){
////        return self.rankHeaderView.frame.size.height;
////    }
////    if(section == 1){
////    return self.rankHeaderView1.frame.size.height;
////}
////    return 0.0;
////}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    return nil;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return CGFLOAT_MIN;
//}
//
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    if(section == 0){
//        if(reqRankDataFinished){
//            if([rankDataArr count] == 0){          //没数据时候显示另一个cell
//                return 1;
//            }
//            return [rankDataArr count];
//        }
//        else if (section == 1) {
//            return [otcarra count];
//           }
//    }
//
//
//
//    return 0;
//
//}
//
////- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
////{
////    if(indexPath.section == 1){
////        if([rankDataArr count] == 0){
////            return self.rankNoDataCellHeight;
////        }
////        return self.rankCellHeight;
////    }
////    return 0.0;
////}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 0 ){
//    static NSString *rankCellIdentifier = @"PCHomeRankCellIdentifier";
//    //static NSString *rankCellIdentifier1 = @"CircleBlackListCellIdentifier";
//
//
//    if([rankDataArr count] > 0){
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rankCellIdentifier];
//        if(cell == nil){
//            cell = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeRankCell" owner:nil options:nil] lastObject];
//        }
//        InfluencerRankEntity *rankEntity = [rankDataArr objectAtIndex:indexPath.row];
//        RZWebImageView *headLogoIV = (RZWebImageView *)[cell viewWithTag:100];
//        UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
//        UILabel *daysLabel = (UILabel *)[cell viewWithTag:102];
//        UILabel *correctRateLabel = (UILabel *)[cell viewWithTag:103];
//        UILabel *totalProfitLabel = (UILabel *)[cell viewWithTag:104];
//        UILabel *monthProfitLabel = (UILabel *)[cell viewWithTag:105];
//        [correctRateLabel setAlpha:0.f];
//        [totalProfitLabel setAlpha:0.f];
//        [monthProfitLabel setAlpha:0.f];
////        [UIView animateWithDuration:1.0
////                              delay:1
////                            options:UIViewAnimationOptionCurveEaseInOut
////                         animations:^{
////                             //fade in here (changing alpha of UILabel component)
////            correctRateLabel.alpha = 1.0;
////
////                         }
////                         completion:^(BOOL finished){
////                            if(finished){
////                              //start a fade out here when previous animation is finished (changing alpha of UILabel component)
////                                correctRateLabel.alpha = 1.0;
////
////                         }
////        }];
//        [UIView animateWithDuration:2.f
//                               delay:1.5f
//                             options:UIViewAnimationOptionCurveEaseIn
//                                   | UIViewAnimationOptionAutoreverse
//                          animations:^{
//                                        [correctRateLabel setAlpha:1.f];
//            [totalProfitLabel setAlpha:1.f];
//            [monthProfitLabel setAlpha:1.f];
//
//                                      }
//                          completion:nil];
//           // fade in
//
//        [headLogoIV showHeaderImageViewWithUrl:rankEntity.headUrl];
//        nameLabel.text = rankEntity.userName;
//        daysLabel.text = [NSString stringWithFormat:@"%@%@天", NSLocalizedStringForKey(@"Been in for"), rankEntity.days];
//        correctRateLabel.text = [NSString stringWithFormat:@"%@%%",rankEntity.correctRate];
//        totalProfitLabel.text = rankEntity.totalProfit;
//        monthProfitLabel.text = rankEntity.monthProfit;
//        return cell;
//    }
//    }
//    else if (indexPath.section == 1)
//    {
//        static NSString *rankCellIdentifier1 = @"OTCCEll";
//
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rankCellIdentifier1];
//            if(cell == nil){
//                cell = [[[NSBundle mainBundle] loadNibNamed:@"OTCCEll" owner:nil options:nil] lastObject];
//            }
//
//
//        cell.textLabel.text = otcarra[indexPath.row];
//
//
//
//                return cell;
//            }
//
//    }
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    if([rankDataArr count] == 0){
//        return;
//    }
//    if(![ROOTCONTROLLER getLoginStatus]){
//        return;
//    }
//    InfluencerRankEntity *rankEntity = [rankDataArr objectAtIndex:indexPath.row];
//    [self putValueToParamDictionary:ProCoinBaseDict value:rankEntity.userId forKey:@"PersonalMainTargetUid"];
//    [self pageToViewControllerForName:@"PersonalMainController"];
//}
//
//- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
//    CropymeBannerEntity *entity = [bannerDataArr objectAtIndex:index];
//    if(entity.type == 1){           //视频播放
//        [videoManager showVideoViewWithUrlString:entity.videoUrl coverImageUrl:entity.imageUrl];
//    }else{     //站内页面
//        if(checkIsStringWithAnyText(entity.pview)){
//            [self putValueToParamDictionary:MSG_PARAMS value:entity.params forKey:MSG_PARAMS];
//            [self pageToViewControllerForName:entity.pview];
//        }
//    }
//}
//
//#pragma mark - pan gesture
//- (void)dragCoreTableView:(UIGestureRecognizer *)rec
//{
//    if(rec.state == UIGestureRecognizerStateBegan){
//        panGesturePoint = [rec locationInView:self.view];
//    }else if(rec.state == UIGestureRecognizerStateChanged){
//        CGPoint currentPoint = [rec locationInView:self.view];
//        CGFloat distace = panGesturePoint.y - currentPoint.y;
//        if(distace > 0){
//            _coreTableViewLayoutConstraintTop.constant = 235 - distace;
//        }
//    }else if(rec.state == UIGestureRecognizerStateEnded){
//        CGPoint currentPoint = [rec locationInView:self.view];
//        CGFloat distace = panGesturePoint.y - currentPoint.y;
//        if(distace > 0){
//            [self setCoretableViewTopConstantWithAnimation:STATUS_BAR_HEIGHT];
//        }else{
//            [self setCoretableViewTopConstantWithAnimation:defaultCoreTableViewTopConstant];
//        }
//    }
//}
//
//#pragma mark - core table view animation
//- (void)setCoretableViewTopConstantWithAnimation:(CGFloat)constant
//{
//    [UIView animateWithDuration:0.3 animations:^{
//        _coreTableViewLayoutConstraintTop.constant = constant;
//        [self.view layoutIfNeeded];
//    } completion:^(BOOL finished) {
//        if(constant == STATUS_BAR_HEIGHT){
//            _coreTableView.scrollEnabled = YES;
//            [_coreTableView removeGestureRecognizer:_panGesture];
//        }else if(constant == defaultCoreTableViewTopConstant){
//            _coreTableView.scrollEnabled = NO;
//            [_coreTableView addGestureRecognizer:_panGesture];
//        }
//    }];
//}
//
//#pragma mark - scroll view delegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if(scrollView == _coreTableView){
//        CGPoint point = _coreTableView.contentOffset;
//        if(point.y < 0){
//            _coreTableView.scrollEnabled = NO;
//            [self setCoretableViewTopConstantWithAnimation:defaultCoreTableViewTopConstant];
//        }
//    }
//}
//
//- (HomeMainSecondView *)secondSubview{
//    if (!_secondSubview) {
//        _secondSubview = [[HomeMainSecondView alloc] initWithFrame:self.secondview.bounds];
//    }
//    return _secondSubview;
//}
@end
