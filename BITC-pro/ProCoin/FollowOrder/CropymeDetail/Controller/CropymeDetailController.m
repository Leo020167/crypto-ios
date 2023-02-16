//
//  CropymeDetailController.m
//  Cropyme
//
//  Created by Hay on 2019/8/8.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CropymeDetailController.h"
#import <YNPageViewController.h>
#import "NetWorkManage+FollowOrder.h"
#import "CDBaseInfoEntity.h"
#import "CDHoldCostController.h"
#import "CDFollowOrderBalanceController.h"
#import "CDHoldCoinMarketController.h"

@interface CropymeDetailController ()<YNPageViewControllerDelegate,YNPageViewControllerDataSource>
{
    YNPageViewController *mainController;
    CDHoldCostController *holdCostVC;
    CDFollowOrderBalanceController *followOrderBalanceVC;
    CDHoldCoinMarketController *holdCoinMarketVC;
}

/** 懒加载*/
@property (retain, nonatomic) UIView *infoHeaderView;
@property (retain, nonatomic) NSArray *segmentArrayVC;              //分段控制器
@property (retain, nonatomic) NSArray *segmentArrayTitle;           //分段标题

/** 数据变量*/
@property (retain, nonatomic) CDBaseInfoEntity *infoEntity;     //基本信息变量


@end

@implementation CropymeDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self showProgressDefaultText];
    [self reqFollowOrderUsersBaseInfo];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if(mainController == nil){
        [self setupMainController];
    }
}


- (void)dealloc
{
    [mainController release];
    [holdCostVC release];
    [followOrderBalanceVC release];
    [holdCoinMarketVC release];
    [_infoHeaderView release];
    [_segmentArrayVC release];
    [_segmentArrayTitle release];
    [_infoEntity release];
    [super dealloc];
}

#pragma mark - 懒加载
- (UIView *)infoHeaderView
{
    if(!_infoHeaderView){
        _infoHeaderView = (UIView *)[[[[NSBundle mainBundle] loadNibNamed:@"CDInfoHeaderView" owner:nil options:nil] lastObject] retain];
        
    }
    return _infoHeaderView;
}

- (NSArray *)segmentArrayVC
{
    if(!_segmentArrayVC){
        holdCostVC = [[CDHoldCostController alloc] init];
        followOrderBalanceVC = [[CDFollowOrderBalanceController alloc] init];
        holdCoinMarketVC = [[CDHoldCoinMarketController alloc] init];
        _segmentArrayVC = [[NSArray arrayWithObjects:holdCostVC,followOrderBalanceVC,holdCoinMarketVC,nil] retain];
    }
    return _segmentArrayVC;
}

- (NSArray *)segmentArrayTitle
{
    if(!_segmentArrayTitle){
        _segmentArrayTitle = [[NSArray arrayWithObjects:NSLocalizedStringForKey(@"持仓成本"),NSLocalizedStringForKey(@"跟单资金"),NSLocalizedStringForKey(@"持币市值"),nil] retain];
    }
    return _segmentArrayTitle;
}

#pragma mark - 按钮点击事件
- (IBAction)backButonPressed:(id)sender
{
    [self goBack];
}

#pragma mark - 设置main Controller
- (void)setupMainController
{
    
    YNPageConfigration *configration = [YNPageConfigration defaultConfig];
    configration.pageStyle = YNPageStyleSuspensionTopPause;
    configration.showNavigation = YES;
    configration.showTabbar = NO;
    configration.scrollMenu = YES;
    configration.aligmentModeCenter = NO;
    configration.lineWidthEqualFontWidth = YES;
    configration.lineColor = RGBA(255, 143, 1, 1.0);
    configration.bottomLineHeight = 1;
    configration.headerViewCouldScale = YES;
    configration.headerViewScaleMode = YNPageHeaderViewScaleModeTop;
    configration.itemFont = [UIFont systemFontOfSize:14.0f];
    configration.selectedItemFont = [UIFont systemFontOfSize:16.0f];
    configration.itemMargin = 30;
    configration.cutOutHeight = IPHONEX_BOTTOM_HEIGHT;
    //    configration.itemFont = [UIFont systemFontOfSize:14];
    //    configration.selectedItemFont = [UIFont systemFontOfSize:16];
    configration.normalItemColor = RGBA(61, 58, 80, 0.4);
    configration.selectedItemColor = RGBA(255, 143, 1, 1.0);
    
    //    configration.lineLeftAndRightMargin = 36;
    
    mainController = [[YNPageViewController pageViewControllerWithControllers:self.segmentArrayVC
                                                                       titles:self.segmentArrayTitle
                                                                       config:configration] retain];
    
    mainController.delegate = self;
    mainController.dataSource = self;
    
    mainController.headerView = self.infoHeaderView;
    mainController.view.clipsToBounds = YES;
    
    
    mainController.view.frame = CGRectMake(0.0, NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT);
    [mainController addSelfToParentViewController:self];
    [self.view sendSubviewToBack:mainController.view];
}

#pragma mark - YNPageViewControllerDataSource
- (UIScrollView *)pageViewController:(YNPageViewController *)pageViewController pageForIndex:(NSInteger)index
{
    id baseVC = pageViewController.controllersM[index];
    if([baseVC isKindOfClass:[CDHoldCostController class]]){
        CDHoldCostController *vc = baseVC;
        return [vc holdCostTableView];
    }else if([baseVC isKindOfClass:[CDFollowOrderBalanceController class]]){
        CDFollowOrderBalanceController *vc = baseVC;
        return [vc balanceTableView];
    }else if([baseVC isKindOfClass:[CDHoldCoinMarketController class]]){
        CDHoldCoinMarketController *vc = baseVC;
        return [vc marketTableView];
    }
    return nil;
}

#pragma mark - YNPageViewControllerDelegate
- (void)pageViewController:(YNPageViewController *)pageViewController contentOffsetY:(CGFloat)contentOffset progress:(CGFloat)progress
{
}


#pragma mark - 请求数据
- (void)reqFollowOrderUsersBaseInfo
{
    [[NetWorkManage shareSingleNetWork] reqFollowOrderUsersBaseInfo:self finishedCallback:@selector(reqFollowOrderUsersBaseInfoFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqFollowOrderUsersBaseInfoFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        self.infoEntity = [[[CDBaseInfoEntity alloc] initWithJson:dataDic] autorelease];
        
        [self updateInfoHeaderView];
    }
}


#pragma mark - 更新数据
- (void)updateInfoHeaderView
{
    UILabel *totalFollowBalanceLabel = (UILabel *)[self.infoHeaderView viewWithTag:100];
    UILabel *totalProfitLabel = (UILabel *)[self.infoHeaderView viewWithTag:101];
    UILabel *predictProfitLabel = (UILabel *)[self.infoHeaderView viewWithTag:102];
    
    totalFollowBalanceLabel.text = _infoEntity.totalFollowBalance;
    totalProfitLabel.text = _infoEntity.totalProfitShare;
    predictProfitLabel.text = _infoEntity.predictProfitShare;
}


@end
