//
//  TYAccountBaseViewController.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/8/24.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYAccountBaseViewController.h"
#import "JXCategoryView.h"
#import "AccountInfoView.h"
#import "TYAccountBalanceViewController.h"
#import "TYAccountTokenViewController.h"
#import "TYAccountFollowViewController.h"
#import "TYAccountIndexViewController.h"
#import "TYAccountContractViewController.h"
#import "TYAccountCoinViewController.h"

#import "NetWorkManage+Home.h"
#import "NetWorkManage+Personal.h"
#import "CropymeBannerEntity.h"
#import "InfluencerRankEntity.h"
#import "RZWebImageView.h"
#import "CommonUtil.h"
#import "RZSmallVideoManager.h"
#import "RZWebImageView.h"
#import "PCAccountModel.h"

@interface TYAccountBaseViewController ()<JXPagerViewDelegate, JXCategoryViewDelegate, JXPagerMainTableViewGestureDelegate, AccountInfoViewDelegate>

@property (retain, nonatomic) AccountInfoView *infoHeaderView;

@property (nonatomic, strong) JXCategoryTitleView *categoryView;

@property (nonatomic, strong) JXPagerView *pagingView;

@property (nonatomic, strong) NSTimer *requestDataTimer;

@property (nonatomic, strong) TYAccountBalanceViewController *balance;

@property (nonatomic, strong) TYAccountTokenViewController *token;

@property (nonatomic, strong) TYAccountFollowViewController *follow;

@property (nonatomic, strong) TYAccountIndexViewController *index;

@property (nonatomic, strong) TYAccountContractViewController *contract;

@property (nonatomic, strong) TYAccountCoinViewController *coin;

@property (nonatomic, strong) UIView *navView;

@property (nonatomic, strong) NSMutableArray *titlesArray;

@end

@implementation TYAccountBaseViewController

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
    self.pagingView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [self setNav];
    
    //[self getData];
}

- (void)setNav{
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kUINormalNavBarHeight)];
    self.navView = navView;
    navView.alpha = 0;
    [self.view addSubview:navView];
    navView.backgroundColor = UIColor.whiteColor;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = UIColor.blackColor;
    titleLabel.font = UIFontMake(17);
    titleLabel.text = NSLocalizedStringForKey(@"账户");
    [navView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(navView);
        make.top.mas_equalTo(kUIStatusBarHeight);
        make.height.mas_equalTo(44);
    }];
}

- (void)initUI{
    self.view.backgroundColor = UIColorMakeWithHex(@"#E2E6F2");
    NSMutableArray *titlesArray = [NSMutableArray arrayWithArray:
@[NSLocalizedStringForKey(@"余额"),
  NSLocalizedStringForKey(@"币币账户"),
//  NSLocalizedStringForKey(@"跟单账户"),
//  NSLocalizedStringForKey(@"全球期指账户"),
  NSLocalizedStringForKey(@"合约账户")]];
    self.titlesArray = titlesArray;
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.backgroundColor = UIColorClear;
    lineView.indicatorColor = UIColorMakeWithHex(@"#4D4CE6");
    lineView.indicatorHeight = 1;
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
}

- (void)getData{
    if (!ROOTCONTROLLER_USER.userId) {
        return;
    }
    [YYRequestUtility Post:@"home/account.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            //更新顶部总资产数据
            AccountAssetsEntity *assetsEntity = [AccountAssetsEntity yy_modelWithDictionary:responseDict[@"data"]];
            [self.infoHeaderView reloadAccountInfoViewData:assetsEntity];
            
            NSDictionary *balanceDic = [responseDict[@"data"] objectForKey:@"balanceAccount"];
            PCAccountModel *balanceAccountEntity = [PCAccountModel yy_modelWithDictionary:balanceDic];
            [self.balance getData:balanceAccountEntity];
            
            NSDictionary *tokenDic = [responseDict[@"data"] objectForKey:@"tokenAccount"];
            PCAccountModel *tokenModel = [PCAccountModel yy_modelWithDictionary:tokenDic];
            
            [self.token getData:tokenModel];
            
            NSDictionary *followDic = [responseDict[@"data"] objectForKey:@"followAccount"];
            PCAccountModel *followModel = [PCAccountModel yy_modelWithDictionary:followDic];
            
            NSDictionary *followDvDic = [responseDict[@"data"] objectForKey:@"followDv"];
            PCHomeUserFollowOrderInfoModel *dvModel = [PCHomeUserFollowOrderInfoModel yy_modelWithDictionary:followDvDic];
            
            followModel.dvModel = dvModel;
            [self.follow getData:followModel];
            
            NSDictionary *stockDic = [responseDict[@"data"] objectForKey:@"stockAccount"];
            PCAccountModel *stockModel = [PCAccountModel yy_modelWithDictionary:stockDic];
            
            [self.index getData:stockModel];
            
            NSDictionary *digitalDic = [responseDict[@"data"] objectForKey:@"digitalAccount"];
            PCAccountModel *digitalModel = [PCAccountModel yy_modelWithDictionary:digitalDic];
            
            [self.contract getData:digitalModel];
            
            NSDictionary *spotDic = [responseDict[@"data"] objectForKey:@"spotAccount"];
            PCAccountModel *spotModel = [PCAccountModel yy_modelWithDictionary:spotDic];
            
            [self.coin getData:spotModel];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
    }];
}

