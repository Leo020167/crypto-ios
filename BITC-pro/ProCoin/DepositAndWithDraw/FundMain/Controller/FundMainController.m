//
//  FundMainController.m
//  Cropyme
//
//  Created by Hay on 2019/5/24.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FundMainController.h"
#import "NetWorkManage+Trade.h"
#import "RZRefreshTableView.h"
#import "CashTradeOrderEntity.h"
#import "CommonUtil.h"
#import "VeDateUtil.h"
#import "TradeConfigInfoEntity.h"
#import "TradeUtil.h"
#import <YNPageViewController.h>
#import "FundMainUndoneController.h"
#import "FundMainHistoryController.h"
#import "TJRBaseTitleView.h"
#import "LewPopupViewAnimationSpring.h"

@interface FundMainController ()<YNPageViewControllerDelegate,YNPageViewControllerDataSource,FundMainUndoneControllerDelegate,FundMainHistoryControllerDelegate>
{
    BOOL isLightStype;          //statue bar 是否亮风格
    YNPageViewController *mainController;
    FundMainUndoneController *undoneController;
    FundMainHistoryController *historyController;
    
}


@property (retain, nonatomic) NSArray *segmentArrayVC;              //分段控制器
@property (retain, nonatomic) NSArray *segmentArrayTitle;           //分段标题

@property (retain, nonatomic) UIView *infoHeaderView;                  //信息headerView
@property (retain, nonatomic) UIView *optionsHeaderView;                //选项headerView


@property (retain, nonatomic) IBOutlet TJRBaseTitleView *navigationBar;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (retain, nonatomic) IBOutlet UIButton *usdtIntroButton;

@property (retain, nonatomic) IBOutlet UIView *noticeView;      //通知view
@property (retain, nonatomic) IBOutlet UILabel *noticeLabel;    //通知文本
@end

@implementation FundMainController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return isLightStype ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isLightStype = YES;
    [_navigationBar setBackgroundColor:[UIColor clearColor]];
    [_backButton setImage:[UIImage imageNamed:@"btn_back_white"] forState:UIControlStateNormal];
    _navigationTitleLabel.textColor = [UIColor whiteColor];
    [_usdtIntroButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];


    [self showProgressDefaultText];
    [self reqConfigInfo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if([self getValueFromModelDictionary:FundExchangeDic forKey:@"FundMainNeedUpdate"]){
        [undoneController reqCashCoinTransactionFirstPageUndoneRecord];
        [historyController reqCashCoinTransactionFirstPageHistoryRecord];
        [self removeParamFromModelDictionary:FundExchangeDic forKey:@"FundMainNeedUpdate"];
    }
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
    [undoneController release];
    [historyController release];
    [_segmentArrayVC release];
    [_segmentArrayTitle release];
    [_infoHeaderView release];
    [_optionsHeaderView release];
    [_navigationBar release];
    [_backButton release];
    [_usdtIntroButton release];
    [_navigationTitleLabel release];
    [_noticeView release];
    [_noticeLabel release];
    [super dealloc];
}

#pragma mark - 懒加载

- (NSArray *)segmentArrayVC
{
    if(!_segmentArrayVC){
        
        undoneController = [[FundMainUndoneController alloc] init];
        historyController = [[FundMainHistoryController alloc] init];

        undoneController.delegate = self;
        historyController.delegate = self;
        _segmentArrayVC = [[NSArray arrayWithObjects:undoneController,historyController,nil] retain];
    }
    return _segmentArrayVC;
}

- (NSArray *)segmentArrayTitle
{
    if(!_segmentArrayTitle){
        _segmentArrayTitle = [[NSArray arrayWithObjects:NSLocalizedStringForKey(@"未完成"),NSLocalizedStringForKey(@"历史记录"), nil] retain];
    }
    return _segmentArrayTitle;
}


