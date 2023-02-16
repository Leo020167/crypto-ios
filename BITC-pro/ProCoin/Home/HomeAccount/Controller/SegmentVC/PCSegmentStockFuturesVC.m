//
//  SegmentLeverageVC.m
//  BYY
//
//  Created by Hay on 2019/12/17.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "PCSegmentStockFuturesVC.h"
#import "TradeUtil.h"

@interface PCSegmentStockFuturesVC ()<UITableViewDelegate,UITableViewDataSource>
{

}

/** 懒加载*/
@property (assign, nonatomic) CGFloat accountInfoCellHeight;
@property (assign, nonatomic) CGFloat accountHoldCellHeight;

/** 实体变量*/
@property (retain, nonatomic) PCAccountModel *stockFuturesEntity;
@property (copy, nonatomic) NSArray *holdTableData;

@end

@implementation PCSegmentStockFuturesVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    _dataTableView.delegate = self;
    _dataTableView.dataSource = self;
    //reloadData 视图漂移或者闪动解决方法
    _dataTableView.estimatedRowHeight = 0;
    _dataTableView.estimatedSectionHeaderHeight = 0;
    _dataTableView.estimatedSectionFooterHeight = 0;
}

- (void)dealloc
{
    [_dataTableView release];
    [_stockFuturesEntity release];
    [_holdTableData release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)accountInfoCellHeight
{
    if(_accountInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseAccountInfoCell" owner:nil options:nil] lastObject];
        _accountInfoCellHeight = cell.frame.size.height;
    }
    return _accountInfoCellHeight;
}

- (CGFloat)accountHoldCellHeight
{
    if(_accountHoldCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseAccountHoldCell" owner:nil options:nil] lastObject];
        _accountHoldCellHeight = cell.frame.size.height;
    }
    return _accountHoldCellHeight;
}

#pragma mark - 按钮点击事件
- (void)questionButtonPressed:(UIButton *)sender
{
    if([_delegate respondsToSelector:@selector(stockFuturesRiskQuestionButtonDidPressed)]){
        [_delegate stockFuturesRiskQuestionButtonDidPressed];
    }
}


#pragma mark - 更新数据
- (void)reloadStockFuturesAccountInfo:(PCAccountModel *)infoEntity accountHoldData:(NSArray *)dataArr
{
    self.stockFuturesEntity = infoEntity;
    self.holdTableData = dataArr;
    [_dataTableView reloadData];
}

#pragma mark - table view data source and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 10)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){           //账户信息
        return 1;;
    }else if(section == 1){     //开仓
        return [self.holdTableData count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){           //账户信息
        return self.accountInfoCellHeight;
    }else if(indexPath.section == 1){     //开仓
        return self.accountHoldCellHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *holdCellIdentifier = @"PCBaseAccountHoldCellIdentifier";
    if(indexPath.section == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseAccountInfoCell" owner:nil options:nil] lastObject];
        UILabel *accountLabel = (UILabel *)[cell viewWithTag:107];
        if (self.stockFuturesEntity.type == 1) {
            accountLabel.text = NSLocalizedStringForKey(@"国际期货总资产(USDT)");
        }else if (self.stockFuturesEntity.type == 2){
            accountLabel.text = NSLocalizedStringForKey(@"外汇总资产(USDT)");
        }
        if(_stockFuturesEntity == nil){
            return cell;
        }
        UILabel *assetsLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *cnyLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *riskLabel = (UILabel *)[cell viewWithTag:102];
        UILabel *eableLabel = (UILabel *)[cell viewWithTag:103];
        UILabel *profitLabel = (UILabel *)[cell viewWithTag:104];
        UILabel *openBailLabel = (UILabel *)[cell viewWithTag:105];
        UILabel *frozenBailLabel = (UILabel *)[cell viewWithTag:106];
        UIButton *questionButton = (UIButton *)[cell viewWithTag:500];
        [questionButton addTarget:self action:@selector(questionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        assetsLabel.text = _stockFuturesEntity.assets;
        cnyLabel.text = _stockFuturesEntity.assetsCny;
        riskLabel.text = [NSString stringWithFormat:@"%@%%",_stockFuturesEntity.riskRate];
        eableLabel.text = _stockFuturesEntity.eableBail;
        profitLabel.text = [TradeUtil stringByAppendingPlusSymbolString:_stockFuturesEntity.profit];
        profitLabel.textColor = [TradeUtil textColorWithQuotationNumber:[_stockFuturesEntity.profit doubleValue]];
        openBailLabel.text = _stockFuturesEntity.openBail;
        frozenBailLabel.text = _stockFuturesEntity.frozenBail;
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:holdCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseAccountHoldCell" owner:nil options:nil] lastObject];
        }
        PCBaseHoldCoinModel *entity = [_holdTableData objectAtIndex:indexPath.row];
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *rateLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *handAmountLabel = (UILabel *)[cell viewWithTag:102];
        UILabel *openPriceLabel = (UILabel *)[cell viewWithTag:103];
        UILabel *profitLabel = (UILabel *)[cell viewWithTag:104];
        NSString *titleString = [NSString stringWithFormat:@"%@·%@",entity.symbol,entity.buySellValue];
        NSRange range = [titleString rangeOfString:@"/"];
        NSMutableAttributedString *titleAttributed = [[[NSMutableAttributedString alloc] initWithString:titleString] autorelease];
        if(range.location != NSNotFound){
            [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f],NSForegroundColorAttributeName:RGBA(29, 49, 85, 1.0)} range:NSMakeRange(0,range.location + 1)];
            [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f],NSForegroundColorAttributeName:RGBA(97, 117, 174, 0.4)} range:NSMakeRange(range.location,titleString.length - range.location)];
        }
        titleLabel.attributedText = titleAttributed;
        rateLabel.text = [NSString stringWithFormat:@"%@%%",[TradeUtil stringByAppendingPlusSymbolString:entity.profitRate]];
        rateLabel.textColor = [TradeUtil textColorWithQuotationNumber:[entity.profitRate doubleValue]];
        handAmountLabel.text = entity.openHand;
        openPriceLabel.text = entity.openPrice;
        profitLabel.text = [TradeUtil stringByAppendingPlusSymbolString:entity.profit];
        profitLabel.textColor = [TradeUtil textColorWithQuotationNumber:[entity.profit doubleValue]];
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1){
        PCBaseHoldCoinModel *entity = [_holdTableData objectAtIndex:indexPath.row];
        if([_delegate respondsToSelector:@selector(stockFuturesTableViewDidSelectedCellWithIndexPath:)]){
            [_delegate stockFuturesTableViewDidSelectedCellWithIndexPath:entity];
        }
    }
}

@end
