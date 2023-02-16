//
//  P2PBankWayController.m
//  ProCoin
//
//  Created by UnWood on 2021/4/6.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "P2PBankWayController.h"
#import "RZRefreshTableView.h"
#import "NetWorkManage+P2P.h"
#import "TJRBaseParserJson.h"
#import "RZWebImageView.h"
#import "CommonUtil.h"
#import "P2PPaymentEntity.h"
#import "BankWayAlertView.h"

@interface P2PBankWayController () <BankWayAlertViewDelegate>{
    BOOL bReqFinished;

    NSMutableArray* tableData;
}

@property (retain, nonatomic) IBOutlet RZRefreshTableView *refreshTableView;
@property (retain, nonatomic) IBOutlet UIView *tipsView;
@property (retain, nonatomic) BankWayAlertView *bankWayAlertView;

@property (assign, nonatomic) NSInteger selectedRow;
@end

@implementation P2PBankWayController

- (void)viewDidLoad {
    [super viewDidLoad];
    bReqFinished = YES;

    tableData = [[NSMutableArray alloc] init];
    [_refreshTableView setTableViewDelegate:self];
    [_refreshTableView tableViewFooterRefreshViewHidden];
    
    [CommonUtil setExtraCellLineHidden:_refreshTableView];

    self.selectedRow = -1;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self refreshTableViewHeaderRefreshingDidTrigger];
}

- (void)dealloc{

    [_bankWayAlertView release];
    [tableData release];
    [_refreshTableView release];
    [_tipsView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (BankWayAlertView *)bankWayAlertView
{
    if(!_bankWayAlertView){
        _bankWayAlertView= [[[[NSBundle mainBundle] loadNibNamed:@"BankWayAlertView" owner:nil options:nil] lastObject] retain];
        _bankWayAlertView.delegate = self;
    }
    return _bankWayAlertView;
}


#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)createBtnClicked:(id)sender {
    [self.bankWayAlertView showInView:self.view];
}

#pragma mark - 【收款方式】获取我的收款方式列表
- (void)reqFindMyPaymentList
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PFindMyPaymentList:self finishedCallback:@selector(reqPaymentListFinished:) failedCallback:@selector(reqPaymentListFailed:)];
    }
    
}

- (void)reqPaymentListFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        NSDictionary *dataDic = [result objectForKey:@"data"];
        
        NSArray *list = [dataDic objectForKey:@"myPaymentList"];
        
        NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
        for(NSDictionary *dic in list){
            P2PPaymentEntity *entity = [[[P2PPaymentEntity alloc] initWithJson:dic]autorelease];
            [array addObject:entity];
        }
        
        if([_refreshTableView dragOrientation]){
            [_refreshTableView tableViewEndRefreshing];
            [tableData removeAllObjects];
        }else{
            [_refreshTableView tableViewFooterEndRefreshingWithNoData];
        }
        [tableData addObjectsFromArray:array];
        
        if (array.count <  [parser integerParser:dataDic name:@"pageSize"]) {
            [_refreshTableView tableViewFooterEndRefreshingWithNoData];
        }
        
    }else{
        [_refreshTableView tableViewEndRefreshing];
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
    [_refreshTableView reloadData];
    
    if (tableData.count>0) {
        _tipsView.hidden = YES;
        _refreshTableView.hidden = NO;
    }else {
        _tipsView.hidden = NO;
        _refreshTableView.hidden = YES;
    }
}

- (void)reqPaymentListFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
    [_refreshTableView tableViewEndRefreshing];
}

#pragma mark - 【收款方式】删除我的收款方式
- (void)reqPaymentDelete:(NSString*)paymentId
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PPaymentDelete:self paymentId:paymentId  finishedCallback:@selector(reqPaymentDeleteFinished:) failedCallback:@selector(reqPaymentDeleteFailed:)];
    }
    
}

- (void)reqPaymentDeleteFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_SUCCEED];
        
        if (_selectedRow != -1) {
            [tableData removeObjectAtIndex:_selectedRow];
            NSIndexPath *path = [NSIndexPath indexPathForRow:_selectedRow inSection:0];
            NSArray *array = [NSArray arrayWithObject:path];
            [_refreshTableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
        }

        if([tableData count] == 0){
            _tipsView.hidden = NO;
            _refreshTableView.hidden = YES;
        }
    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

- (void)reqPaymentDeleteFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

#pragma mark -
#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"P2PBankWayCell" owner:nil options:nil] lastObject];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"P2PBankWayCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"P2PBankWayCell" owner:nil options:nil] lastObject];
    }
    P2PPaymentEntity *entity = [tableData objectAtIndex:indexPath.row];

    UILabel *lbReceiptTypeValue = (UILabel *)[cell viewWithTag:100];
    lbReceiptTypeValue.text = [NSString stringWithFormat:@"%@",entity.receiptTypeValue];

    UILabel *lbReceiptName= (UILabel *)[cell viewWithTag:101];
    lbReceiptName.text = [NSString stringWithFormat:@"%@",entity.receiptName];

    UILabel *lbReceiptNo = (UILabel *)[cell viewWithTag:102];
    lbReceiptNo.text = [NSString stringWithFormat:@"%@",entity.receiptNo];
    
    RZWebImageView* headView = (RZWebImageView*)[cell viewWithTag:200];
    [headView showImageWithUrl:entity.receiptLogo];

    return cell;
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedStringForKey(@"删除");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!TTIsArrayWithItems(tableData)) return;
    
    P2PPaymentEntity *entity = [tableData objectAtIndex:indexPath.row];
    [self putValueToParamDictionary:P2PDict value:entity forKey:@"paymentEntity"];
    [self pageToOrBackWithName:@"P2PCreateBankController"];
}

- (void)refreshTableViewHeaderRefreshingDidTrigger{
    _refreshTableView.pageNo = 1;

    [self reqFindMyPaymentList];
}

- (void)refreshTableViewFooterRefreshingDidTrigger{
    _refreshTableView.pageNo = _refreshTableView.pageNo + 1;

}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleNone:
            break;
        case UITableViewCellEditingStyleDelete:
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"确定要删除选中的收款方式吗?") preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                self.selectedRow = indexPath.row;
                P2PPaymentEntity *entity = [tableData objectAtIndex:indexPath.row];
                [self reqPaymentDelete:entity.paymentId];
               
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
            break;
        case UITableViewCellEditingStyleInsert:
            break;
        default:
            break;
    }
}

#pragma mark - BankWayAlertView delegate
- (void)p2pView:(BankWayAlertView *)alertView alipayButtonClicked:(id)sender {
    [self putValueToParamDictionary:P2PDict value:@"1" forKey:@"receiptType"];
    [self putValueToParamDictionary:P2PDict value:@"0" forKey:@"paymentId"];
    [self pageToOrBackWithName:@"P2PCreateBankController"];
}

- (void)p2pView:(BankWayAlertView *)alertView bankButtonClicked:(id)sender {
    [self putValueToParamDictionary:P2PDict value:@"3" forKey:@"receiptType"];
    [self putValueToParamDictionary:P2PDict value:@"0" forKey:@"paymentId"];
    [self pageToOrBackWithName:@"P2PCreateBankController"];
}

- (void)p2pView:(BankWayAlertView *)alertView wechatpayButtonClicked:(id)sender {
    [self putValueToParamDictionary:P2PDict value:@"2" forKey:@"receiptType"];
    [self putValueToParamDictionary:P2PDict value:@"0" forKey:@"paymentId"];
    [self pageToOrBackWithName:@"P2PCreateBankController"];
}

@end