- (UIView *)infoHeaderView
{
    if(!_infoHeaderView){
        _infoHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"FundMainHeaderView" owner:nil options:nil] lastObject] retain];
        UIButton *depositButton = (UIButton *)[_infoHeaderView viewWithTag:300];
        UIButton *extractCoinButton = (UIButton *)[_infoHeaderView viewWithTag:301];
        UIButton *purchaseButton = (UIButton *)[_infoHeaderView viewWithTag:302];
        [depositButton addTarget:self action:@selector(depositButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [extractCoinButton addTarget:self action:@selector(extractCoinButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [purchaseButton addTarget:self action:@selector(purchaseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _infoHeaderView;
}


#pragma mark - 设置main Controller
- (void)setupMainController
{
    UIButton *button_1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_1 setFrame:CGRectMake(0.0, 0.0, 0, 44)];
    UIButton *button_2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_2 setFrame:CGRectMake(0.0, 0.0, 0, 44)];
    
    YNPageConfigration *configration = [YNPageConfigration defaultConfig];
    configration.pageStyle = YNPageStyleSuspensionCenter;
    configration.headerViewCouldScale = YES;
    configration.headerViewScaleMode = YNPageHeaderViewScaleModeTop;
    configration.showTabbar = NO;
    configration.showNavigation = NO;
    configration.scrollMenu = YES;
    configration.aligmentModeCenter = NO;
    configration.lineWidthEqualFontWidth = true;
    configration.showBottomLine = NO;
    configration.lineColor = RGBA(97, 117, 174, 1.0);
    configration.itemFont = [UIFont systemFontOfSize:14.0f];
    configration.selectedItemFont = [UIFont systemFontOfSize:18.0f];
    /// 设置悬浮停顿偏移量
    configration.suspenOffsetY = NAVIGATION_BAR_HEIGHT ;
    //    configration.itemFont = [UIFont systemFontOfSize:14];
    //    configration.selectedItemFont = [UIFont systemFontOfSize:16];
    configration.normalItemColor = RGBA(97, 117, 174, 0.4);
    configration.selectedItemColor = RGBA(29, 49, 85, 1.0);
    
    //    configration.lineLeftAndRightMargin = 36;
    
    mainController = [[YNPageViewController pageViewControllerWithControllers:self.segmentArrayVC
                                                                       titles:self.segmentArrayTitle
                                                                       config:configration] retain];
   
    mainController.delegate = self;
    mainController.dataSource = self;
    self.infoHeaderView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, self.infoHeaderView.frame.size.height + NAVIGATION_BAR_HEIGHT);
    mainController.headerView = self.infoHeaderView;
    mainController.view.clipsToBounds = YES;

    [mainController addSelfToParentViewController:self];

    

    mainController.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view sendSubviewToBack:mainController.view];
    
    
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}


/** 充币点击事件*/
- (void)depositButtonPressed:(id)sender
{
    [self putValueToParamDictionary:ProCoinBaseDict value:@"USDT" forKey:@"ChargeCoinSymbol"];
    [self pageToViewControllerForName:@"ChargeCoinController"];
}

/** 提币事件*/
- (void)extractCoinButtonPressed:(id)sender
{
    [self putValueToParamDictionary:ProCoinBaseDict value:@"USDT" forKey:@"ExtractCoinSymbol"];
    [self pageToViewControllerForName:@"ExtractCoinController"];
}

/** 法币购买事件*/
- (void)purchaseButtonPressed:(id)sender
{
    [self pageToViewControllerForName:@"PurchaseCoinController"];
}

/** USDT说明按钮点击事件*/
- (IBAction)usdtIntroButtonPressed:(id)sender
{
    
    TYWebViewController *web = [[TYWebViewController alloc] init];
    web.url = FundUSDTIntroductionWebURL;
    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
}


- (IBAction)iKnowNoticeButtonPressed:(id)sender
{
    [self lew_dismissPopupView];
}

#pragma mark - 请求数据
- (void)reqConfigInfo
{
    [[NetWorkManage shareSingleNetWork] reqDepositWithdrawHomeConfig:self finishedCallback:@selector(reqConfigInfoFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqConfigInfoFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        TradeConfigInfoEntity *infoEntity = [[[TradeConfigInfoEntity alloc] initWithJson:dataDic] autorelease];
        [self updateMainHeaderViewData:infoEntity];
        if(checkIsStringWithAnyText(infoEntity.noticeMsg)){
            CGRect frame = self.noticeView.frame;
            frame.size.width = SCREEN_WIDTH - 40;
            [self.noticeView setFrame:frame];
            self.noticeLabel.text = infoEntity.noticeMsg;

            [self lew_presentPopupView:self.noticeView animation:[[LewPopupViewAnimationSpring alloc] autorelease]];
        }
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}


#pragma mark - 更新FundMainHeaderView数据
- (void)updateMainHeaderViewData:(TradeConfigInfoEntity *)infoEntity
{
    UILabel *tolUsdtLabel = (UILabel *)[self.infoHeaderView viewWithTag:100];
    UILabel *tolCashLabel = (UILabel *)[self.infoHeaderView viewWithTag:101];
    UILabel *holdUsdtLabel = (UILabel *)[self.infoHeaderView viewWithTag:102];
    UILabel *frozenUsdtLabel = (UILabel *)[self.infoHeaderView viewWithTag:103];
    tolUsdtLabel.text = infoEntity.tolUsdt;
    tolCashLabel.text = [NSString stringWithFormat:@"≈%@",[TradeUtil stringByAppendingRMBSymbolString:infoEntity.tolCash]];
    holdUsdtLabel.text = infoEntity.holdUsdt;
    frozenUsdtLabel.text = infoEntity.frozenUsdt;
    
}

#pragma mark - YNPageViewControllerDataSource
- (UIScrollView *)pageViewController:(YNPageViewController *)pageViewController pageForIndex:(NSInteger)index
{
    id baseVC = pageViewController.controllersM[index];
    if([baseVC isKindOfClass:[FundMainUndoneController class]]){
        FundMainUndoneController *vc = baseVC;
        return [vc undoneTableView];
    }else if([baseVC isKindOfClass:[FundMainHistoryController class]]){
        FundMainHistoryController *vc = baseVC;
        return [vc historyTableView];
    }
    
    return nil;
}

#pragma mark - YNPageViewControllerDelegate
- (void)pageViewController:(YNPageViewController *)pageViewController contentOffsetY:(CGFloat)contentOffset progress:(CGFloat)progress
{
    /** 根据拉的位置，是否显示navigationBar，并且判断是否更改statueBar的颜色*/
    if(progress >= 0.7){
        if(isLightStype){
            isLightStype = NO;
            [self setNeedsStatusBarAppearanceUpdate];
            
            [_navigationBar setBackgroundColor:[UIColor whiteColor]];
            [_backButton setImage:[UIImage imageNamed:@"btn_back_black"] forState:UIControlStateNormal];
            _navigationTitleLabel.textColor = RGBA(61, 58, 80, 1.0);
            [_usdtIntroButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
        }
    }else{
        if(!isLightStype){
            isLightStype = YES;
            [self setNeedsStatusBarAppearanceUpdate];
            
            [_navigationBar setBackgroundColor:[UIColor clearColor]];
            [_backButton setImage:[UIImage imageNamed:@"btn_back_white"] forState:UIControlStateNormal];
            _navigationTitleLabel.textColor = [UIColor whiteColor];
            [_usdtIntroButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}


#pragma mark - FundMainUndoneController delegate
- (void)undoneControllerTableViewDidSelectedWithEntity:(CashTradeOrderEntity *)entity
{
    if([entity.buySell isEqualToString:@"1"]){
        [self putValueToParamDictionary:FundExchangeDic value:entity.orderCashId forKey:@"FundPayDetailOrderCashId"];
        [self pageToViewControllerForName:@"FundPayDetailController"];
    }else if([entity.buySell isEqualToString:@"-1"]){
        [self putValueToParamDictionary:FundExchangeDic value:entity.orderCashId forKey:@"FundWithdrawDetailCashId"];
        [self pageToViewControllerForName:@"FundWithdrawDetailController"];
    }
}

#pragma mark - FundMainHistoryController delegate
- (void)historyControllerTableViewDidSelectedWithEntity:(CashTradeOrderEntity *)entity
{
    if([entity.buySell isEqualToString:@"1"]){
        [self putValueToParamDictionary:FundExchangeDic value:entity.orderCashId forKey:@"FundPayDetailOrderCashId"];
        [self pageToViewControllerForName:@"FundPayDetailController"];
    }else if([entity.buySell isEqualToString:@"-1"]){
        [self putValueToParamDictionary:FundExchangeDic value:entity.orderCashId forKey:@"FundWithdrawDetailCashId"];
        [self pageToViewControllerForName:@"FundWithdrawDetailController"];
    }
}


@end
