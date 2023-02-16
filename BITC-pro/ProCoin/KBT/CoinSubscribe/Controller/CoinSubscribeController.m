//
//  CoinSubscribeController.m
//  BYY
//
//  Created by Hay on 2019/10/10.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CoinSubscribeController.h"
#import "RZRefreshTableView.h"
#import "CoinSubOperationView.h"
#import "NetWorkManage+KBT.h"
#import "PersonSubInfoEntity.h"
#import "CoinSubscribeEntity.h"
#import "CommonUtil.h"
#import "VeDateUtil.h"
#import "CoinSubscribeInputView.h"
#import "KBTAnnouceEntity.h"

@interface CoinSubscribeController ()<CoinSubOperationViewDelegate,CoinSubscribeInputViewDelegate>
{
    NSInteger pageNo;
    NSMutableArray *announceDataArr;
    NSTimer *timeLabelUpdateTimer;
}

@property (retain, nonatomic) PersonSubInfoEntity *subInfoEntity;   //认购信息
@property (retain, nonatomic) CoinSubscribeEntity *coinSubEntity;   //币种信息

/** 懒加载*/
@property (retain, nonatomic) UIView *subInfoHeaderView;
@property (retain, nonatomic) CoinSubOperationView *subOperationView;         //操作view
@property (retain, nonatomic) UIView *announceHeaderView;               //公告headerView
@property (assign, nonatomic) CGFloat announceCellHeight;               //公告cell高度


@property (retain, nonatomic) IBOutlet UILabel *navigationTitle;
@property (retain, nonatomic) IBOutlet RZRefreshTableView *subscribeTableView;
@end

@implementation CoinSubscribeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    pageNo = 1;
    announceDataArr = [[NSMutableArray alloc] init];
    [_subscribeTableView setTableViewDelegate:self];
    
    [self showProgressDefaultText];
    [self reqSubMainData];          //请求认购主页信息
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.subInfoEntity){
        [self updateTimeLabel];
        if([_subInfoEntity.countDownTimestamp doubleValue] > 0 && ![self isSurpassValidTime]){
            [self startUpdateTimeLabelTimer];
        }
    }
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self closeUpdateTimeLabelTimer];
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [announceDataArr release];
    [_subInfoEntity release];
    [_coinSubEntity release];
    [_subInfoHeaderView release];
    [_subOperationView release];
    [_announceHeaderView release];
    [_subscribeTableView release];
    [_navigationTitle release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

#pragma mark - 懒加载
- (UIView *)subInfoHeaderView
{
    if(!_subInfoHeaderView){
        _subInfoHeaderView = (UIView *)[[[[NSBundle mainBundle] loadNibNamed:@"CoinSubMainInfoHeaderView" owner:nil options:nil] lastObject] retain];
    }
    return _subInfoHeaderView;
}


- (CoinSubOperationView *)subOperationView
{
    if(!_subOperationView){
        _subOperationView = (CoinSubOperationView *)[[[[NSBundle mainBundle] loadNibNamed:@"CoinSubOperationView" owner:nil options:nil] lastObject] retain];
        _subOperationView.delegate = self;
    }
    return _subOperationView;
}

- (UIView *)announceHeaderView
{
    if(!_announceHeaderView){
        _announceHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 40)];
        UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 40)] autorelease];
        titleLabel.textColor = RGBA(61, 58, 80, 1.0);
        titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        titleLabel.text = NSLocalizedStringForKey(@"公告");
        [_announceHeaderView addSubview:titleLabel];
    }
    return _announceHeaderView;
}

- (CGFloat)announceCellHeight
{
    if(_announceCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CoinSubAnnounceCell" owner:nil options:nil] lastObject];
        _announceCellHeight = cell.frame.size.height;
    }
    return _announceCellHeight;
}


