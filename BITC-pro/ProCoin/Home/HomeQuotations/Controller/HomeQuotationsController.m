//
//  HomeQuotationsController.m
//  Cropyme
//
//  Created by Hay on 2019/5/7.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "HomeQuotationsController.h"
#import "NetWorkManage+Home.h"
#import "TradeUtil.h"
#import "QuotationCoinBaseEntity.h"
#import "QuotationSocket.h"
#import "NetWorkManage+Quotation.h"
#import "MHSortButton.h"
#import "RZRefreshTableView.h"
#import "VeDateUtil.h"
#import "CoinSubscribeEntity.h"
#import "NetWorkManage+KBT.h"
#import "CommonUtil.h"
#import "PersonSubInfoEntity.h"
#import "HQCustomSymbolView.h"
#import "HQStockFuturesSymbolView.h"
#import "HomeQuotationsSortHeaderView.h"

#define CoinSubRoundKey         @"CoinSubRoundKey"              //认购货币的编号

@interface HomeQuotationsController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,HQCustomSybolViewDelegate,HomeQuotationSortHeaderViewDelegate,HQStockFuturesSymbolViewDelegate>
{
    NSMutableArray *coinsDataArr;               //数字货币行情数据
    NSMutableArray *customCoinsDataArr;         //自选行情数据
    NSMutableArray *stockFuturesDataArr;        //股指期货行情数据
    NSMutableArray *hsDataArr;
    NSMutableArray *hkDataArr;
    NSTimer *requestDataTimer;
}

@property (copy, nonatomic) NSString *customSortField;                      //自选排序种类
@property (copy, nonatomic) NSString *customSortType;                       //自选排序类型
@property (copy, nonatomic) NSString *leverageSortFiled;                    //杠杆排序种类
@property (copy, nonatomic) NSString *leverageSortType;                     //杠杆排序类型
@property (copy, nonatomic) NSString *byySortField;                         //BYY排序种类
@property (copy, nonatomic) NSString *byySortType;                          //BYY排序类型
@property (copy, nonatomic) NSString *hbSortField;                          //火币排序种类
@property (copy, nonatomic) NSString *hbSortType;                           //火币排序类型
@property (copy, nonatomic) NSString *hsSortField;
@property (copy, nonatomic) NSString *hsSortType;
@property (copy, nonatomic) NSString *hkSortField;
@property (copy, nonatomic) NSString *hkSortType;
@property (copy, nonatomic) NSString *reqSocketTab;                         //请求socket参数tab
@property (copy, nonatomic) NSString *topPrice;
@property (copy, nonatomic) NSString *topRate;
@property (copy, nonatomic) NSString *topSymbol;
@property (copy, nonatomic) NSString *myCustomSymbols;                   //我的自选股字段



/** 懒加载*/
@property (retain, nonatomic) HQCustomSymbolView *customSymbolDataView;                   //自选数据view
@property (retain, nonatomic) HQStockFuturesSymbolView *stockFuturesSymbolDataView;       //股指期货数据view
@property (retain, nonatomic) HomeQuotationsSortHeaderView *quotationsHeaderView;
@property (retain, nonatomic) HomeQuotationsSortHeaderView *quotationsHeaderViewHS;
@property (retain, nonatomic) HomeQuotationsSortHeaderView *quotationsHeaderViewHK;
@property (assign, nonatomic) CGFloat quotationsCoinCellHeight;


@property (retain, nonatomic) IBOutlet UIView *optionsView;                 //选项view
@property (retain, nonatomic) IBOutlet UIButton *customButton;              //自选按钮
@property (retain, nonatomic) IBOutlet UIButton *stockFuturesButton;        //股指期货按钮

/// 数字货币按钮
@property (retain, nonatomic) IBOutlet UIButton *hbButton;

/// 外汇
@property (retain, nonatomic) IBOutlet UIButton *hsButton;
@property (retain, nonatomic) IBOutlet UIButton *hkButton;

@property (retain, nonatomic) IBOutlet UIScrollView *coreScrollView;
@property (retain, nonatomic) IBOutlet UIView *customView;                  //自选股view
@property (retain, nonatomic) IBOutlet UIView *stockFuturesView;            //股指期货view
@property (retain, nonatomic) IBOutlet UITableView *dataTableView;
@property (retain, nonatomic) IBOutlet UITableView *dataHSTableView;
@property (retain, nonatomic) IBOutlet UITableView *dataHKTableView;




