//
//  FundWithdrawManagerController.m
//  Cropyme
//
//  Created by Hay on 2019/5/15.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FundWithdrawManagerController.h"
#import "NetWorkManage+Trade.h"
#import "CommonUtil.h"
#import "OwnReceiptEntity.h"
#import "RZWebImageView.h"
#import "PayAlertView.h"

@interface FundWithdrawManagerController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *tableData;
    NSInteger operationIndex;           //操作索引
    BOOL isWithdrawPageTo;              //是否从提现页面跳过来，这样可以选择收款方式
    BOOL isPopAddAccountAlert;          //是否已经弹过没添加收款方式的alert view
}

@property (assign, nonatomic) CGFloat managerCellheight;
@property (retain, nonatomic) IBOutlet UITableView *dataTableView;
@property (retain, nonatomic) IBOutlet UIButton *addModeButton;
@property (retain, nonatomic) IBOutlet UIView *tipsView;            //没数据提示页面

@end

@implementation FundWithdrawManagerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([self getValueFromModelDictionary:FundExchangeDic forKey:@"FundWithdrawManagerIsWithdrawPageTo"]){
        isWithdrawPageTo = YES;
        [self removeParamFromModelDictionary:FundExchangeDic forKey:@"FundWithdrawManagerIsWithdrawPageTo"];
    }else{
        isWithdrawPageTo = NO;
    }
    isPopAddAccountAlert = NO;
    tableData = [[NSMutableArray alloc] init];
    _dataTableView.delegate = self;
    _dataTableView.dataSource = self;
    [_addModeButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(255, 143, 1, 1.0)] forState:UIControlStateNormal];
    [self showProgressDefaultText];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reqUserOwnReceiptList];
}

- (void)dealloc
{
    [tableData release];
    [_dataTableView release];
    [_addModeButton release];
    [_tipsView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)managerCellheight
{
    if(_managerCellheight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FundWithdrawManagerCell" owner:nil options:nil] lastObject];
        _managerCellheight = cell.frame.size.height;
    }
    return _managerCellheight;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)addWithdrawButtonPressed:(id)sender
{
    [self pageToViewControllerForName:@"FundWithdrawWayListController"];
}

- (void)deleteReceiptWayButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    UITableViewCell *cell = [CommonUtil getTableViewCellWithContainView:targetButton];
    operationIndex = [_dataTableView indexPathForCell:cell].row;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"是否删除该收款方式?") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqDeleteReceiptWay:@""];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)setDefaultButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    UITableViewCell *cell = [CommonUtil getTableViewCellWithContainView:targetButton];
    operationIndex = [_dataTableView indexPathForCell:cell].row;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"是否设置该收款方式为默认收款方式?") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqSetDefaultReceiptWay];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 请求数据