#pragma mark - 请求数据
/** 请求认购数据*/
- (void)reqSubMainData
{
    [[NetWorkManage shareSingleNetWork] reqSubMainHome:self finishedCallback:@selector(reqSubMainDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqSubMainDataFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *coinSubDic = [dataDic objectForKey:@"coinSubBuy"];
        self.subInfoEntity = [[[PersonSubInfoEntity alloc] initWithJson:dataDic] autorelease];
        self.coinSubEntity = [[[CoinSubscribeEntity alloc] initWithJson:coinSubDic] autorelease];
        
        /** 更新信息数据*/
        [self updateMainInfoHeaderView];
        /** 更新按钮*/
        [self updateMainChartViewButtonState];
        /** 请求公告*/
        [self reqAnnounceData];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 认购*/
- (void)reqSubBuy:(NSInteger)index
{
    NSString *amount = [NSString stringWithFormat:@"%@",[_coinSubEntity.balanceList objectAtIndex:index]];
    [[NetWorkManage shareSingleNetWork] reqSubBuy:self subId:_coinSubEntity.subId symbol:_coinSubEntity.symbol amount:amount finishedCallback:@selector(reqSubBuyFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqSubBuyFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"操作成功");
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:NO completion:nil];
        [self reqSubMainData];
    }else{
        if([self checkIsNotEnoughCash:json]){         //不够资金
            [self notEnoughMoneyJson:json toPageName:@"FundMainController" pageParams:nil];
        }else{
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
    }
}


/** 请求公告*/
- (void)reqAnnounceData
{
    [[NetWorkManage shareSingleNetWork] reqSubAnnounceData:self pageNo:[NSString stringWithFormat:@"%@",@(pageNo)] finishedCallback:@selector(reqAnnounceDataFinished:) failedCallback:@selector(reqAnnounceDataFailed:)];
}

- (void)reqAnnounceDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataList = [dataDic objectForKey:@"data"];
        if(_subscribeTableView.dragOrientation){
            [announceDataArr removeAllObjects];
        }
        for(NSDictionary *dic in dataList){
            KBTAnnouceEntity *announceEntity = [[[KBTAnnouceEntity alloc] initWithJson:dic] autorelease];
            [announceDataArr addObject:announceEntity];
        }
        [_subscribeTableView reloadData];
        
        if(!_subscribeTableView.dragOrientation && [dataList count] == 0){
            [_subscribeTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_subscribeTableView tableViewEndRefreshing];
        }
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        [_subscribeTableView tableViewEndRefreshing];
    }
}

- (void)reqAnnounceDataFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [_subscribeTableView tableViewEndRefreshing];
}


#pragma mark - 更新信息数据
- (void)updateMainInfoHeaderView
{

    UIView *subInfoView = (UIView *)[self.subInfoHeaderView viewWithTag:200];
    UIView *noDataView = (UIView *)[self.subInfoHeaderView viewWithTag:300];
    if(checkIsStringWithAnyText(_coinSubEntity.symbol)){            //有认购信息情况下
        subInfoView.hidden = NO;
        noDataView.hidden = YES;
        UILabel *titleLabel = (UILabel *)[self.subInfoHeaderView viewWithTag:100];
        UILabel *priceLabel = (UILabel *)[self.subInfoHeaderView viewWithTag:102];
        UILabel *totalAmountLabel = (UILabel *)[self.subInfoHeaderView viewWithTag:103];
        UILabel *priceCNYLabel = (UILabel *)[self.subInfoHeaderView viewWithTag:104];
        UILabel *subProgressLabel = (UILabel *)[self.subInfoHeaderView viewWithTag:105];
        UIView *subProgressView = (UILabel *)[self.subInfoHeaderView viewWithTag:106];
        UIView *totalProgressView = (UILabel *)[self.subInfoHeaderView viewWithTag:107];
        
        [self updateTimeLabel];//更新倒计时
        if([_subInfoEntity.countDownTimestamp doubleValue] > 0 && ![self isSurpassValidTime]){
            [self startUpdateTimeLabelTimer];
        }
        
        titleLabel.text = [NSString stringWithFormat:@"%@",_coinSubEntity.symbol];
        
        priceLabel.text = _coinSubEntity.price;
        totalAmountLabel.text = _coinSubEntity.totalAmount;
        priceCNYLabel.text = _coinSubEntity.priceCny;
        CGFloat percentage;
        if([_coinSubEntity.totalAmount doubleValue] == 0){
            percentage = 0;
        }else{
            percentage = [_coinSubEntity.produceAmount doubleValue] / [_coinSubEntity.totalAmount doubleValue];
        }
        
        subProgressLabel.text = [NSString stringWithFormat:@"%@：%.2f%%", NSLocalizedStringForKey(@"本轮认购进度"), percentage * 100];
        [CommonUtil viewWidthForAutoLayout:subProgressView width:(totalProgressView.frame.size.width * percentage)];
        
        
        
    }else{
        subInfoView.hidden = YES;
        noDataView.hidden = NO;
    }
    
}

#pragma mark - 更新按钮状态
- (void)updateMainChartViewButtonState
{
    [self.subOperationView reloadButtonStateWithBuyButtonState:_subInfoEntity.isOpenBuy tradeButtonState:_subInfoEntity.isOpenTrade buyButtonTitle:_subInfoEntity.btnText];
}

