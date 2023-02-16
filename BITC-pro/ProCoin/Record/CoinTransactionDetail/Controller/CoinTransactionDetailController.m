//
//  CoinTransactionDetailController.m
//  Cropyme
//
//  Created by Hay on 2019/5/27.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CoinTransactionDetailController.h"
#import "NetWorkManage+Trade.h"
#import "CoinTransactionDetailEntity.h"
#import "CoinTradeOrderEntity.h"
#import "CTDTradeBaseInfoCell.h"
#import "CTDTradeFollowOrderInfoCell.h"
#import "VeDateUtil.h"


@interface CoinTransactionDetailController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *transactonDetailArr;            //交易明细数组
    CGFloat detailHeaderViewHeight;                //交易明细headerView高度
}

@property (copy, nonatomic) NSString *orderId;
@property (retain, nonatomic) CoinTradeOrderEntity *orderEntity;
@property (retain, nonatomic) UIView *detailHeaderView;         //交易明细headerView
@property (assign, nonatomic) CGFloat baseInfoCellHeight;       //base info cell高度
@property (assign, nonatomic) CGFloat orderInfoCellHeight;      //汇总cell高度
@property (assign, nonatomic) CGFloat detailCellHeight;         //交易明细高度
@property (retain, nonatomic) IBOutlet UITableView *coreTableView;

@end

@implementation CoinTransactionDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
    transactonDetailArr = [[NSMutableArray alloc] init];
    detailHeaderViewHeight = 40;
    // Do any additional setup after loading the view from its nib.
    _coreTableView.delegate = self;
    _coreTableView.dataSource = self;
    if([self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinTradnsactionDetailOrderId"]){
        self.orderId = [self getValueFromModelDictionary:CoinTradeDic forKey:@"CoinTradnsactionDetailOrderId"];
        [self removeParamFromModelDictionary:CoinTradeDic forKey:@"CoinTradnsactionDetailOrderId"];
    }
    
    [self showProgressDefaultText];
    [self reqCoinCoinTradeDetail];
}

- (void)dealloc
{
    [transactonDetailArr release];
    [_orderId release];
    [_orderEntity release];
    [_detailHeaderView release];
    [_coreTableView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (UIView *)detailHeaderView
{
    if(_detailHeaderView == nil){
        //这个不需要释放，因为detailHeaderView属于retain,会在dealloc中释放
        _detailHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, detailHeaderViewHeight)];
        _detailHeaderView.backgroundColor = [UIColor whiteColor];
        UIImageView *iconIV = [[[UIImageView alloc] initWithFrame:CGRectMake(10, (detailHeaderViewHeight - 16)/2.0f, 4, 16)] autorelease];
        iconIV.backgroundColor = RGBA(61, 58, 80, 1.0);
        UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(iconIV.frame.origin.x + iconIV.frame.size.width + 5, (detailHeaderViewHeight - 30)/2.0f, 100, 30)] autorelease];
        titleLabel.font = [UIFont systemFontOfSize:16.0f];
        titleLabel.textColor = RGBA(61, 58, 80, 1.0);
        titleLabel.text = NSLocalizedStringForKey(@"成交明细");
        [_detailHeaderView addSubview:iconIV];
        [_detailHeaderView addSubview:titleLabel];
        
    }
    return _detailHeaderView;
}

- (CGFloat)detailCellHeight
{
    if(_detailCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CTDTradeDeailInfoCell" owner:nil options:nil] lastObject];
        _detailCellHeight = cell.frame.size.height;
    }
    return _detailCellHeight;
}

- (CGFloat)baseInfoCellHeight
{
    if(_baseInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CTDTradeBaseInfoCell" owner:nil options:nil] lastObject];
        _baseInfoCellHeight = cell.frame.size.height;
    }
    return _baseInfoCellHeight;
}