@end

@implementation HomeQuotationsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    /** 初始化按钮状态 */
    
    
    [_customButton setTitleColor:RGBA(61, 58, 80, 0.4) forState:UIControlStateNormal];
    [_customButton setTitleColor:UIColorMakeWithHex(@"#333333") forState:UIControlStateSelected];
    _customButton.selected = YES;
    
    [_hsButton setTitleColor:RGBA(61, 58, 80, 0.4) forState:UIControlStateNormal];
    [_hsButton setTitleColor:UIColorMakeWithHex(@"#333333") forState:UIControlStateSelected];
    [_hsButton setBackgroundColor:[UIColor whiteColor]];
    
    [_hkButton setTitleColor:RGBA(61, 58, 80, 0.4) forState:UIControlStateNormal];
    [_hkButton setTitleColor:UIColorMakeWithHex(@"#333333") forState:UIControlStateSelected];
    [_hkButton setBackgroundColor:[UIColor whiteColor]];
    
    [_stockFuturesButton setTitleColor:RGBA(61, 58, 80, 0.4) forState:UIControlStateNormal];
    [_stockFuturesButton setTitleColor:UIColorMakeWithHex(@"#333333") forState:UIControlStateSelected];
    [_stockFuturesButton setBackgroundColor:[UIColor whiteColor]];
    
    [_hbButton setTitleColor:RGBA(61, 58, 80, 0.4) forState:UIControlStateNormal];
    [_hbButton setTitleColor:UIColorMakeWithHex(@"#333333") forState:UIControlStateSelected];
    [_hbButton setBackgroundColor:[UIColor whiteColor]];
    
    self.reqSocketTab = HomeQuotationsTabCustom;               //默认请求的是自选的行情
    self.customSortField = @"";
    self.customSortType = @"";
    self.leverageSortFiled = @"";
    self.leverageSortType = @"";
    self.byySortField = @"";
    self.byySortType = @"";
    self.hbSortField = @"";
    self.hbSortType = @"";
    self.hsSortField = @"";
    self.hsSortType = @"";
    self.hkSortField = @"";
    self.hkSortType = @"";
    self.myCustomSymbols = @"";
    self.quotationsHeaderView = nil;
    _dataTableView.backgroundColor = [UIColor whiteColor];
    _dataTableView.delegate = self;
    _dataTableView.dataSource = self;
    _dataTableView.tableHeaderView = self.quotationsHeaderView;
    _dataHSTableView.tableHeaderView = self.quotationsHeaderViewHS;
    _dataHKTableView.tableHeaderView = self.quotationsHeaderViewHK;
    //reloadData 视图漂移或者闪动解决方法
    _dataTableView.estimatedRowHeight = 0;
    _dataTableView.estimatedSectionHeaderHeight = 0;
    _dataTableView.estimatedSectionFooterHeight = 0;

    _coreScrollView.delegate = self;
    self.quotationsCoinCellHeight = 0.0;
    coinsDataArr = [[NSMutableArray alloc] init];
    customCoinsDataArr = [[NSMutableArray alloc] init];
    stockFuturesDataArr = [[NSMutableArray alloc] init];
    hsDataArr = [[NSMutableArray alloc] init];
    hkDataArr = [[NSMutableArray alloc] init];
    
    [_customView addSubview:self.customSymbolDataView];                 //添加自选页面
    [_stockFuturesView addSubview:self.stockFuturesSymbolDataView];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!checkIsStringWithAnyText(ROOTCONTROLLER_USER.userId)){          //未登陆情况下显示的数据
        [_customSymbolDataView customSymbolViewDidNotLoginData];
    }
    
    //启动socket连接
    [[QuotationSocket shareQuotationSocket] registerNotificationOfDidConnectedToServer:self selector:@selector(socketDidConnectedToServer)];
    [[QuotationSocket shareQuotationSocket] registerNotificationOfDisconnectedToServer:self selector:@selector(socketDidDisconnected)];
    
    [self reqMarketQuotationData:HomeQuotationsTabCustom];
    [self reqMarketQuotationData:HomeQuotationsTabSotckFutures];
    [self reqMarketQuotationData:HomeQuotationsTabHB];
    [self reqMarketQuotationData:HomeQuotationsTabHS];
    [self reqMarketQuotationData:HomeQuotationsTabHK];
    [self startRequestTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[QuotationSocket shareQuotationSocket] cancelAllNotifcationOfSocket:self];
    [self closeRequestTimer];
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}