#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){           //信息
        return self.subInfoHeaderView.frame.size.height;
    }else if(section == 1){     //操作
        if(checkIsStringWithAnyText(_coinSubEntity.symbol)){
            return self.subOperationView.frame.size.height;
        }
    }else if(section == 2){     //公告
        if([announceDataArr count] > 0){
            return self.announceHeaderView.frame.size.height;
        }
    }
    return CGFLOAT_MIN;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){           //信息
        return self.subInfoHeaderView;
    }else if(section == 1){     //操作
        if(checkIsStringWithAnyText(_coinSubEntity.symbol)){
            return self.subOperationView;
        }
        
    }else if(section == 2){     //公告
        if([announceDataArr count] > 0){
            return self.announceHeaderView;
        }
    }
    return nil;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 2){
        return [announceDataArr count];
    }
    return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KBTAnnouceEntity *announceEntity = [announceDataArr objectAtIndex:indexPath.row];
    CGSize size = [CommonUtil getPerfectSizeByText:announceEntity.title andFontSize:12.0f andWidth:SCREEN_WIDTH - 30];
    size.height =  MAX(size.height, 16);
    return self.announceCellHeight + (size.height - 16);

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CoinSubAnnounceCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyBackAnnounceCell" owner:nil options:nil] lastObject];
    }
    KBTAnnouceEntity *announceEntity = [announceDataArr objectAtIndex:indexPath.row];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *impLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:102];
    
    titleLabel.text = announceEntity.title;
    if(announceEntity.isTop == 1){
        impLabel.text = NSLocalizedStringForKey(@"重要");
    }else{
        impLabel.text = @"";
    }
    timeLabel.text = [VeDateUtil formatterDate:announceEntity.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm" isTimestamp:YES];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    KBTAnnouceEntity *announceEntity = [announceDataArr objectAtIndex:indexPath.row];
    
    TYWebViewController *web = [[TYWebViewController alloc] init];
    web.url = announceEntity.url;
    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
    
}

- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    pageNo = 1;
    [self reqSubMainData];
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    pageNo++;
    [self reqAnnounceData];
}


#pragma mark - 开启关闭定时器
- (void)startUpdateTimeLabelTimer
{
    if(timeLabelUpdateTimer && [timeLabelUpdateTimer isValid]){
        [self closeUpdateTimeLabelTimer];
    }
    timeLabelUpdateTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timeLabelUpdateTimer forMode:NSRunLoopCommonModes];
}

- (void)closeUpdateTimeLabelTimer
{
    if(timeLabelUpdateTimer && [timeLabelUpdateTimer isValid]){
        [timeLabelUpdateTimer invalidate];
        timeLabelUpdateTimer = nil;
    }
}



#pragma mark - SubCoinOperationView delegate
- (void)coinSubOperationViewSubscribeButtonDidSelected
{
    if(![ROOTCONTROLLER getLoginStatus]){
        return;
    }
    if(checkIsStringWithAnyText(_subInfoEntity.holdAmount) && checkIsStringWithAnyText(_subInfoEntity.repoAmount)){
        CoinSubscribeInputView *inputView = (CoinSubscribeInputView *)[[[NSBundle mainBundle] loadNibNamed:@"CoinSubscribeInputView" owner:nil options:nil] lastObject];
        inputView.delegate = self;
        [inputView showCoinSubscribeInputViewInView:self.tabBarController.view];
        [inputView reloadInputViewWithHoldAmount:_subInfoEntity.holdAmount symbol:_coinSubEntity.symbol balanceArr:_coinSubEntity.balanceList price:_coinSubEntity.price myEquityLevel:_subInfoEntity.myEquityLevel myEquityTip:_subInfoEntity.myEquityTip];
    }
}

- (void)coinSubOperationViewTradeButtonDidSelected
{
    if(![ROOTCONTROLLER getLoginStatus]){
        return;
    }
    if(checkIsStringWithAnyText(_coinSubEntity.symbol)){
        [self putValueToParamDictionary:CoinTradeDic value:_coinSubEntity.symbol forKey:@"CoinQuotationsDetailSymbol"];
        [self putValueToParamDictionary:CoinTradeDic value:_coinSubEntity.originSymbol forKey:@"CoinQuotationsDetailOriginSymbol"];
        [self pageToViewControllerForName:@"CoinQuotationsDetailController"];
    }
}

#pragma mark - CoinSubscribeInputView delegate
- (void)coinSubscribeInputViewErrorMsg:(NSString *)msg
{
    [self showToastCenter:msg];
}

