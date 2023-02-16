//
//  HQLeverageSymbolView.m
//  BYY
//
//  Created by Hay on 2019/12/20.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "HQStockFuturesSymbolView.h"
#import "HomeQuotationsSortHeaderView.h"
#import "QuotationCoinBaseEntity.h"
#import "TradeUtil.h"

@interface HQStockFuturesSymbolView()<UITableViewDelegate,UITableViewDataSource,HomeQuotationSortHeaderViewDelegate>

@property (copy, nonatomic) NSArray *tableData;
@property (retain, nonatomic) UITableView *symbolTableView;             //table view

/** 懒加载 */
@property (assign, nonatomic) CGFloat symbolDataCellHeight;             //cell高度
@property (retain, nonatomic) HomeQuotationsSortHeaderView *sortHeaderView;         //排序headerView

@end

@implementation HQStockFuturesSymbolView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self inititalLeverageSymbolView];
    }
    return self;
}

- (void)inititalLeverageSymbolView
{
    self.backgroundColor = [UIColor whiteColor];
    self.symbolTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain] autorelease];
    self.symbolTableView.backgroundColor = [UIColor whiteColor];
    [_symbolTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _symbolTableView.delegate = self;
    _symbolTableView.dataSource = self;
    _symbolTableView.tableHeaderView = self.sortHeaderView;
    [self addSubview:self.symbolTableView];
}

- (void)dealloc
{
    [_tableData release];
    [_symbolTableView release];
    [_sortHeaderView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)symbolDataCellHeight
{
    if(_symbolDataCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeQuotationsCoinCell" owner:nil options:nil] lastObject];
        _symbolDataCellHeight = cell.frame.size.height;
    }
    return _symbolDataCellHeight;
}

- (HomeQuotationsSortHeaderView *)sortHeaderView
{
    if(!_sortHeaderView){
        _sortHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"HomeQuotationsSortHeaderView" owner:nil options:nil] lastObject] retain];
        _sortHeaderView.delegate = self;
    }
    return _sortHeaderView;
}

#pragma mark - 更新数据
- (void)reloadStockFuturesSymbolViewData:(NSArray *)dataArr
{
    self.tableData = [NSArray arrayWithArray:dataArr];
    [_symbolTableView reloadData];
}


#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.symbolDataCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *byySymbolCellIdentifier = @"HomeQuotationsCoinCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:byySymbolCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeQuotationsCoinCell" owner:nil options:nil] lastObject];
    }
    QuotationCoinBaseEntity *entity = [_tableData objectAtIndex:indexPath.row];
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
    QuotationCoinBaseEntity *entity = [_tableData objectAtIndex:indexPath.row];
    if([_delegate respondsToSelector:@selector(stockFuturesSymbolViewSymbolDidSelected:originSymbol:marketType:)]){
        [_delegate stockFuturesSymbolViewSymbolDidSelected:entity.symbol originSymbol:entity.originSymbol marketType:entity.marketType];
    }
}

#pragma mark - HomeQuotationSortHeaderViewDelegate   (排序回调)
- (void)sortHeaderView:(UIView *)sortView sortField:(NSString *)field sortState:(SortButtonState)state
{
    if([_delegate respondsToSelector:@selector(stockFuturesSymbolViewSortButtonDidSelectedWithSortField:sortState:)]){
        [_delegate stockFuturesSymbolViewSortButtonDidSelectedWithSortField:field sortState:[NSString stringWithFormat:@"%@",@(state)]];
    }
}




@end