- (void)dealloc
{
    [hkDataArr release];
    [hsDataArr release];
    [coinsDataArr release];
    [customCoinsDataArr release];
    [stockFuturesDataArr release];
    [_customSortField release];
    [_customSortType release];
    [_leverageSortFiled release];
    [_leverageSortType release];
    [_byySortField release];
    [_byySortType release];
    [_hbSortField release];
    [_hbSortType release];
    [_hsSortType release];
    [_hsSortField release];
    [_hkSortType release];
    [_hkSortField release];
    [_reqSocketTab release];
    [_topPrice release];
    [_topRate release];
    [_topSymbol release];
    [_myCustomSymbols release];
    [_customSymbolDataView release];
    [_stockFuturesSymbolDataView release];
    [_quotationsHeaderView release];
    [_quotationsHeaderViewHK release];
    [_quotationsHeaderViewHS release];
    [_dataTableView release];
    [_coreScrollView release];
    [_customButton release];
    [_hbButton release];
    [_customView release];
    [_optionsView release];
    [_stockFuturesButton release];
    [_stockFuturesView release];
    [_hsButton release];
    [_hkButton release];
    [_dataHSTableView release];
    [_dataHKTableView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (HQCustomSymbolView *)customSymbolDataView
{
    if(!_customSymbolDataView){
        _customSymbolDataView  = [[HQCustomSymbolView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - TAB_BAR_HEIGHT - _optionsView.frame.size.height)];
        _customSymbolDataView.delegate = self;
    }
    return _customSymbolDataView;
}

- (HQStockFuturesSymbolView *)stockFuturesSymbolDataView
{
    if(!_stockFuturesSymbolDataView){
        _stockFuturesSymbolDataView = [[HQStockFuturesSymbolView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - TAB_BAR_HEIGHT - _optionsView.frame.size.height)];
        _stockFuturesSymbolDataView.delegate = self;
    }
    return _stockFuturesSymbolDataView;
}


- (HomeQuotationsSortHeaderView *)quotationsHeaderView
{
    if(!_quotationsHeaderView){
        _quotationsHeaderView = (HomeQuotationsSortHeaderView *)[[[[NSBundle mainBundle] loadNibNamed:@"HomeQuotationsSortHeaderView" owner:nil options:nil] lastObject] retain];
        _quotationsHeaderView.delegate = self;
    }
    return _quotationsHeaderView;
}

- (HomeQuotationsSortHeaderView *)quotationsHeaderViewHS
{
    if(!_quotationsHeaderViewHS){
        _quotationsHeaderViewHS = (HomeQuotationsSortHeaderView *)[[[[NSBundle mainBundle] loadNibNamed:@"HomeQuotationsSortHeaderView" owner:nil options:nil] lastObject] retain];
        _quotationsHeaderViewHS.delegate = self;
    }
    return _quotationsHeaderViewHS;
}

- (HomeQuotationsSortHeaderView *)quotationsHeaderViewHK
{
    if(!_quotationsHeaderViewHK){
        _quotationsHeaderViewHK = (HomeQuotationsSortHeaderView *)[[[[NSBundle mainBundle] loadNibNamed:@"HomeQuotationsSortHeaderView" owner:nil options:nil] lastObject] retain];
        _quotationsHeaderViewHK.delegate = self;
    }
    return _quotationsHeaderViewHK;
}


- (CGFloat)quotationsCoinCellHeight
{
    if(_quotationsCoinCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeQuotationsCoinCell" owner:nil options:nil] lastObject];
        _quotationsCoinCellHeight = cell.frame.size.height;
    }
    return _quotationsCoinCellHeight;
}

#pragma mark - 按钮点击事件
/** 功能选项按钮点击事件*/
- (IBAction)functionOptionsButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton.isSelected){
        return;
    }
    _customButton.selected = NO;
    _stockFuturesButton.selected = NO;
    _hbButton.selected = NO;
    _hsButton.selected = NO;
    _hkButton.selected = NO;
    
    targetButton.selected = YES;
    if(targetButton == _customButton){
        [_coreScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
        self.reqSocketTab = HomeQuotationsTabCustom;   //请求的是自选行情
    }else if(targetButton == _hbButton){
        [_coreScrollView setContentOffset:CGPointMake(_coreScrollView.frame.size.width * 4 , 0.0) animated:YES];
        self.reqSocketTab = HomeQuotationsTabHB;  //请求的是数字货币行情
    }else if(targetButton == _stockFuturesButton){
        [_coreScrollView setContentOffset:CGPointMake(_coreScrollView.frame.size.width * 3, 0.0) animated:YES];
        self.reqSocketTab = HomeQuotationsTabSotckFutures;  //请求的是股指期货行情
    }else if(targetButton == _hsButton){
        [_coreScrollView setContentOffset:CGPointMake(_coreScrollView.frame.size.width * 1, 0.0) animated:YES];
        self.reqSocketTab = HomeQuotationsTabHS;  //请求的是沪深行情
    }else if(targetButton == _hkButton){
        [_coreScrollView setContentOffset:CGPointMake(_coreScrollView.frame.size.width * 2, 0.0) animated:YES];
        self.reqSocketTab = HomeQuotationsTabHK;  //请求的是港股行情
    }
    [self reqMarketQuotationData:_reqSocketTab];

}


/** 编辑自选股*/
- (IBAction)editFollowCoinButtonPressed:(id)sender
{
    if(!ROOTCONTROLLER.getLoginStatus)
        return;
    
    [self pageToViewControllerForName:@"EditCustomQuotationsController"];
}


- (IBAction)searchCoinButtonPressed:(id)sender
{
    [self pageToViewControllerForName:@"SearchCoinController"];
}



#pragma mark - socket

/** 连接上服务器*/
- (void)socketDidConnectedToServer
{
    [self startRequestTimer];
}

/** 与服务器断开*/
- (void)socketDidDisconnected
{
    [self dismissProgress];
    [self closeRequestTimer];
    
}

#pragma mark - 请求数据
- (void)reqMarketQuotationData:(NSString *)tab
{
    if([tab isEqualToString:HomeQuotationsTabCustom]){             //自选数据
        [[NetWorkManage shareSingleNetWork] reqMarketQuotationData:self tab:tab sortField:_customSortField sortType:_customSortType finishedCallback:@selector(reqMarketQuotationDataFinished:) failedCallback:@selector(reqMarketQuotationDataFailed:)];
    }else if([tab isEqualToString:HomeQuotationsTabSotckFutures]){
        [[NetWorkManage shareSingleNetWork] reqMarketQuotationData:self tab:tab sortField:_leverageSortFiled sortType:_leverageSortType finishedCallback:@selector(reqMarketQuotationDataFinished:) failedCallback:@selector(reqMarketQuotationDataFailed:)];
    }else if([tab isEqualToString:HomeQuotationsTabHB]){           //数字货币数据
        [[NetWorkManage shareSingleNetWork] reqMarketQuotationData:self tab:tab sortField:_hbSortField sortType:_hbSortType finishedCallback:@selector(reqMarketQuotationDataFinished:) failedCallback:@selector(reqMarketQuotationDataFailed:)];
    }else if([tab isEqualToString:HomeQuotationsTabHS]){
        [[NetWorkManage shareSingleNetWork] reqMarketQuotationData:self tab:tab sortField:_hsSortField sortType:_hsSortType finishedCallback:@selector(reqMarketQuotationDataFinished:) failedCallback:@selector(reqMarketQuotationDataFailed:)];
    }else if([tab isEqualToString:HomeQuotationsTabHK]){
        [[NetWorkManage shareSingleNetWork] reqMarketQuotationData:self tab:tab sortField:_hkSortField sortType:_hkSortType finishedCallback:@selector(reqMarketQuotationDataFinished:) failedCallback:@selector(reqMarketQuotationDataFailed:)];
    }
    
}

- (void)reqMarketQuotationDataFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSString *tab = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"tab"]];
        NSArray *quotesArr = [dataDic objectForKey:@"quotes"];
        if([tab isEqualToString:HomeQuotationsTabCustom]){              //自选行情数据
            [customCoinsDataArr removeAllObjects];
            for(NSDictionary *dic in quotesArr){
                QuotationCoinBaseEntity *entity = [[[QuotationCoinBaseEntity alloc] initWithJson:dic] autorelease];
                [customCoinsDataArr addObject:entity];
            }
            if(checkIsStringWithAnyText(ROOTCONTROLLER_USER.userId)){           //登陆了才需要刷新数据
                [_customSymbolDataView reloadCustomSymbolViewData:customCoinsDataArr];         //更新数据
            }
            
        }else if([tab isEqualToString:HomeQuotationsTabSotckFutures]){          //股指期货数据
            [stockFuturesDataArr removeAllObjects];
            for(NSDictionary *dic in quotesArr){
                QuotationCoinBaseEntity *entity = [[[QuotationCoinBaseEntity alloc] initWithJson:dic] autorelease];
                [stockFuturesDataArr addObject:entity];
            }
            [_stockFuturesSymbolDataView reloadStockFuturesSymbolViewData:stockFuturesDataArr];
    
        }else if([tab isEqualToString:HomeQuotationsTabHB] ){           //火币行情数据
            [coinsDataArr removeAllObjects];
            for(NSDictionary *dic in quotesArr){
                QuotationCoinBaseEntity *entity = [[[QuotationCoinBaseEntity alloc] initWithJson:dic] autorelease];
                [coinsDataArr addObject:entity];
            }
            [_dataTableView reloadData];
        }else if([tab isEqualToString:HomeQuotationsTabHS] ){
            [hsDataArr removeAllObjects];
            for(NSDictionary *dic in quotesArr){
                QuotationCoinBaseEntity *entity = [[[QuotationCoinBaseEntity alloc] initWithJson:dic] autorelease];
                [hsDataArr addObject:entity];
            }
            [_dataHSTableView reloadData];
        }else if([tab isEqualToString:HomeQuotationsTabHK] ){
            [hkDataArr removeAllObjects];
            for(NSDictionary *dic in quotesArr){
                QuotationCoinBaseEntity *entity = [[[QuotationCoinBaseEntity alloc] initWithJson:dic] autorelease];
                [hkDataArr addObject:entity];
            }
            [_dataHKTableView reloadData];
        }
    }
}