- (void)coinSubscribeInputViewCertainButtonDidPressedWithPriceIndex:(NSInteger)index
{
    NSString *balance = [NSString stringWithFormat:@"%@",[_coinSubEntity.balanceList objectAtIndex:index]];
    NSString *msg = [NSString stringWithFormat:NSLocalizedStringForKey(@"确定要认购数量为%@的%@吗？"),balance,_coinSubEntity.symbol];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self showProgressDefaultText];
        [self reqSubBuy:index];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)coinSubscribeInputViewEquityInfoButtonDidPressed
{
    if(checkIsStringWithAnyText(_subInfoEntity.subUrl)){
        
        TYWebViewController *web = [[TYWebViewController alloc] init];
        web.url = _subInfoEntity.subUrl;
        [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
    }
}


#pragma mark - 更新时间文本倒计时
- (void)updateTimeLabel
{
    UILabel *countDownTimeLabel = (UILabel *)[self.subInfoHeaderView viewWithTag:101];
    if(!checkIsStringWithAnyText(_coinSubEntity.symbol) || [_subInfoEntity.countDownTimestamp doubleValue] <= 0 ){
        if(checkIsStringWithAnyText(_coinSubEntity.symbol)){
            NSMutableAttributedString *text = [[[NSMutableAttributedString alloc] initWithString:_subInfoEntity.timeTips] autorelease];
            countDownTimeLabel.attributedText = text;
        }
        [self closeUpdateTimeLabelTimer];
        return;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *theDate = [NSDate dateWithTimeIntervalSince1970:[_subInfoEntity.countDownTimestamp doubleValue]];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *result = [formatter stringFromDate:theDate];
    RELEASE(formatter);
    NSInteger diffSeconds = [VeDateUtil componentsSecondNowWithDateContainNegative:result];           //现在时间离结束时间相差的秒数
    NSInteger days = (diffSeconds / 60 / 60 / 24);
    NSInteger hours = (diffSeconds / 60 / 60 - (24 * days));
    NSInteger minutes = (diffSeconds /60 - (24 * 60 * days) - (60 * hours));
    NSInteger seconds = (diffSeconds - (24 * 60 * 60 * days) - (60 * 60 * hours) - (60 * minutes));
    
    NSString *timeString;
    if([self isSurpassValidTime]){
        timeString = NSLocalizedStringForKey(@"0天00时00分00秒");
        NSString *textString = [NSString stringWithFormat:@"%@%@",_subInfoEntity.timeTips,timeString];
        NSMutableAttributedString *text = [[[NSMutableAttributedString alloc] initWithString:textString] autorelease];
        countDownTimeLabel.attributedText = text;
        [self reqSubMainData];                  //超过重新请求数据
        [self closeUpdateTimeLabelTimer];       //关掉定时器
    }else{
        NSString *daysStr;
        NSString *hoursStr;
        NSString *minutesStr;
        NSString *secondsStr;
        daysStr = [NSString stringWithFormat:@"%ld", (long)days];
        if(hours < 10){
            hoursStr = [NSString stringWithFormat:@"0%ld", (long)hours];
        }else{
            hoursStr = [NSString stringWithFormat:@"%ld", (long)hours];
        }
        if (minutes < 10) {
            minutesStr = [NSString stringWithFormat:@"0%ld", (long)minutes];
        } else {
            minutesStr = [NSString stringWithFormat:@"%ld", (long)minutes];
        }
        
        if (seconds < 10) {
            secondsStr = [NSString stringWithFormat:@"0%ld", (long)seconds];
        } else {
            secondsStr = [NSString stringWithFormat:@"%ld", (long)seconds];
        }
        
        timeString = [NSString stringWithFormat:NSLocalizedStringForKey(@"%@天%@时%@分%@秒"),daysStr,hoursStr,minutesStr,secondsStr];
        NSString *textString = [NSString stringWithFormat:@"%@%@",_subInfoEntity.timeTips,timeString];
        NSMutableAttributedString *text = [[[NSMutableAttributedString alloc] initWithString:textString] autorelease];
        NSRange range = [textString rangeOfString:_subInfoEntity.timeTips];
        [text addAttribute:NSForegroundColorAttributeName value:RGBA(251, 135, 90, 1.0) range:NSMakeRange(range.length, textString.length - range.length)];
        countDownTimeLabel.attributedText = text;
    }
    
    
    
}

/** 判断是否超过有效时间*/
- (BOOL)isSurpassValidTime
{
    if(checkIsStringWithAnyText(_subInfoEntity.countDownTimestamp) && [_subInfoEntity.countDownTimestamp doubleValue] >= 0){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSDate *theDate = [NSDate dateWithTimeIntervalSince1970:[_subInfoEntity.countDownTimestamp doubleValue]];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *result = [formatter stringFromDate:theDate];
        RELEASE(formatter);
        NSInteger diffSeconds = [VeDateUtil componentsSecondNowWithDateContainNegative:result];           //现在时间离结束时间相差的秒数
        NSInteger days = (diffSeconds / 60 / 60 / 24);
        NSInteger hours = (diffSeconds / 60 / 60 - (24 * days));
        NSInteger minutes = (diffSeconds /60 - (24 * 60 * days) - (60 * hours));
        NSInteger seconds = (diffSeconds - (24 * 60 * 60 * days) - (60 * 60 * hours) - (60 * minutes));
        
        if(days<=0 && hours<=0 && minutes<=0 && seconds<=0){
            return YES;
        }
        return NO;
    }
    
    return YES;
    
}


@end
