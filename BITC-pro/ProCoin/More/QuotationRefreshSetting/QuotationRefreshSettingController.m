//
//  QuotationRefreshSettingController.m
//  ProCoin
//
//  Created by Hay on 2020/3/4.
//  Copyright © 2020 Toka. All rights reserved.
//


#import "QuotationRefreshSettingController.h"

@implementation QuotationRefreshTimeModel

- (instancetype)initWithTitle:(NSString *)title time:(NSString *)time isSelected:(BOOL)isSelected
{
    if(self = [super init]){
        self.title = title;
        self.time = time;
        self.isSelected = isSelected;
    }
    return self;
}

+ (QuotationRefreshTimeModel *)refreshTimeModelWithTitle:(NSString *)title time:(NSString *)time isSelected:(BOOL)isSelected
{
    QuotationRefreshTimeModel *entity = [[[QuotationRefreshTimeModel alloc] initWithTitle:title time:time isSelected:isSelected] autorelease];

    return entity;
}

- (void)dealloc
{
    [_title release];
    [_time release];
    [super dealloc];
}

@end


@interface QuotationRefreshSettingController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger preIndex;     //之前选中的选项
    NSArray <QuotationRefreshTimeModel *>*tableDataArr;          //显示数据数组
}

/** 懒加载*/
@property (assign, nonatomic) CGFloat optionCellHeight;     //选项cell
@property (retain, nonatomic) IBOutlet UITableView *dataTableView;

@end

@implementation QuotationRefreshSettingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _dataTableView.delegate = self;
    _dataTableView.dataSource = self;
    tableDataArr = [[NSArray alloc] initWithObjects:
                    [QuotationRefreshTimeModel refreshTimeModelWithTitle:[NSString stringWithFormat:NSLocalizedStringForKey(@"每隔%d秒刷新"), 1] time:@"1" isSelected:NO],
                    [QuotationRefreshTimeModel refreshTimeModelWithTitle:[NSString stringWithFormat:NSLocalizedStringForKey(@"每隔%d秒刷新"), 2] time:@"2" isSelected:NO],
                    [QuotationRefreshTimeModel refreshTimeModelWithTitle:[NSString stringWithFormat:NSLocalizedStringForKey(@"每隔%d秒刷新"), 3] time:@"3" isSelected:NO],
                    [QuotationRefreshTimeModel refreshTimeModelWithTitle:[NSString stringWithFormat:NSLocalizedStringForKey(@"每隔%d秒刷新"), 4] time:@"4" isSelected:NO],
                    [QuotationRefreshTimeModel refreshTimeModelWithTitle:[NSString stringWithFormat:NSLocalizedStringForKey(@"每隔%d秒刷新"), 5] time:@"5" isSelected:NO], nil];
    
    NSString *time = [[NSUserDefaults standardUserDefaults] objectForKey:QuotationRefreshTimeSettingKey];
    if(checkIsStringWithAnyText(time)){
        for(int i = 0; i < [tableDataArr count] ; i++){
            QuotationRefreshTimeModel *entity = [tableDataArr objectAtIndex:i];
            if([entity.time isEqualToString:time]){
                entity.isSelected = YES;
                preIndex = i;
                break;
            }
        }
    }
    [_dataTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [ROOTCONTROLLER reloadQuotationRefreshTime];        //通知更新行情刷新时间
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [tableDataArr release];
    [_dataTableView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)optionCellHeight
{
    if(_optionCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"QuotationRefreshTimeCell" owner:nil options:nil] lastObject];
        _optionCellHeight = cell.frame.size.height;
    }
    return _optionCellHeight;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableDataArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.optionCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"QuotationRefreshTimeCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"QuotationRefreshTimeCell" owner:nil options:nil] lastObject];
    }
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    UIImageView *selectedIV = (UIImageView *)[cell viewWithTag:101];
    QuotationRefreshTimeModel *entity = [tableDataArr objectAtIndex:indexPath.row];
    
    titleLabel.text = entity.title;
    selectedIV.hidden = !entity.isSelected;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QuotationRefreshTimeModel *preEntity = [tableDataArr objectAtIndex:preIndex];
    preEntity.isSelected = NO;
    
    QuotationRefreshTimeModel *entity = [tableDataArr objectAtIndex:indexPath.row];
    entity.isSelected = YES;
    preIndex = indexPath.row;
    [[NSUserDefaults standardUserDefaults] setObject:entity.time forKey:QuotationRefreshTimeSettingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [tableView reloadData];
}

@end