- (void)reqMarketQuotationDataFailed:(NSDictionary *)json
{
    [self dismissProgress];
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _dataHSTableView) {
        return [hsDataArr count];
    }else if (tableView == _dataHKTableView) {
        return [hkDataArr count];
    }else{
        return [coinsDataArr count];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.quotationsCoinCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *byySymbolCellIdentifier = @"HomeQuotationsCoinCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:byySymbolCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeQuotationsCoinCell" owner:nil options:nil] lastObject];
    }
    
    QuotationCoinBaseEntity *entity;
    if (tableView == _dataHSTableView) {
        entity = [hsDataArr objectAtIndex:indexPath.row];
    }else if (tableView == _dataHKTableView) {
        entity = [hkDataArr objectAtIndex:indexPath.row];
    }else{
        entity = [coinsDataArr objectAtIndex:indexPath.row];
    }

    UILabel *symbolLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *priceLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:104];
    UILabel *rateLabel = (UILabel *)[cell viewWithTag:103];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:102];
    UIView *priceView = (UIView *)[cell viewWithTag:105];
    UILabel *tipsLabel = (UILabel *)[cell viewWithTag:106];
    
    NSRange symbolRange = [entity.symbol rangeOfString:@"/"];
    NSMutableAttributedString *string = [[[NSMutableAttributedString alloc] initWithString:entity.symbol] autorelease];
    if(symbolRange.location != NSNotFound){
        [string addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0f],NSForegroundColorAttributeName:RGBA(97, 117, 174, 0.4)} range:NSMakeRange(symbolRange.location, entity.symbol.length - symbolRange.location)];
    }
    symbolLabel.attributedText = string;
    
    
    priceLabel.text = entity.price;
    nameLabel.text = entity.name;
    rateLabel.text = [NSString stringWithFormat:@"%@%%",[TradeUtil stringByAppendingPlusSymbolString:entity.rate]];
    priceView.backgroundColor = [TradeUtil textColorWithQuotationNumber:entity.rate.floatValue];
    amountLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedStringForKey(@"量"), entity.amount];
    if(checkIsStringWithAnyText(entity.tip)){
        tipsLabel.hidden = NO;
        tipsLabel.text = entity.tip;
    }else{
        tipsLabel.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    QuotationCoinBaseEntity *entity;
    if (tableView == _dataHSTableView) {
        entity = [hsDataArr objectAtIndex:indexPath.row];
    }else if (tableView == _dataHKTableView) {
        entity = [hkDataArr objectAtIndex:indexPath.row];
    }else{
        entity = [coinsDataArr objectAtIndex:indexPath.row];
    }
    [self putValueToParamDictionary:CoinTradeDic value:entity.originSymbol forKey:@"CoinQuotationsDetailOriginSymbol"];
    [self putValueToParamDictionary:CoinTradeDic value:entity.symbol forKey:@"CoinQuotationsDetailSymbol"];
    [self putValueToParamDictionary:CoinTradeDic value:entity.marketType forKey:@"CoinQuotationDetailMarketType"];
    [self pageToViewControllerForName:@"CoinQuotationsDetailController"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == _coreScrollView){
        CGPoint point = scrollView.contentOffset;
        if(point.x == 0){
            _customButton.selected = YES;
            _hsButton.selected = NO;
            _hkButton.selected = NO;
            _stockFuturesButton.selected = NO;
            _hbButton.selected = NO;
            
            _customButton.titleLabel.font = UIFontBoldMake(16);
            _hsButton.titleLabel.font = UIFontMake(14);
            _hkButton.titleLabel.font = UIFontMake(14);
            _stockFuturesButton.titleLabel.font = UIFontMake(14);
            _hbButton.titleLabel.font = UIFontMake(14);
            
            self.reqSocketTab = HomeQuotationsTabCustom;               //请求的是自选的行情
        }else if(point.x == scrollView.frame.size.width * 1){
            _customButton.selected = NO;
            _hsButton.selected = YES;
            _hkButton.selected = NO;
            _stockFuturesButton.selected = NO;
            _hbButton.selected = NO;
            _hsButton.titleLabel.font = UIFontBoldMake(16);
            _customButton.titleLabel.font = UIFontMake(14);
            _hkButton.titleLabel.font = UIFontMake(14);
            _stockFuturesButton.titleLabel.font = UIFontMake(14);
            _hbButton.titleLabel.font = UIFontMake(14);
            
            self.reqSocketTab = HomeQuotationsTabHS;
        }else if(point.x == scrollView.frame.size.width * 2){
            
            _customButton.selected = NO;
            _hsButton.selected = NO;
            _hkButton.selected = YES;
            _stockFuturesButton.selected = NO;
            _hbButton.selected = NO;
            
            _hkButton.titleLabel.font = UIFontBoldMake(16);
            
            _hsButton.titleLabel.font = UIFontMake(14);
            _hkButton.titleLabel.font = UIFontMake(14);
            _stockFuturesButton.titleLabel.font = UIFontMake(14);
            _hbButton.titleLabel.font = UIFontMake(14);
            
            self.reqSocketTab = HomeQuotationsTabHK;
            
        }else if(point.x == scrollView.frame.size.width * 3){
            
            _customButton.selected = NO;
            _hsButton.selected = NO;
            _hkButton.selected = NO;
            _stockFuturesButton.selected = YES;
            _hbButton.selected = NO;
            _stockFuturesButton.titleLabel.font = UIFontBoldMake(16);
            
            _hsButton.titleLabel.font = UIFontMake(14);
            _hkButton.titleLabel.font = UIFontMake(14);
            _hkButton.titleLabel.font = UIFontMake(14);
            _hbButton.titleLabel.font = UIFontMake(14);
            self.reqSocketTab = HomeQuotationsTabSotckFutures;
            
        }else if(point.x == scrollView.frame.size.width * 4){
            
            _customButton.selected = NO;
            _hsButton.selected = NO;
            _hkButton.selected = NO;
            _stockFuturesButton.selected = NO;
            _hbButton.selected = YES;
            _hbButton.titleLabel.font = UIFontBoldMake(16);
            
            _hsButton.titleLabel.font = UIFontMake(14);
            _hkButton.titleLabel.font = UIFontMake(14);
            _hkButton.titleLabel.font = UIFontMake(14);
            _stockFuturesButton.titleLabel.font = UIFontMake(14);
            
            self.reqSocketTab = HomeQuotationsTabHB;
            
        }
        [self setReqSocketTab:_reqSocketTab];
    }
}