#pragma mark - 开启关闭定时器
- (void)startRequestTimer
{
    if(self.requestDataTimer && [self.requestDataTimer isValid]){
        [self closeRequestTimer];
    }
//    self.requestDataTimer = [NSTimer timerWithTimeInterval:ROOTCONTROLLER.quotationRefreshTime target:self selector:@selector(getData) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.requestDataTimer forMode:NSRunLoopCommonModes];
    self.requestDataTimer = [NSTimer scheduledTimerWithTimeInterval:ROOTCONTROLLER.quotationRefreshTime repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self getData];
    }];
}

- (void)closeRequestTimer
{
    if(self.requestDataTimer && [self.requestDataTimer isValid]){
        [self.requestDataTimer invalidate];
        self.requestDataTimer = nil;
    }
}

- (UIView *)tableHeaderViewInPagerView:(JXPagerView *)pagerView {
    return self.infoHeaderView;
}

- (NSUInteger)tableHeaderViewHeightInPagerView:(JXPagerView *)pagerView {
    return 165 + kUIStatusBarHeight;
}

- (NSUInteger)heightForPinSectionHeaderInPagerView:(JXPagerView *)pagerView {
    return 50;
}

- (UIView *)viewForPinSectionHeaderInPagerView:(JXPagerView *)pagerView {
    return self.categoryView;
}

- (NSInteger)numberOfListsInPagerView:(JXPagerView *)pagerView {
    return self.titlesArray.count;
}

- (id<JXPagerViewListViewDelegate>)pagerView:(JXPagerView *)pagerView initListAtIndex:(NSInteger)index {
    if (index == 0) {
        TYAccountBalanceViewController *balance = [[TYAccountBalanceViewController alloc] init];
        self.balance = balance;
        return balance;
        //    }else if (index == 1) {
        //        TYAccountTokenViewController *token = [[TYAccountTokenViewController alloc] init];
        //        self.token = token;
        //        return token;
    } else if (index == 1) {
        TYAccountCoinViewController *coin = [[TYAccountCoinViewController alloc] init];
        self.coin = coin;
        return coin;
//    }else if (index == 2) {
//        TYAccountFollowViewController *follow = [[TYAccountFollowViewController alloc] init];
//        self.follow = follow;
//        return follow;
//    }else if (index == 3) {
//        TYAccountIndexViewController *index = [[TYAccountIndexViewController alloc] init];
//        self.index = index;
//        return index;
    }else if (index == 2) {
        TYAccountContractViewController *contract = [[TYAccountContractViewController alloc] init];
        self.contract = contract;
        return contract;
    }
    TYAccountCoinViewController *coin = [[TYAccountCoinViewController alloc] init];
    self.coin = coin;
    return coin;
}
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    //侧滑手势处理
    self.navigationController.interactivePopGestureRecognizer.enabled = (index == 0);
}

- (void)pagerView:(JXPagerView *)pagerView mainTableViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y >= kUINormalNavBarHeight) {
        self.navView.alpha = 1;
    }else{
        self.navView.alpha = scrollView.contentOffset.y / kUINormalNavBarHeight;
    }
}

#pragma mark - account info view delegate
- (void)accountChargeCoinButtonPressed
{
    [self putValueToParamDictionary:ProCoinBaseDict value:@"USDT" forKey:@"ChargeCoinSymbol"];
    [self pageToViewControllerForName:@"ChargeCoinController"];
}

- (void)accountExtractCoinButtonPressed
{
    [self putValueToParamDictionary:ProCoinBaseDict value:@"USDT" forKey:@"ExtractCoinSymbol"];
    [self pageToViewControllerForName:@"ExtractCoinController"];
}

- (void)accountTransferCoinButtonPressed
{
    [self pageToViewControllerForName:@"PCTransferCoinController"];
}

- (void)accountP2pCoinButtonPressed
{
    [self pageToViewControllerForName:@"P2PMainController"];
}

#pragma mark =========================== 懒加载 ===========================
- (JXCategoryTitleView *)categoryView{
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(50, 0, SCREEN_WIDTH - 100, 50)];
        _categoryView.backgroundColor = UIColor.whiteColor;
        _categoryView.delegate = self;
        _categoryView.titleSelectedColor = UIColorMakeWithHex(@"#4D4CE6");
        _categoryView.titleColor = UIColorMakeWithHex(@"#999999");
        _categoryView.titleSelectedFont = UIFontBoldMake(13);
        _categoryView.titleFont = [UIFont systemFontOfSize:13];
        _categoryView.titleColorGradientEnabled = YES;
        _categoryView.averageCellSpacingEnabled = NO;
        _categoryView.titleLabelAnchorPointStyle = JXCategoryTitleLabelAnchorPointStyleBottom;
    }
    return _categoryView;
}

#pragma mark - 懒加载
- (AccountInfoView *)infoHeaderView
{
    if(!_infoHeaderView){
        _infoHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"AccountInfoView" owner:nil options:nil] lastObject] retain];
        _infoHeaderView.delegate = self;
        _infoHeaderView.backgroundColor = UIColorMakeWithHex(@"#4D4CE6");
    }
    return _infoHeaderView;
}

#pragma mark - JXPagerMainTableViewGestureDelegate

- (BOOL)mainTableViewGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //禁止categoryView左右滑动的时候，上下和左右都可以滚动
    if (otherGestureRecognizer == self.categoryView.collectionView.panGestureRecognizer) {
        return NO;
    }
    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}
@end
