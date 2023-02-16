//
//  HelpCenterListViewController.m
//  ProCoin
//
//  Created by Luo Chun on 2023/1/31.
//  Copyright © 2023 Toka. All rights reserved.
//

#import "HelpCenterListViewController.h"
#import "RZRefreshTableView.h"
#import "NetWorkManage+Home.h"
#import "CommonUtil.h"
#import "PCAnnounceModel.h"
#import "VeDateUtil.h"

@interface HelpCenterListViewController ()<UITableViewDelegate,UITableViewDataSource,RZRefreshTableViewDelegate>
{
    NSInteger pageNo;
    NSMutableArray *announceDataArr;
}

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet RZRefreshTableView *dataTableView;

/** 懒加载*/
@property (assign, nonatomic) CGFloat originAnnounceCellHeight;     //初始cell高度
@end

@implementation HelpCenterListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = NSLocalizedStringForKey(@"帮助中心");
    pageNo = 1;
    announceDataArr = [[NSMutableArray alloc] init];
    [_dataTableView setTableViewDelegate:self];
    [self showProgressDefaultText];
    [self reqHelpListData];
}

- (void)dealloc
{
    [_titleLabel release];
    [announceDataArr release];
    [_dataTableView release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

#pragma mark - 懒加载
- (CGFloat)originAnnounceCellHeight
{
    if(_originAnnounceCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCAnnounceCell" owner:nil options:nil] lastObject];
        _originAnnounceCellHeight = cell.frame.size.height;
    }
    return _originAnnounceCellHeight;
}

#pragma mark - 请求数据
- (void)reqHelpListData
{
    [[NetWorkManage shareSingleNetWork] reqHelpDataList:self pageNo:[NSString stringWithFormat:@"%@",@(pageNo)] finishedCallback:@selector(reqHelpDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqHelpDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *dataArr = [dataDic objectForKey:@"data"];
        if(_dataTableView.dragOrientation){
            [announceDataArr removeAllObjects];
        }
        for(NSDictionary *announceDic in dataArr){
            PCAnnounceModel *entity = [[[PCAnnounceModel alloc] initWithJson:announceDic] autorelease];
            [announceDataArr addObject:entity];
        }
        [_dataTableView reloadData];
        
        if(!_dataTableView.dragOrientation && [dataArr count] == 0){
            [_dataTableView tableViewFooterEndRefreshingWithNoData];
        }else{
            [_dataTableView tableViewEndRefreshing];
        }
    }else{
        [_dataTableView tableViewEndRefreshing];
    }
}

- (void)reqHelpListDataFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [_dataTableView tableViewEndRefreshing];
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [announceDataArr count];
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCAnnounceModel *entity = [announceDataArr objectAtIndex:indexPath.row];
    CGSize size = [CommonUtil getPerfectSizeByText:entity.title andFontSize:16.0 andWidth:SCREEN_WIDTH - 24];
    size.height = MAX(21, size.height);
    return self.originAnnounceCellHeight + (size.height - 21);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PCAnnounceCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PCAnnounceCell" owner:nil options:nil] lastObject];
    }
    PCAnnounceModel *entity = [announceDataArr objectAtIndex:indexPath.row];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:101];
    titleLabel.text = entity.title;
    timeLabel.text = [VeDateUtil formatterDate:entity.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm" isTimestamp:YES];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PCAnnounceModel *entity = [announceDataArr objectAtIndex:indexPath.row];
    TYWebViewController *web = [[TYWebViewController alloc] init];
    web.url = entity.url;
    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
}

- (void)refreshTableViewHeaderRefreshingDidTrigger
{
    pageNo = 1;
    [self reqHelpListData];
}

- (void)refreshTableViewFooterRefreshingDidTrigger
{
    pageNo++;
    [self reqHelpListData];
}

@end