#pragma mark - 开启关闭定时器
- (void)startRequestTimer
{
    if(requestDataTimer && [requestDataTimer isValid]){
        [self closeRequestTimer];
    }
    requestDataTimer = [NSTimer timerWithTimeInterval:ROOTCONTROLLER.quotationRefreshTime target:self selector:@selector(requestTimerUpdate) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:requestDataTimer forMode:NSRunLoopCommonModes];
}

- (void)closeRequestTimer
{
    if(requestDataTimer && [requestDataTimer isValid]){
        [requestDataTimer invalidate];
        requestDataTimer = nil;
    }
}

- (void)requestTimerUpdate
{
    [self reqMarketQuotationData:_reqSocketTab];
}

#pragma mark - HomeQuotationSortHeaderViewDelegate  (排序回调)
- (void)sortHeaderView:(UIView *)sortView sortField:(NSString *)field sortState:(SortButtonState)state
{
    if (sortView == _quotationsHeaderViewHS) {
        self.hsSortField = field;
        self.hsSortType = [NSString stringWithFormat:@"%@",@(state)];
    } else if (sortView == _quotationsHeaderViewHK) {
        self.hkSortField = field;
        self.hkSortType = [NSString stringWithFormat:@"%@",@(state)];
    } else {
        self.hbSortField = field;
        self.hbSortType = [NSString stringWithFormat:@"%@",@(state)];
    }
    [self reqMarketQuotationData:_reqSocketTab];
}

