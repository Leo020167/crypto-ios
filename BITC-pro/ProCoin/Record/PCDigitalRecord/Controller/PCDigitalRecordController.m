//
//  PCDigitalRecordController.m
//  ProCoin
//
//  Created by Hay on 2020/3/3.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCDigitalRecordController.h"
#import "RZRefreshTableView.h"
#import "NetWorkManage+Trade.h"
#import "PCDigitalRecordScreenView.h"
#import "PCBaseTransactionRecordModel.h"
#import "VeDateUtil.h"
#import "CommonUtil.h"
#import "PayAlertView.h"
#import "TYMineTransactionRecordListCell.h"

@interface PCDigitalRecordController ()<UITableViewDelegate,UITableViewDataSource,RZRefreshTableViewDelegate,UIScrollViewDelegate,PCDigitalRecordScreenViewDelegate>
{
    NSMutableArray *orderTableData;
    NSMutableArray *historyTableData;
    NSInteger orderPageNo;          //委托页数
    NSInteger historyPageNo;        //历史页数
}

/** 变量*/
@property (copy, nonatomic) NSString *screenSymbol;       //筛选的交易队
@property (copy, nonatomic) NSString *screenOrderType;    //筛选的订单类型
@property (copy, nonatomic) NSString *cancelOrderId;      //撤单id

/** 懒加载*/
@property (assign, nonatomic) CGFloat orderCellHeight;      //委托cell高度
@property (assign, nonatomic) CGFloat historyFilledCellHeight;      //历史已完成cell高度
@property (assign, nonatomic) CGFloat historyCanceledCellHeight;    //历史已撤销cell高度

@property (retain, nonatomic) IBOutlet QMUIButton *titleBtn;

/** UI */
@property (retain, nonatomic) IBOutlet UIButton *screenButton;  //筛选按钮
@property (retain, nonatomic) IBOutlet UIButton *orderButton;   //委托按钮
@property (retain, nonatomic) IBOutlet UIButton *historyButton; //历史按钮
@property (retain, nonatomic) IBOutlet UIScrollView *coreScrollView;    //核心scrollView
@property (retain, nonatomic) IBOutlet RZRefreshTableView *orderTableView;      //委托tableView
@property (retain, nonatomic) IBOutlet UIView *orderTipsView;                   //委托提示view
@property (retain, nonatomic) IBOutlet RZRefreshTableView *historyTableView;    //历史tableView
@property (retain, nonatomic) IBOutlet UIView *historyTipsView;                 //历史提示view

@property (nonatomic, strong) UILabel *amountLabel;

@property (nonatomic, strong) UILabel *tokenLabel;

@end

@implementation PCDigitalRecordController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!self.accountType.length) {
        self.accountType = @"follow";
    }
    if (self.accountName.length) {
        [self.titleBtn setTitle:self.accountName forState:0];
    }else{
        [self.titleBtn setTitle:NSLocalizedStringForKey(@"跟单交易记录") forState:0];
    }
    if ([self.accountType isEqualToString:@"digital"] || [self.accountType isEqualToString:@"stock"]) {
        self.tokenLabel.hidden = NO;
        self.amountLabel.hidden = NO;
        [self getQuerySumAction];
    }else{
        self.tokenLabel.hidden = YES;
        self.amountLabel.hidden = YES;
    }
    
    /** 请求委托和历史数据*/
    [self showProgressDefaultText];
    [self reqTransactionOrderData];
    [self reqTransactionHistoryData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _screenButton.hidden = NO;         //在历史记录才显示
    _orderTipsView.hidden = YES;
    _historyTipsView.hidden = YES;
    [_orderTableView setTableViewDelegate:self];
    [_historyTableView setTableViewDelegate:self];
    orderTableData = [[NSMutableArray alloc] init];
    historyTableData = [[NSMutableArray alloc] init];
    _coreScrollView.delegate = self;
    orderPageNo = 1;
    historyPageNo = 1;
    self.screenSymbol = @"";
    self.screenOrderType = @"";
    
    self.titleBtn.qmui_height = 44;
    self.titleBtn.qmui_top = kUIStatusBarHeight;
    self.titleBtn.spacingBetweenImageAndTitle = 5;
    self.titleBtn.imagePosition = QMUIButtonImagePositionRight;
    [self.titleBtn setImage:UIImageMake(@"util_icon_down_trangle") forState:0];
    [self.titleBtn addTarget:self action:@selector(titleBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.tokenLabel];
    [self.view addSubview:self.amountLabel];
    [self.tokenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.orderButton);
    }];
    [self.amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.tokenLabel.mas_left).offset(-10);
        make.centerY.mas_equalTo(self.orderButton);
    }];
}

