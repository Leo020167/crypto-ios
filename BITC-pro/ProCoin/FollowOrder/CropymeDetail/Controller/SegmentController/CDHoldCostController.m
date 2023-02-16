//
//  CDHoldCostController.m
//  Cropyme
//
//  Created by Hay on 2019/8/9.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CDHoldCostController.h"
#import "NetWorkManage+FollowOrder.h"
#import "CDCostBaseEntity.h"
#import "CostSymbolHeaderView.h"
#import "CostChartHeaderView.h"
#import "CostChartEntity.h"

@interface CDHoldCostController ()<UITableViewDataSource,UITableViewDelegate,CostSymbolHeaderViewDelegate>
{
    NSMutableArray *chartDataArr;            //图标数据数组
    NSMutableArray *distributeDataArr;       //分布数组
    NSMutableArray *symbolArr;               //币种数组
}

@property (copy, nonatomic)  NSString *currentSymbol;           //当前symbol
@property (retain, nonatomic) CDCostBaseEntity *costEntity;

/** 懒加载*/
@property (retain, nonatomic) CostSymbolHeaderView *tableHeaderView;
@property (retain, nonatomic) CostChartHeaderView *chartHeaderView;         //图表header View
@property (retain, nonatomic) UIView *distributeHeaderView;                 //分布header View
@property (assign, nonatomic) CGFloat distributeCellHeight;                 //cell高度




@end

@implementation CDHoldCostController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _holdCostTableView.delegate = self;
    _holdCostTableView.dataSource = self;
    self.currentSymbol = @"";
    chartDataArr = [[NSMutableArray alloc] init];
    symbolArr = [[NSMutableArray alloc] init];
    distributeDataArr = [[NSMutableArray alloc] init];
    [self reqHoldCostData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object .to the new view controller.
}
*/

- (void)dealloc
{
    [_holdCostTableView release];
    [chartDataArr release];
    [distributeDataArr release];
    [symbolArr release];
    [_currentSymbol release];
    [_costEntity release];
    [_tableHeaderView release];
    [_chartHeaderView release];
    [_distributeHeaderView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CostSymbolHeaderView *)tableHeaderView
{
    if(!_tableHeaderView){
        _tableHeaderView = (CostSymbolHeaderView *)[[[[NSBundle mainBundle] loadNibNamed:@"CostSymbolHeaderView" owner:nil options:nil] lastObject] retain];
        _tableHeaderView.delegate = self;
    }
    return _tableHeaderView;
}

- (CostChartHeaderView *)chartHeaderView
{
    if(!_chartHeaderView){
        _chartHeaderView = (CostChartHeaderView *)[[[[NSBundle mainBundle] loadNibNamed:@"CostChartHeaderView" owner:nil options:nil] lastObject] retain];
    }
    return _chartHeaderView;
}

- (UIView *)distributeHeaderView
{
    if(!_distributeHeaderView){
        _distributeHeaderView = (UIView *)[[[[NSBundle mainBundle] loadNibNamed:@"CostDistributeHeaderView" owner:nil options:nil] lastObject] retain];
    }
    return _distributeHeaderView;
}

- (CGFloat)distributeCellHeight
{
    if(!_distributeCellHeight){
        UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"CostDistributeCell" owner:nil options:nil] lastObject];
        _distributeCellHeight = cell.frame.size.height;
    }
    return _distributeCellHeight;
}

#pragma mark - 请求数据
- (void)reqHoldCostData
{
    [[NetWorkManage shareSingleNetWork] reqFollowOrderUsersHoldCost:self symbol:_currentSymbol finishedCallback:@selector(reqHoldCostDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqHoldCostDataFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        self.costEntity = [[[CDCostBaseEntity alloc] initWithJson:dataDic] autorelease];
        NSArray *symbolList = [dataDic objectForKey:@"symbolList"];
        if([symbolList count] > 0){
            [symbolArr removeAllObjects];
            [symbolArr addObjectsFromArray:symbolList];
            [self.tableHeaderView reloadSymbolHeaderViewWithSymbolArr:symbolArr];
            _holdCostTableView.tableHeaderView = self.tableHeaderView;
        }else{
            /** 因为请求的时候，symbol为空才会返回symbol列表，symbol如果有具体数据，则不再返回数组!
             所以当不返回数据，而且之前都没symbol数据，则直接设置为nil */
            if(!self.tableHeaderView.isHasOptionsButton){
                _holdCostTableView.tableHeaderView = nil;
            }
        }
        
        [chartDataArr removeAllObjects];
        NSArray *chartDistributeList = [dataDic objectForKey:@"chartDistributeList"];
        for(NSDictionary *dic in chartDistributeList){
            CostChartEntity *entity = [[[CostChartEntity alloc] initWithJson:dic] autorelease];
            [chartDataArr addObject:entity];
        }
        [self.chartHeaderView reloadChartHeaderViewWithCostEntity:self.costEntity chartDataArr:chartDataArr];
        
        [distributeDataArr removeAllObjects];
        NSArray *distributeList = [dataDic objectForKey:@"distributeList"];
        for(NSDictionary *dic in distributeList){
            CostChartEntity *entity = [[[CostChartEntity alloc] initWithJson:dic] autorelease];
            [distributeDataArr addObject:entity];
        }
        [_holdCostTableView reloadData];
        
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
        return self.chartHeaderView.frame.size.height;
    }else if(section == 1){
        return self.distributeHeaderView.frame.size.height;
    }
    return CGFLOAT_MIN;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return self.chartHeaderView;
    }else if(section == 1){
        return self.distributeHeaderView;
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
    if(section == 1){
        return [distributeDataArr count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.distributeCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CostDistributeCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"CostDistributeCell" owner:nil options:nil] lastObject];
    }
    UILabel *priceLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *rateLabel = (UILabel *)[cell viewWithTag:102];
    
    CostChartEntity *entity = [distributeDataArr objectAtIndex:indexPath.row];
    if(checkIsStringWithAnyText(entity.fromPrice) && checkIsStringWithAnyText(entity.toPrice)){     //当价格有区间的情况下
        priceLabel.text = [NSString stringWithFormat:@"%@ - %@",entity.fromPrice,entity.toPrice];
    }else{          //当只有一个价格没有区间的情况下，显示价格
        priceLabel.text = entity.price;
    }
    
    amountLabel.text = entity.amount;
    rateLabel.text = [NSString stringWithFormat:@"%@%%",entity.rate];
    
    return cell;
}


#pragma mark - CostSymbolHeaderView delegate
- (void)headerViewDidPressedSymbolButtonWithIndex:(NSInteger)index
{
    self.currentSymbol = [symbolArr objectAtIndex:index];
    [self reqHoldCostData];
    
}
@end
