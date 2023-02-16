//
//  CoinQuotationsSegmentGearController.m
//  Cropyme
//
//  Created by Hay on 2019/9/2.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CoinQuotationsSegmentGearController.h"
#import "CoinQuotationsTradeDataCell.h"

@interface CoinQuotationsSegmentGearController ()<UITableViewDelegate,UITableViewDataSource>
{

}

/**变量 */
@property (copy, nonatomic) NSArray *buyGearDataArr;
@property (copy, nonatomic) NSArray *sellGearDataArr;

/** 懒加载*/
@property (assign, nonatomic) CGFloat tradeDataCellHeight;      //交易cell高度


@end

@implementation CoinQuotationsSegmentGearController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _gearTableView.delegate = self;
    _gearTableView.dataSource = self;
    //reloadData 视图漂移或者闪动解决方法
    _gearTableView.estimatedRowHeight = 0;
    _gearTableView.estimatedSectionHeaderHeight = 0;
    _gearTableView.estimatedSectionFooterHeight = 0;
}

- (void)dealloc
{
    [_buyGearDataArr release];
    [_sellGearDataArr release];
    [_gearTableView release];
    [super dealloc];
}

/** 懒加载*/
- (CGFloat)tradeDataCellHeight
{
    if(_tradeDataCellHeight == 0){
        _tradeDataCellHeight = [CoinQuotationsTradeDataCell coinQuotationTradeDataCellHeight];
    }
    return _tradeDataCellHeight;
}

- (void)reloadControllerWithBuyDataArr:(NSArray *)buyDataArr sellDataArr:(NSArray *)sellDataArr
{
    self.buyGearDataArr = buyDataArr;
    self.sellGearDataArr = sellDataArr;
    [_gearTableView reloadData];
    
}

#pragma mark - table view delegate and data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tradeDataCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CoinQuotationsTradeDataCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoinQuotationsTradeDataCellIdentifier"];
    if(cell == nil){
        cell = (CoinQuotationsTradeDataCell *)[[[NSBundle mainBundle] loadNibNamed:@"CoinQuotationsTradeDataCell" owner:nil options:nil] lastObject];
    }
    [cell updateBuyTradeData:_buyGearDataArr sellDataArr:_sellGearDataArr];
    return cell;
}


@end