- (void)dealloc
{
    [orderTableData release];
    [historyTableData release];
    [_screenSymbol release];
    [_screenOrderType release];
    [_cancelOrderId release];
    [_screenButton release];
    [_orderButton release];
    [_historyButton release];
    [_coreScrollView release];
    [_orderTableView release];
    [_orderTipsView release];
    [_historyTableView release];
    [_historyTipsView release];
    [_titleBtn release];
    [super dealloc];
}

- (void)titleBtnAction{
    NSArray *titleArray = @[NSLocalizedStringForKey(@"跟单交易记录"), NSLocalizedStringForKey(@"全球期指交易记录"), NSLocalizedStringForKey(@"合约交易记录"), NSLocalizedStringForKey(@"币币交易记录")];
    NSArray *accountArray = @[@"follow", @"stock", @"digital", @"spot"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"交易类型") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (int i = 0; i < titleArray.count; i ++) {
        [alert addAction:[UIAlertAction actionWithTitle:titleArray[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.accountType = accountArray[i];
            [self.titleBtn setTitle:titleArray[i] forState:0];
            if ([self.accountType isEqualToString:@"spot"]) {
                self.screenButton.hidden = YES;
            }else{
                self.screenButton.hidden = YES;
            }
            if ([self.accountType isEqualToString:@"digital"] || [self.accountType isEqualToString:@"stock"]) {
                self.tokenLabel.hidden = NO;
                self.amountLabel.hidden = NO;
                [self getQuerySumAction];
            }else{
                self.tokenLabel.hidden = YES;
                self.amountLabel.hidden = YES;
            }
            historyPageNo = 1;
            orderPageNo = 1;
            [orderTableData removeAllObjects];
            [historyTableData removeAllObjects];
            /** 请求委托和历史数据*/
            [self showProgressDefaultText];
            [self reqTransactionOrderData];
            [self reqTransactionHistoryData];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)getQuerySumAction{
    [YYRequestUtility Post:@"/pro/order/querySum.do" addParameters:@{@"accountType" : self.accountType} progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {

            NSMutableAttributedString *amountText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", NSLocalizedStringForKey(@"总交易手数"), responseDict[@"data"][@"sumCount"]]];
            [amountText yy_setFont:UIFontMake(15) range:amountText.yy_rangeOfAll];
            [amountText yy_setColor:UIColorMakeWithHex(@"#333333") range:amountText.yy_rangeOfAll];
            [amountText yy_setFont:UIFontMake(13) range:NSMakeRange(0, NSLocalizedStringForKey(@"总交易手数").length)];
            [amountText yy_setColor:UIColorMakeWithHex(@"#999999") range:NSMakeRange(0, NSLocalizedStringForKey(@"总交易手数").length)];
            [amountText yy_setAlignment:NSTextAlignmentCenter range:amountText.yy_rangeOfAll];
            [amountText yy_setLineSpacing:5 range:amountText.yy_rangeOfAll];
            self.amountLabel.attributedText = amountText;
            
            NSMutableAttributedString *tokenText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", NSLocalizedStringForKey(@"获得BICP"), responseDict[@"data"][@"sumToken"]]];
            [tokenText yy_setFont:UIFontMake(15) range:tokenText.yy_rangeOfAll];
            [tokenText yy_setColor:UIColorMakeWithHex(@"#333333") range:tokenText.yy_rangeOfAll];
            [tokenText yy_setFont:UIFontMake(13) range:NSMakeRange(0, NSLocalizedStringForKey(@"获得BICP").length)];
            [tokenText yy_setColor:UIColorMakeWithHex(@"#999999") range:NSMakeRange(0, NSLocalizedStringForKey(@"获得BICP").length)];
            [tokenText yy_setAlignment:NSTextAlignmentCenter range:tokenText.yy_rangeOfAll];
            [tokenText yy_setLineSpacing:5 range:tokenText.yy_rangeOfAll];
            self.tokenLabel.attributedText = tokenText;
            
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 懒加载
- (CGFloat)orderCellHeight
{
    if(_orderCellHeight == 0){
        UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"PCBaseTransactionOrderCell" owner:nil options:nil] lastObject];
        _orderCellHeight = cell.frame.size.height;
    }
    return _orderCellHeight;
    
}

- (CGFloat)historyFilledCellHeight
{
    if(_historyFilledCellHeight == 0){
        UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"PCBaseHistoryRecordFilledCell" owner:nil options:nil] lastObject];
        _historyFilledCellHeight = cell.frame.size.height;
    }
    return _historyFilledCellHeight;
}

- (CGFloat)historyCanceledCellHeight
{
    if(_historyCanceledCellHeight == 0){
        UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"PCBaseHistoryRecordCanceledCell" owner:nil options:nil] lastObject];
        _historyCanceledCellHeight =  cell.frame.size.height;
    }
    return _historyCanceledCellHeight;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)optionsButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton == _orderButton){
        if(_orderButton.isSelected){
            return;
        }
        _orderButton.selected = YES;
        _historyButton.selected = NO;
        _screenButton.hidden = YES;
        _orderButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        _historyButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_coreScrollView setContentOffset:CGPointMake(_coreScrollView.frame.size.width, 0.0) animated:YES];
        if([orderTableData count] == 0){
            [self reqTransactionOrderData];
        }
        
    }else{
        if(_historyButton.isSelected){
            return;
        }
        _orderButton.selected = NO;
        _historyButton.selected = YES;
        if ([self.accountType isEqualToString:@"spot"]) {
            _screenButton.hidden = YES;
        }else{
            _screenButton.hidden = NO;
        }
        
        _orderButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _historyButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        [_coreScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
        if([historyTableData count] == 0){
            [self  reqTransactionHistoryData];
        }
    }
}

