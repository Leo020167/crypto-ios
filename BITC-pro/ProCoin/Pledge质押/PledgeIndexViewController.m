//
//  PledgeIndexViewController.m
//  ProCoin
//
//  Created by Luo Chun on 2022/11/8.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "PledgeIndexViewController.h"
#import "PledgeIndexCell.h"
#import "PledgeRecordViewController.h"
#import "PledgeBuyViewController.h"
#import "NetWorkManage+ExtractCoin.h"
#import "YYRequestUtility.h"

@interface PledgeIndexViewController ()<UITableViewDelegate, UITableViewDataSource> {
    
}

@property (nonatomic, strong) NSMutableArray *coinsArray;

@property (retain, nonatomic) IBOutlet UITableView *table;
@end

@implementation PledgeIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorMakeWithHex(@"#F4F6F4");
    self.coinsArray = [NSMutableArray array];
    //[_coinsArray addObject:@{@"a": @"b"}];
//    [_table registerClass:[PledgeIndexCell class] forCellReuseIdentifier:NSStringFromClass([PledgeIndexCell class])];
    [self getList];
}

- (void)getList {
    [YYRequestUtility Post:@"pledge/list.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        [self.coinsArray removeAllObjects];
        if ([responseDict[@"code"] intValue] == 200) {
//            for (NSArray *items in responseDict[@"data"]) {
//                [self.coinsArray addObjectsFromArray:items];
//            }
            self.coinsArray = responseDict[@"data"];
            [self.table reloadData];
        } else {
            [QMUITips showError:responseDict[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        
    }];

}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)record {
    PledgeRecordBaseViewController *purchase = [[PledgeRecordBaseViewController alloc] init];
    [QMUIHelper.visibleViewController.navigationController pushViewController:purchase animated:YES];
}

#pragma mark - table view delegate and data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 10)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 178;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    PledgeIndexCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PledgeIndexCell"];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PledgeIndexCell" owner:nil options:nil] lastObject];
    }
        cell.model = _coinsArray[indexPath.row];
    __block typeof(self) weakSelf = self;
    [cell setClickActionBlock:^(NSDictionary * _Nonnull model) {
        PledgeBuyViewController *screenView = [[[PledgeBuyViewController alloc] init] autorelease];
        //screenView.delegate = self;
        screenView.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [screenView addSelfToParentViewController:weakSelf pledge: model];
    }];

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.coinsArray.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}



@end


