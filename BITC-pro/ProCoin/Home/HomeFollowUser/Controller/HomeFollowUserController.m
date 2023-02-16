//
//  HomeFollowUserController.m
//  Cropyme
//
//  Created by Hay on 2019/5/7.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "HomeFollowUserController.h"
#import "NetWorkManage+Home.h"
#import "RZWebImageView.h"
#import "PCHomeFollowUserModel.h"
#import "VeDateUtil.h"
#import "CommonUtil.h"

@interface HomeFollowUserController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *tableData;
}

@property (assign, nonatomic) CGFloat followUserInfoCellHeight;
@property (retain, nonatomic) UIView *followUserHeaderView;
@property (retain, nonatomic) IBOutlet UITableView *dataTableView;
@property (retain, nonatomic) IBOutlet UIView *noDataView;          //无数据提示


@end

@implementation HomeFollowUserController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _dataTableView.delegate = self;
    _dataTableView.dataSource = self;
    self.followUserInfoCellHeight = 0.0;
    tableData = [[NSMutableArray alloc] init];
    _noDataView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //登陆之后才能进行查看操作
    if(checkIsStringWithAnyText(ROOTCONTROLLER_USER.userId)){
        if([tableData count] == 0){
            [self showProgressDefaultText];
        }
        [self reqFollowUsersData];
    }
    
}

- (void)dealloc
{
    [tableData release];
    [_followUserHeaderView release];
    [_dataTableView release];
    [_noDataView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)followUserInfoCellHeight
{
    if(_followUserInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeFollowUserInfoCell" owner:nil options:nil] lastObject];
        _followUserInfoCellHeight = cell.frame.size.height;
    }
    return _followUserInfoCellHeight;
}

- (UIView *)followUserHeaderView
{
    if(!_followUserHeaderView){
        _followUserHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"PCHomeFollowUserHeaderView" owner:nil options:nil] lastObject] retain];
    }
    return _followUserHeaderView;
}

#pragma mark - 搜索按钮点击事件
- (IBAction)searchButtonPressed:(id)sender
{
    [self pageToViewControllerForName:@"SearchUserController"];
}

/** 续费按钮点击事件*/
- (void)subscribeButtonPressed:(UIButton *)sender
{
    UITableViewCell *cell = [CommonUtil getTableViewCellWithContainView:sender];
    NSIndexPath *indexPath = [_dataTableView indexPathForCell:cell];
     PCHomeFollowUserModel *userEntity = [tableData objectAtIndex:indexPath.row];
    [self putValueToParamDictionary:ProCoinBaseDict value:userEntity.userId forKey:@"PersonalMainTargetUid"];
    [self pageToViewControllerForName:@"PersonalMainController"];
    
}

#pragma mark - 请求数据
- (void)reqFollowUsersData
{
    [[NetWorkManage shareSingleNetWork] reqHomeFollowUsers:self finishedCallback:@selector(reqFollowUsersDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqFollowUsersDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSArray *dataArr = [json objectForKey:@"data"];
        [tableData removeAllObjects];
        for(NSDictionary *dic in dataArr){
            PCHomeFollowUserModel *entity = [[[PCHomeFollowUserModel alloc] initWithJson:dic] autorelease];
            [tableData addObject:entity];
        }
        [_dataTableView reloadData];
        
        if([tableData count] == 0){
            _noDataView.hidden = NO;
            _dataTableView.hidden = YES;
        }else{
            _noDataView.hidden = YES;
            _dataTableView.hidden = NO;
        }
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

#pragma mark - table view data source and delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([tableData count] > 0){
        return self.followUserHeaderView.frame.size.height;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if([tableData count] > 0){
        return self.followUserHeaderView;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.followUserInfoCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *followUserCellIdentifier = @"PCHomeFollowUserInfoCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:followUserCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PCHomeFollowUserInfoCell" owner:nil options:nil] lastObject];
        UIButton *subButton = (UIButton *)[cell viewWithTag:103];
        [subButton addTarget:self action:@selector(subscribeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    PCHomeFollowUserModel *userEntity = [tableData objectAtIndex:indexPath.row];
    RZWebImageView *headLogoIV = (RZWebImageView *)[cell viewWithTag:100];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *daysLabel = (UILabel *)[cell viewWithTag:102];
    UIButton *subButton = (UIButton *)[cell viewWithTag:103];
    
    UILabel *timeTipsLabel = (UILabel *)[cell viewWithTag:104];
    [headLogoIV showHeaderImageViewWithUrl:userEntity.headUrl];
    nameLabel.text = userEntity.userName;
    daysLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"已入驻%@天"),userEntity.days];
    if(userEntity.subIsFee){
        [subButton setTitle:NSLocalizedStringForKey(@"续费") forState:UIControlStateNormal];
        timeTipsLabel.hidden = NO;
        if(userEntity.isExpireTime){
               timeTipsLabel.text = NSLocalizedStringForKey(@"订阅已过期");
               timeTipsLabel.textColor = [UIColor redColor];
           }else{
               timeTipsLabel.text = [VeDateUtil formatterDate:userEntity.expireTime inStytle:nil outStytle:[NSString stringWithFormat:@"%@:yyyy-MM-dd", NSLocalizedStringForKey(@"到期")] isTimestamp:YES];
               timeTipsLabel.textColor = RGBA(29, 49, 85, 1.0);
           }
    }else{
        [subButton setTitle:NSLocalizedStringForKey(@"已订阅") forState:UIControlStateNormal];
        timeTipsLabel.hidden = YES;
        
    }
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PCHomeFollowUserModel *entity = [tableData objectAtIndex:indexPath.row];
    [self putValueToParamDictionary:ProCoinBaseDict value:entity.userId forKey:@"PersonalMainTargetUid"];
    [self pageToViewControllerForName:@"PersonalMainController"];
}


@end