/** 筛选按钮点击事件*/
- (IBAction)screenButtonPressed:(id)sender
{
    PCDigitalRecordScreenView *screenView = [[[PCDigitalRecordScreenView alloc] init] autorelease];
    screenView.delegate = self;
    screenView.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [screenView addSelfToParentViewController:self inputSymbol:self.screenSymbol orderType:self.screenOrderType];
}

/** 取消订单按钮点击事件*/
- (void)cancelOrderButtonPressed:(NSIndexPath *)indexPath
{
    PCBaseTransactionRecordModel *entity = [orderTableData objectAtIndex:indexPath.row];
    self.cancelOrderId = entity.orderId;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"确定取消该委托订单吗?") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqCancelOrder:@""];          //取消订单
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
   
}
#pragma mark - 请求数据
/** 请求委托数据*/
- (void)reqTransactionOrderData
{
    
    NSString *type = @"";
    NSString *isDone = @"0";
    NSString *screenOrderType = @"";
    if ([self.accountType isEqualToString:@"spot"]) {
        type = @"2";
        isDone = @"1";
        screenOrderType = @"0";
    }
    
    [[NetWorkManage shareSingleNetWork] reqDigitalStockTransactionRecord:self symbol:@"" accountType:self.accountType isDone:isDone pageNo:[NSString stringWithFormat:@"%@",@(orderPageNo)] buySell:@"" orderState:screenOrderType type:type finishedCallback:@selector(reqTransactionOrderDataFinished:) failedCallback:@selector(reqTransactionOrderDataFailed:)];
}

- (void)reqTransactionOrderDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *containDataArr = [dataDic objectForKey:@"data"];
        if(_orderTableView.dragOrientation){
            [orderTableData removeAllObjects];
        }
        for(NSDictionary *dic in containDataArr){
            PCBaseTransactionRecordModel *entity = [PCBaseTransactionRecordModel yy_modelWithDictionary:dic];
            [orderTableData addObject:entity];
        }
        [_orderTableView reloadData];

        if([containDataArr count] == 0 && !_orderTableView.dragOrientation){
            [_orderTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_orderTableView tableViewEndRefreshing];
        }
        if([orderTableData count] > 0){
            _orderTableView.hidden = NO;
            _orderTipsView.hidden = YES;
        }else{
            _orderTableView.hidden = YES;
            _orderTipsView.hidden = NO;
        }
    }else{
        [_orderTableView tableViewEndRefreshing];
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqTransactionOrderDataFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [_orderTableView tableViewEndRefreshing];
    [self showToastCenter:NSLocalizedStringForKey(@"请求失败")];
}

