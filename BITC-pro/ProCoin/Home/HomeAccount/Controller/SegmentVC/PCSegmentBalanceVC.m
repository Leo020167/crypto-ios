//
//  SegmentStoreVC.m
//  BYY
//
//  Created by Hay on 2019/12/17.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "PCSegmentBalanceVC.h"
#import "TradeUtil.h"
#import "VeDateUtil.h"

@interface PCSegmentBalanceVC ()<UITableViewDelegate,UITableViewDataSource>
{

}

/** 数据变量*/
@property (retain, nonatomic) PCAccountModel *balanceInfoEntity;            //账户信息
@property (copy, nonatomic) NSArray *recordDataArr;           //财务记录数组

/** 懒加载*/
@property (assign, nonatomic) CGFloat accountInfoCellHeight;
@property (assign, nonatomic) CGFloat recordCellHeight;



@end

@implementation PCSegmentBalanceVC

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
    [_balanceInfoEntity release];
    [_recordDataArr release];
    [super dealloc];
}

#pragma mark - 更新数据
- (void)reloadBalanceAccountInfo:(PCAccountModel *)balanceInfoEntity
{
    self.balanceInfoEntity = balanceInfoEntity;
    
}

- (void)reloadBalanceRecordData:(NSArray *)recordDataArr
{
    self.recordDataArr = recordDataArr;
    
    [_dataTableView reloadData];
}

#pragma mark - 懒加载
- (CGFloat)accountInfoCellHeight
{
    if(_accountInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeBalanceInfoCell" owner:nil options:nil] lastObject];
        _accountInfoCellHeight = cell.frame.size.height;
    }
    return _accountInfoCellHeight;
}

- (CGFloat)recordCellHeight
{
    if(_recordCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeBalanceRecordCell" owner:nil options:nil] lastObject];
        _recordCellHeight = cell.frame.size.height;
    }
    return _recordCellHeight;
}

#pragma mark - 按钮点击事件
- (void)allRecordButtonPressed:(UIButton *)sender
{
    if([_delegate respondsToSelector:@selector(balanceCoinAllRecordButtonPressed)]){
        [_delegate balanceCoinAllRecordButtonPressed];
    }
}

#pragma mark - table view data source and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1){       //财务记录
        return 40;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 1){       //财务记录
        UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 40)] autorelease];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 0.0, 120, 40)] autorelease];
        titleLabel.text = NSLocalizedStringForKey(@"财务记录");
        titleLabel.font = [UIFont systemFontOfSize:18.0f];
        titleLabel.textColor = RGBA(29, 49, 85, 1.0);
        [view addSubview:titleLabel];
        UIButton *allButton = [UIButton buttonWithType:UIButtonTypeCustom];
        allButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [allButton setTitleColor:RGBA(97, 117, 174, 1.0) forState:UIControlStateNormal];
        [allButton setTitle:NSLocalizedStringForKey(@"全部") forState:UIControlStateNormal];
        [allButton setFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 60, 40)];
        [allButton addTarget:self action:@selector(allRecordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:allButton];
        return view;
    }
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
        return 1;
    }else if(section == 1){     //财务记录
        return [_recordDataArr count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){     //账户信息
        return self.accountInfoCellHeight;
    }else if(indexPath.section == 1){   //财务记录
        return self.recordCellHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *recordCellIdentifier = @"PCHomeBalanceRecordCellIdentifier";
    if(indexPath.section == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeBalanceInfoCell" owner:nil options:nil] lastObject];
        if(_balanceInfoEntity == nil)
            return cell;
        UILabel *assetsLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *assetsCNYLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *holdAmount = (UILabel *)[cell viewWithTag:102];
        UILabel *frozenAmountLabel = (UILabel *)[cell viewWithTag:103];
        assetsLabel.text = _balanceInfoEntity.assets;
        assetsCNYLabel.text = _balanceInfoEntity.assetsCny;
        holdAmount.text = _balanceInfoEntity.holdAmount;
        frozenAmountLabel.text = _balanceInfoEntity.frozenAmount;
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:recordCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeBalanceRecordCell" owner:nil options:nil] lastObject];
        }
        PCCoinOperationRecordModel *recordEntity = [_recordDataArr objectAtIndex:indexPath.row];
        UILabel *orientationLabel = (UILabel *)[cell viewWithTag:99];
        UILabel *numbersLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *amountLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *stateLabel = (UILabel *)[cell viewWithTag:102];
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:103];
        orientationLabel.text = recordEntity.inOut == PCCoinOperationTypeOut ? NSLocalizedStringForKey(@"提币"):NSLocalizedStringForKey(@"充币");
        amountLabel.text = recordEntity.amount;
        stateLabel.text = recordEntity.stateDesc;
        timeLabel.text = [VeDateUtil formatterDate:recordEntity.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm" isTimestamp:YES];
        numbersLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringForKey(@"数量"), recordEntity.symbol];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        if([_delegate respondsToSelector:@selector(balanceCoinOperationRecordDidSelectedWithIndexPath:)]){
            [_delegate balanceCoinOperationRecordDidSelectedWithIndexPath:indexPath];
        }
    }
    
}

@end
