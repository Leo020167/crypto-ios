//
//  CoinQuotationsTradeDataCell.m
//  Cropyme
//
//  Created by Hay on 2019/9/2.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TYCoinQuotationsTradeDataCell.h"
#import "CoinQuotationsTradeDataCell.h"
#import "CoinTradeGearEntity.h"
#import "CommonUtil.h"


#define TradeDataCellGearCellHeight     27

@interface TYCoinQuotationsTradeDataCell ()<UITableViewDelegate,UITableViewDataSource>
{
}
@property (copy, nonatomic) NSArray *buyTradeDataArr;        //买家数据
@property (copy, nonatomic) NSArray *sellTradeDataArr;  //卖家数据
@property (assign, nonatomic) CGFloat buyCellHeight;           //买家数据cell的高度
@property (assign, nonatomic) CGFloat sellCellHeight;          //卖家数据cell的高度
@property (retain, nonatomic) IBOutlet UITableView *buyDataTableView;           //买家5档数据
@property (retain, nonatomic) IBOutlet UITableView *sellDataTableView;          //卖家5档数据

@end

@implementation TYCoinQuotationsTradeDataCell

+ (NSInteger)coinQuotationTradeDataCellShowGearCount
{
    return TradeDataCellTotalGearCount;
}

+ (CGFloat)coinQuotationTradeDataCellHeight
{
    return TradeDataCellGearCellHeight * TradeDataCellTotalGearCount + 42;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _buyDataTableView.delegate = self;
    _buyDataTableView.dataSource = self;
    _sellDataTableView.delegate = self;
    _sellDataTableView.dataSource = self;
}

- (void)dealloc
{
    [_buyTradeDataArr release];
    [_sellTradeDataArr release];
    [_buyDataTableView release];
    [_sellDataTableView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)buyCellHeight
{
    if(_buyCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"QuotationsTradeBuyDataCell" owner:nil options:nil] lastObject];
        _buyCellHeight = cell.frame.size.height;
    }
    return _buyCellHeight;
}

- (CGFloat)sellCellHeight
{
    if(_sellCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"QuotationsTradeSellDataCell" owner:nil options:nil] lastObject];
        _sellCellHeight = cell.frame.size.height;
    }
    return _sellCellHeight;
}

#pragma mark - 设置左边买家数据,右边卖家数据*/
- (void)updateBuyTradeData:(NSArray *)buyDataArr sellDataArr:(NSArray *)sellDataArr
{
    self.buyTradeDataArr = buyDataArr;
    self.sellTradeDataArr = [[sellDataArr reverseObjectEnumerator] allObjects];         //逆序排序
    [_buyDataTableView reloadData];
    [_sellDataTableView reloadData];
}


#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    if(tableView == _buyDataTableView){
    //        return [_buyTradeDataArr count];
    //    }else{
    //        return [_sellTradeDataArr count];
    //    }
    return TradeDataCellTotalGearCount;           //固定10个
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == _buyDataTableView){
        return self.buyCellHeight;
    }else{
        return self.sellCellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *buyDataCellIdentifier = @"QuotationsTradeBuyDataCellIdentifier";
    static NSString *sellDataCellIdentifier = @"QuotationsTradeSellDataCellIdentifier";
    UITableViewCell *cell = nil;
    if(tableView == _buyDataTableView){
        cell = [tableView dequeueReusableCellWithIdentifier:buyDataCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"QuotationsTradeBuyDataCell" owner:nil options:nil] lastObject];;
        }
        CoinTradeGearEntity *entity = nil;
        UILabel *amountLabel = [cell viewWithTag:100];
        UILabel *priceLabel = [cell viewWithTag:101];
        UIImageView *bgIV = [cell viewWithTag:102];
        if(indexPath.row < [_buyTradeDataArr count]){
            entity = [_buyTradeDataArr objectAtIndex:indexPath.row];
            amountLabel.text = entity.amount;
            priceLabel.text = entity.price;
            CGFloat widthProgress = ([entity.depthRate integerValue] / 100.0f) * (SCREEN_WIDTH / 2.0f - 5.0f);
            [CommonUtil viewWidthForAutoLayout:bgIV width:widthProgress];
        }else{
            amountLabel.text = @"---";
            priceLabel.text = @"---";
            [CommonUtil viewWidthForAutoLayout:bgIV width:1];
        }
        
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:sellDataCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"QuotationsTradeSellDataCell" owner:nil options:nil] lastObject];
        }
        CoinTradeGearEntity *entity = nil;
        UILabel *amountLabel = [cell viewWithTag:100];
        UILabel *priceLabel = [cell viewWithTag:101];
        UIImageView *bgIV = [cell viewWithTag:102];
        if(indexPath.row < [_sellTradeDataArr count]){
            entity = [_sellTradeDataArr objectAtIndex:indexPath.row];
            amountLabel.text = entity.amount;
            priceLabel.text = entity.price;
            CGFloat widthProgress = ([entity.depthRate integerValue] / 100.0f) * (SCREEN_WIDTH / 2.0f - 5.0f);
            [CommonUtil viewWidthForAutoLayout:bgIV width:widthProgress];
        }else{
            amountLabel.text = @"---";
            priceLabel.text = @"---";
            [CommonUtil viewWidthForAutoLayout:bgIV width:1];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}
@end