- (CGFloat)orderInfoCellHeight
{
    if(_orderInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CTDTradeFollowOrderInfoCell" owner:nil options:nil] lastObject];
        _orderInfoCellHeight = cell.frame.size.height;
    }
    return _orderInfoCellHeight;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}


#pragma mark - 请求数据接口
- (void)reqCoinCoinTradeDetail
{
    [[NetWorkManage shareSingleNetWork] reqCoinCoinTradeOrderDetail:self orderId:_orderId finishedCallback:@selector(reqCoinCoinTradeDetailFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCoinCoinTradeDetailFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dealList = [dataDic objectForKey:@"dealList"];
        NSDictionary *orderDic = [dataDic objectForKey:@"order"];
        self.orderEntity = [[[CoinTradeOrderEntity alloc] initWithJson:orderDic] autorelease];
        for(NSDictionary *dealDic in dealList){
            CoinTransactionDetailEntity *entity = [[[CoinTransactionDetailEntity alloc] initWithJson:dealDic] autorelease];
            [transactonDetailArr addObject:entity];
        }
        [_coreTableView reloadData];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return CGFLOAT_MIN;
    }
    if([transactonDetailArr count] > 0){
        return self.detailHeaderView.frame.size.height;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return nil;
    }
    if([transactonDetailArr count] > 0){
        return self.detailHeaderView;
    }else{
        return nil;
    }
    
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
    if(section == 0){
        if(!_orderEntity){          //不存在的话，就不存在交易信息
            return 0;
        }
        if(_orderEntity.openFollow){           //是否跟单交易
            return 2;
        }else{
            return 1;
        }
    }else{
        return [transactonDetailArr count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            return self.baseInfoCellHeight;
        }else{
            return self.orderInfoCellHeight;
        }
    }else if(indexPath.section == 1){
        return self.detailCellHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *baseInfoCellIdentifier = @"CTDTradeBaseInfoCellIdentifier";
    NSString *orderInfoCellIdentifier = @"CTDTradeFollowOrderInfoCellIdentifier";
    NSString *detailInfoCellIdentifier = @"CTDTradeDeailInfoCellIdentifier";
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            CTDTradeBaseInfoCell *baseInfoCell = [tableView dequeueReusableCellWithIdentifier:baseInfoCellIdentifier];
            if(baseInfoCell == nil){
                baseInfoCell = [[[NSBundle mainBundle] loadNibNamed:@"CTDTradeBaseInfoCell" owner:nil options:nil] lastObject];
            }
            [baseInfoCell reloadBaseInfoCellData:self.orderEntity];
            
            return baseInfoCell;
        }else{
            CTDTradeFollowOrderInfoCell *orderInfoCell = [tableView dequeueReusableCellWithIdentifier:orderInfoCellIdentifier];
            if(orderInfoCell == nil){
                orderInfoCell = [[[NSBundle mainBundle] loadNibNamed:@"CTDTradeFollowOrderInfoCell" owner:nil options:nil] lastObject];
            }
            [orderInfoCell reloadOrderInfoCellData:self.orderEntity];
            
            return orderInfoCell;
        }
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:detailInfoCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CTDTradeDeailInfoCell" owner:nil options:nil] lastObject];
        }
        CoinTransactionDetailEntity *entity = [transactonDetailArr objectAtIndex:indexPath.row];
        UILabel *createTimeLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *priceLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *dealAmountLabel = (UILabel *)[cell viewWithTag:102];
        UILabel *priceTitleLabel = (UILabel *)[cell viewWithTag:200];
        UILabel *amountTitleLabel = (UILabel *)[cell viewWithTag:201];
        createTimeLabel.text = [VeDateUtil formatterDate:entity.timestamp inStytle:@"" outStytle:@"yyyy-MM-dd HH:mm" isTimestamp:YES];
        priceLabel.text = entity.dealPrice;
        dealAmountLabel.text = entity.dealAmount;
        priceTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"成交价"), entity.unitSymbol];
        amountTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"成交量"), entity.originSymbol];
        
        return cell;
    }
}


@end
