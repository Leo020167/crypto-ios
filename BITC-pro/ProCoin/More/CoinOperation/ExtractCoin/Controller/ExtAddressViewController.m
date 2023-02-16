//
//  ExtAddressViewController.m
//  ProCoin
//
//  Created by Luo Chun on 2022/11/24.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "ExtAddressViewController.h"
#import "ExtAddressCell.h"
#import "YYRequestUtility.h"
#import "PayAlertView.h"

@interface ExtAddressViewController () <UITableViewDelegate, UITableViewDataSource, PayAlertViewDelegate> {}

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *navRightBtn;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSString *toDeleteAddrId;

@end

@implementation ExtAddressViewController

- (void)dealloc {
    
    [_titleLabel release];
    [_navRightBtn release];
    [_tableView release];
    [_dataSource release];
    [_toDeleteAddrId release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_symbol != nil) {
        [_navRightBtn setHidden:YES];
        _titleLabel.text = NSLocalizedStringForKey(@"提币地址管理");
    } else {
        _titleLabel.text = NSLocalizedStringForKey(@"提币地址管理");
    }
    self.dataSource = [[NSMutableArray alloc] init];
}

- (void)getData {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (_symbol != nil) {
        param[@"symbol"] = _symbol;
    }
    if (_chainType != nil) {
        param[@"chainType"] = _chainType;
    }
    [YYRequestUtility Post:@"depositeWithdraw/addressList.do" addParameters:param progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            self.dataSource = [[NSMutableArray alloc] initWithArray: responseDict[@"data"]];
            [self.tableView reloadData];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)deleteAddr: (NSString *)payPass {
    if (!_toDeleteAddrId) return ;
    [YYRequestUtility Post:@"depositeWithdraw/delAddress.do" addParameters:@{@"addressId": _toDeleteAddrId, @"payPass": payPass} progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            for (NSDictionary *obj in self.dataSource) {
                if ([obj[@"id"] isEqualToString: _toDeleteAddrId]) {
                    [self.dataSource removeObject:obj];
                }
            }
            _toDeleteAddrId = nil;
            [self.tableView reloadData];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)add {
    [self pageToViewControllerForName:@"ExtNewAddressViewController"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 15)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ExtAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExtAddressCell"];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ExtAddressCell" owner:nil options:nil] lastObject];
    }
    cell.model = [[NSDictionary alloc] initWithDictionary: _dataSource[indexPath.row]];
    cell.isManager = (_symbol == nil);
    cell.deleteBlock = ^(NSDictionary * _Nonnull model) {
        self.toDeleteAddrId = [model[@"id"] stringValue];
        PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
        [payAlertView show];
        
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    if (_symbol != nil) {
        NSDictionary *info = [[NSDictionary alloc] initWithDictionary: _dataSource[indexPath.row]];
        [self.delegate extAddressViewDidSelected: info];
        [self goBack];
    }
    
    
}


#pragma mark - payAlertView delegate
- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password
{
    if (password.length>0) {
        [self deleteAddr:password];
        [toolView close];
    }else{
        [toolView reset];
    }
}

//- (void)payAlertView:(PayAlertView *)toolView forgetButtonClicked:(id)sender {
//
//}


@end