#pragma mark - HQCustomSybolViewDelegate   (自选回调)
- (void)customSymbolViewLoginButtonPressed
{
    [ROOTCONTROLLER gotoLogin];
}

- (void)customSymbolViewSymbolDidSelected:(NSString *)symbol originSymbol:(NSString *)originSymbol marketType:(NSString *)marketType
{
    [self putValueToParamDictionary:CoinTradeDic value:symbol forKey:@"CoinQuotationsDetailSymbol"];
    [self putValueToParamDictionary:CoinTradeDic value:originSymbol forKey:@"CoinQuotationsDetailOriginSymbol"];
    [self putValueToParamDictionary:CoinTradeDic value:marketType forKey:@"CoinQuotationDetailMarketType"];
    [self pageToViewControllerForName:@"CoinQuotationsDetailController"];
}

- (void)customSymbolViewSortButtonDidSelectedWithSortField:(NSString *)sortField sortState:(NSString *)sortState
{
    self.customSortField = sortField;
    self.customSortType = sortState;
    [self reqMarketQuotationData:_reqSocketTab];
}

#pragma mark - HQStockFuturesSymbolView delegate
- (void)stockFuturesSymbolViewSymbolDidSelected:(NSString *)symbol originSymbol:(NSString *)originSymbol marketType:(NSString *)marketType
{
    [self putValueToParamDictionary:CoinTradeDic value:originSymbol forKey:@"CoinQuotationsDetailOriginSymbol"];
    [self putValueToParamDictionary:CoinTradeDic value:symbol forKey:@"CoinQuotationsDetailSymbol"];
    [self putValueToParamDictionary:CoinTradeDic value:marketType forKey:@"CoinQuotationDetailMarketType"];
    [self pageToViewControllerForName:@"CoinQuotationsDetailController"];
}

- (void)stockFuturesSymbolViewSortButtonDidSelectedWithSortField:(NSString *)sortField sortState:(NSString *)sortState;
{
    self.leverageSortFiled = sortField;
    self.leverageSortType = sortState;
    [self reqMarketQuotationData:_reqSocketTab];
}

@end