/** 请求历史数据*/
- (void)reqTransactionHistoryData
{
    NSString *type = @"";
    NSString *isDone = @"-1";
    NSString *screenOrderType = self.screenOrderType;
    if ([self.accountType isEqualToString:@"spot"]) {
        type = @"2";
        isDone = @"1";
        screenOrderType = @"1";
    }

    [[NetWorkManage shareSingleNetWork] reqDigitalStockTransactionRecord:self symbol:self.screenSymbol accountType:self.accountType isDone:isDone pageNo:[NSString stringWithFormat:@"%@",@(historyPageNo)] buySell:@"" orderState:screenOrderType type:type finishedCallback:@selector(reqTransactionHistoryDataFinished:) failedCallback:@selector(reqTransactionHistoryDataFailed:)];
}

- (void)reqTransactionHistoryDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *containDataArr = [dataDic objectForKey:@"data"];
        if(_historyTableView.dragOrientation){
            [historyTableData removeAllObjects];
        }
        for(NSDictionary *dic in containDataArr){
            PCBaseTransactionRecordModel *entity = [PCBaseTransactionRecordModel yy_modelWithDictionary:dic];
            [historyTableData addObject:entity];
        }
        [_historyTableView reloadData];
        
        if([containDataArr count] == 0 && !_historyTableView.dragOrientation){
            [_historyTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_historyTableView tableViewEndRefreshing];
        }
        if([historyTableData count] > 0){
            _historyTableView.hidden = NO;
            _historyTipsView.hidden = YES;
        }else{
            _historyTableView.hidden = YES;
            _historyTipsView.hidden = NO;
        }
    }else{
        [_historyTableView tableViewEndRefreshing];
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqTransactionHistoryDataFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [_historyTableView tableViewEndRefreshing];
    [self showToastCenter:NSLocalizedStringForKey(@"请求失败")];
}