- (void)reqUserOwnReceiptList
{
    [[NetWorkManage shareSingleNetWork] reqUserReceiptList:self finishedCallback:@selector(reqUserOwnReceiptListFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqUserOwnReceiptListFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        [tableData removeAllObjects];
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *receiptListArr = [dataDic objectForKey:@"receiptList"];
        for(NSDictionary *receiptDic in receiptListArr){
            OwnReceiptEntity *entity = [[[OwnReceiptEntity alloc] initWithJson:receiptDic] autorelease];
            [tableData addObject:entity];
        }
        if([tableData count] == 0){
            _dataTableView.hidden = YES;
            _tipsView.hidden = NO;
            if(!isPopAddAccountAlert){          //如果之前没弹过，就弹出
                isPopAddAccountAlert = YES;
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"您还未添加收款方式，是否要去添加一个？") preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [self pageToViewControllerForName:@"FundWithdrawWayListController"];
                }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
           
        }else{
            _dataTableView.hidden = NO;
            _tipsView.hidden = YES;
        }
        [_dataTableView reloadData];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 删除收款方式*/
- (void)reqDeleteReceiptWay:(NSString *)payPass
{
    [self showProgressDefaultText];
    OwnReceiptEntity *entity = [tableData objectAtIndex:operationIndex];
    [[NetWorkManage shareSingleNetWork] reqDeleteReceiptWay:self receiptId:entity.receiptId payPass:payPass finishedCallback:@selector(reqDeleteReceiptWayFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqDeleteReceiptWayFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"删除成功")];
        }
        
        [tableData removeObjectAtIndex:operationIndex];
        [_dataTableView reloadData];
        
        if([tableData count] == 0){
            _dataTableView.hidden = YES;
            _tipsView.hidden = NO;
        }else{
            _dataTableView.hidden = NO;
            _tipsView.hidden = YES;
        }
    }else{
        if([self checkIsNeedTradePassword:json]){          //需要输入交易密码
            PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
            [payAlertView show];
        }else if(![self checkIsNeedSetTradePassword:json]){     //不需要设置交易密码
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
        
    }
}

/** 设置默认收款方式*/
- (void)reqSetDefaultReceiptWay
{
    [self showProgressDefaultText];
    OwnReceiptEntity *entity = [tableData objectAtIndex:operationIndex];
    [[NetWorkManage shareSingleNetWork] reqSetDefaultReceipt:self receiptId:entity.receiptId finishedCallback:@selector(reqSetDefaultReceiptWayFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqSetDefaultReceiptWayFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"设置成功")];
        }
        for(int i = 0; i < [tableData count]; i++){
            OwnReceiptEntity *entity = [tableData objectAtIndex:i];
            if(entity.isDefault){
                entity.isDefault = NO;
                break;
            }
        }
        OwnReceiptEntity *entity = [tableData objectAtIndex:operationIndex];
        entity.isDefault = YES;
        [_dataTableView reloadData];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}


#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.managerCellheight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *managerCellIdentifier = @"FundWithdrawManagerCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:managerCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FundWithdrawManagerCell" owner:nil options:nil] lastObject];
        UIButton *deleteButton = (UIButton *)[cell viewWithTag:103];
        [deleteButton addTarget:self action:@selector(deleteReceiptWayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *setDefaultButton = (UIButton *)[cell viewWithTag:104];
        [setDefaultButton addTarget:self action:@selector(setDefaultButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    RZWebImageView *receiptLogo = (RZWebImageView *)[cell viewWithTag:100];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:102];
    UIButton *setDefaultButton = (UIButton *)[cell viewWithTag:104];
    UILabel *defaultTitleLabel = (UILabel *)[cell viewWithTag:105];
    
    OwnReceiptEntity *entity = [tableData objectAtIndex:indexPath.row];
    [receiptLogo showImageWithUrl:entity.receiptTypeLogo];
    nameLabel.text = entity.receiptName;
    if(entity.receiptType == 1 || entity.receiptType == 2){
        titleLabel.text = entity.receiptNo;
    }else if(entity.receiptType == 3){
        NSString *simpleNo = @"";
        if(entity.receiptNo.length > 4){
            simpleNo = [entity.receiptNo substringWithRange:NSMakeRange(entity.receiptNo.length - 4, 4)];
        }else{
            simpleNo = entity.receiptNo;
        }
        titleLabel.text = [NSString stringWithFormat:@"%@(%@)",entity.bankName,simpleNo];
    }
    if(entity.isDefault){
        defaultTitleLabel.hidden = NO;
        setDefaultButton.hidden = YES;
    }else{
        defaultTitleLabel.hidden = YES;
        setDefaultButton.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isWithdrawPageTo){
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(isWithdrawPageTo){           //充值页面点击进来，点击cell即为选择收款方式
        OwnReceiptEntity *entity = [tableData objectAtIndex:indexPath.row];
        [self putValueToParamDictionary:FundExchangeDic value:entity forKey:@"FundWithdrawReceiptEntity"];
        [self goBack];
    }
}

#pragma mark - payAlertView delegate
- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password
{
    if (password.length>0) {
        [self reqDeleteReceiptWay:password];
        [toolView close];
    }else{
        [toolView reset];
    }
}

@end