- (void)reqCancelOrder:(NSString *)payPass
{
    if(checkIsStringWithAnyText(self.cancelOrderId)){
        [self showProgressDefaultText];
        NSString *type = @"";
        if ([self.accountType isEqualToString:@"spot"]) {
            type = @"2";
        }
        [[NetWorkManage shareSingleNetWork] reqTradeCancelOrder:self orderId:self.cancelOrderId payPass:payPass type:type finishedCallback:@selector(reqCancelOrderFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
    }
    
}

- (void)reqCancelOrderFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"已成功发送撤销")];
        }
        /** 请求数据立即刷新*/
        orderPageNo = 1;
        [self reqTransactionOrderData];
        
    }else{
        if([self checkIsNeedTradePassword:json]){          //需要输入交易密码
            PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
            [payAlertView show];
        }else if(![self checkIsNeedSetTradePassword:json]){     //不需要设置交易密码
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
    }
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _orderTableView){
        return [orderTableData count];
    }else if(tableView == _historyTableView){
        return [historyTableData count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _orderTableView){
        return self.orderCellHeight;
    }else if(tableView == _historyTableView){
        PCBaseTransactionRecordModel *entity = [historyTableData objectAtIndex:indexPath.row];
        if([entity.closeState isEqualToString:PCTransactionHistoryOrderFilledState]){        //已完成
            return self.historyFilledCellHeight;
        }else{      //已撤销
            return self.historyCanceledCellHeight;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.accountType isEqualToString:@"spot"]) {
        if (tableView == _orderTableView) {
            static NSString *unDoneCellIdentifier = @"PCBaseTransactionOrderCellIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:unDoneCellIdentifier];
            if(cell == nil){
                cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseTransactionOrderCell" owner:nil options:nil] lastObject];
                UIButton *cancelOrderButton = (UIButton *)[cell viewWithTag:500];
                cancelOrderButton.qmui_tapBlock = ^(__kindof UIControl *sender) {
                    [self cancelOrderButtonPressed:indexPath];
                };
            }
            PCBaseTransactionRecordModel *entity = [orderTableData objectAtIndex:indexPath.row];
            UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
            UILabel *dateLabel = (UILabel *)[cell viewWithTag:101];
            UILabel *handAmountLabel = (UILabel *)[cell viewWithTag:102];
            UILabel *priceLabel = (UILabel *)[cell viewWithTag:103];
            UILabel *openBailLabel = (UILabel *)[cell viewWithTag:104];
            titleLabel.text = [NSString stringWithFormat:@"%@·%@", entity.symbol, entity.buySellValue];
            dateLabel.text = [VeDateUtil formatterDate:entity.openTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
            handAmountLabel.text = entity.amount;
            priceLabel.text = entity.price;
            openBailLabel.text = entity.sum;
            return cell;
        }
        
        TYMineTransactionRecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYMineTransactionRecordListCell class])];
        if (cell == nil) {
            cell = [[TYMineTransactionRecordListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([TYMineTransactionRecordListCell class])];
        }
        PCBaseTransactionRecordModel *model = historyTableData[indexPath.row];
        model.type = self.historyButton.isSelected ? 1 : 0;
        cell.model = model;
        __weak typeof(self) weakSelf = self;
        cell.statusBtnActionBlock = ^{
            [weakSelf cancelOrderButtonPressed:indexPath];
        };
        return cell;
    }
    static NSString *orderCellIdentifier = @"PCBaseTransactionOrderCellIdentifier";
    static NSString *historyFilledCellIdentifier = @"PCBaseHistoryRecordFilledCellIdentifier";
    static NSString *historyCanceledCellIdentifier = @"PCBaseHistoryRecordCanceledCellIdentifier";
    if(tableView == _orderTableView){// 委托
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:orderCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseTransactionOrderCell" owner:nil options:nil] lastObject];
            UIButton *cancelOrderButton = (UIButton *)[cell viewWithTag:500];
            cancelOrderButton.qmui_tapBlock = ^(__kindof UIControl *sender) {
                [self cancelOrderButtonPressed:indexPath];
            };
        }
        PCBaseTransactionRecordModel *entity = [orderTableData objectAtIndex:indexPath.row];
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *handAmountLabel = (UILabel *)[cell viewWithTag:102];
        UILabel *priceLabel = (UILabel *)[cell viewWithTag:103];
        UILabel *openBailLabel = (UILabel *)[cell viewWithTag:104];
        NSString *titleString = [NSString stringWithFormat:@"%@·%@",entity.symbol,entity.buySellValue];
        NSRange range = [titleString rangeOfString:@"/"];
        NSMutableAttributedString *titleAttributed = [[[NSMutableAttributedString alloc] initWithString:titleString] autorelease];
        if(range.location != NSNotFound){
            [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f],NSForegroundColorAttributeName:RGBA(29, 49, 85, 1.0)} range:NSMakeRange(0,range.location + 1)];
            [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f],NSForegroundColorAttributeName:RGBA(97, 117, 174, 0.4)} range:NSMakeRange(range.location,titleString.length - range.location)];
        }
        titleLabel.attributedText = titleAttributed;
        dateLabel.text = [VeDateUtil formatterDate:entity.openTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
        handAmountLabel.text = entity.openHand;
        priceLabel.text = entity.price;
        openBailLabel.text = entity.openBail;
        return cell;
    }else{
        PCBaseTransactionRecordModel *entity = [historyTableData objectAtIndex:indexPath.row];
        if([entity.closeState isEqualToString:PCTransactionHistoryOrderFilledState]){    //已完成
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:historyFilledCellIdentifier];
            if(cell == nil){
                cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseHistoryRecordFilledCell" owner:nil options:nil] lastObject];
            }
            UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
            UILabel *dateLabel = (UILabel *)[cell viewWithTag:101];
            UILabel *handAmountLabel = (UILabel *)[cell viewWithTag:102];
            UILabel *openPriceLabel = (UILabel *)[cell viewWithTag:103];
            UILabel *profitLabel = (UILabel *)[cell viewWithTag:104];
            UILabel *closeStateLabel = (UILabel *)[cell viewWithTag:105];
            NSString *titleString = [NSString stringWithFormat:@"%@·%@",entity.symbol,entity.buySellValue];
            NSRange range = [titleString rangeOfString:@"/"];
            NSMutableAttributedString *titleAttributed = [[[NSMutableAttributedString alloc] initWithString:titleString] autorelease];
            if(range.location != NSNotFound){
                [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f],NSForegroundColorAttributeName:RGBA(29, 49, 85, 1.0)} range:NSMakeRange(0,range.location + 1)];
                [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f],NSForegroundColorAttributeName:RGBA(97, 117, 174, 0.4)} range:NSMakeRange(range.location,titleString.length - range.location)];
            }
            titleLabel.attributedText = titleAttributed;
            dateLabel.text = [VeDateUtil formatterDate:entity.openTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
            handAmountLabel.text = entity.openHand;
            openPriceLabel.text = entity.openPrice;
            profitLabel.text = entity.profit;
            closeStateLabel.text = entity.closeStateDesc;
            return cell;
        }else{      //已撤销
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:historyCanceledCellIdentifier];
            if(cell == nil){
                cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseHistoryRecordCanceledCell" owner:nil options:nil] lastObject];
            }
            UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
            UILabel *dateLabel = (UILabel *)[cell viewWithTag:101];
            UILabel *handAmountLabel = (UILabel *)[cell viewWithTag:102];
            UILabel *priceLabel = (UILabel *)[cell viewWithTag:103];
            UILabel *openBailLabel = (UILabel *)[cell viewWithTag:104];
            UILabel *closeStateLabel = (UILabel *)[cell viewWithTag:105];
            NSString *titleString = [NSString stringWithFormat:@"%@·%@",entity.symbol,entity.buySellValue];
            NSRange range = [titleString rangeOfString:@"/"];
            NSMutableAttributedString *titleAttributed = [[[NSMutableAttributedString alloc] initWithString:titleString] autorelease];
            if(range.location != NSNotFound){
                [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f],NSForegroundColorAttributeName:RGBA(29, 49, 85, 1.0)} range:NSMakeRange(0,range.location + 1)];
                [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f],NSForegroundColorAttributeName:RGBA(97, 117, 174, 0.4)} range:NSMakeRange(range.location,titleString.length - range.location)];
            }
            titleLabel.attributedText = titleAttributed;
            dateLabel.text = [VeDateUtil formatterDate:entity.openTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
            handAmountLabel.text = entity.openHand;
            priceLabel.text = entity.price;
            openBailLabel.text = entity.openBail;
            closeStateLabel.text = entity.closeStateDesc;
            return cell;
        }

    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tableView == _historyTableView){     //只有历史才能点击
        PCBaseTransactionRecordModel *entity = [historyTableData objectAtIndex:indexPath.row];
        if([entity.closeState isEqualToString:PCTransactionHistoryOrderFilledState]){    //已完成才能进详情
            [self putValueToParamDictionary:ProCoinBaseDict value:entity.orderId forKey:@"TransactionDetailOrderId"];
            [self pageToViewControllerForName:@"PCTransactionDetailController"];
        }
    }
}


- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    if(_orderButton.isSelected){
        orderPageNo = 1;
        [self reqTransactionOrderData];
    }else{
        historyPageNo = 1;
        [self reqTransactionHistoryData];
    }
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    if(_orderButton.isSelected){
        orderPageNo++;
        [self reqTransactionOrderData];
    }else{
        historyPageNo++;
        [self reqTransactionHistoryData];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView == _coreScrollView){
        CGPoint point = scrollView.contentOffset;
        if(point.x <= 0){
            if(_historyButton.isSelected){
                return;
            }
            _orderButton.selected = NO;
            _historyButton.selected = YES;
            _screenButton.hidden = NO;
            _orderButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            _historyButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            if([historyTableData count] == 0){
                historyPageNo = 1;
                [self  reqTransactionHistoryData];
            }
            
        }else{
            if(_orderButton.isSelected){
                return;
            }
            _orderButton.selected = YES;
            _historyButton.selected = NO;
            _screenButton.hidden = YES;
            _orderButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            _historyButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            if([orderTableData count] == 0){
                orderPageNo = 1;
                [self reqTransactionOrderData];
            }
        }
    }
}

#pragma mark - payAlertView delegate
- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password
{
    if (password.length>0) {
        [self reqCancelOrder:password];
        [toolView close];
    }else{
        [toolView reset];
    }
}



#pragma mark - PCDigitalRecordScreenView delegate
- (void)digitalRecordScreenCommitDataWithSymbol:(NSString *)symbol orderType:(NSString *)orderType
{
    self.screenSymbol = symbol;
    self.screenOrderType = orderType;
    historyPageNo = 1;
    [self reqTransactionHistoryData];
}

- (UILabel *)amountLabel{
    if (!_amountLabel) {
        _amountLabel = [[UILabel alloc] init];
        _amountLabel.numberOfLines = 0;
    }
    return _amountLabel;
}

- (UILabel *)tokenLabel{
    if (!_tokenLabel) {
        _tokenLabel = [[UILabel alloc] init];
        _tokenLabel.numberOfLines = 0;
    }
    return _tokenLabel;
}

@end
