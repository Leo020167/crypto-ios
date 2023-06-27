//
//  PCTransferCoinController.m
//  ProCoin
//
//  Created by Hay on 2020/2/20.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCTransferCoinController.h"
#import "NetWorkManage+TransferCoin.h"
#import "PCTransferAccountModel.h"
#import "PayAlertView.h"
#import "TextFieldToolBar.h"
#import "SelectCoinController.h"
#import "YYRequestUtility.h"
#import "NetWorkManage+ExtractCoin.h"

@interface PCTransferCoinController () <SelectCoinControllerDelegate>
{
    NSMutableArray *transferAccountDataArr;
    NSArray *coinListArr;   /// 币种
    TextFieldToolBar *toolBar;
}
@property (retain, nonatomic) SelectCoinController *selectController;           //选择币种
@property (copy, nonatomic) NSString *symbol;

@property (copy, nonatomic) NSString *startAccountType; //出发点账户类型
@property (copy, nonatomic) NSString *destAccountType;  //目的点账户类型
@property (copy, nonatomic) NSString *holdAmount;       //当前账户下的数量

@property (retain, nonatomic) IBOutlet UIButton *coinTypeBtn;   //幣

@property (retain, nonatomic) IBOutlet UITextField *amountTF;
@property (retain, nonatomic) IBOutlet UILabel *startLabel;             //出发点账户
@property (retain, nonatomic) IBOutlet UILabel *destLabel;              //目的点账户
@property (retain, nonatomic) IBOutlet UILabel *holdAmountLabel;


@end

@implementation PCTransferCoinController
#pragma mark - 懒加载
- (SelectCoinController *)selectController
{
    if(!_selectController){
        _selectController = [[SelectCoinController alloc] init];
        [_selectController.view setFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _selectController.delegate = self;
    }
    return _selectController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    coinListArr = [[NSArray alloc] init];
    transferAccountDataArr = [[NSMutableArray alloc] init];
    toolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _amountTF.inputAccessoryView = toolBar;
    [_coinTypeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 0.0)];
    [_coinTypeBtn setTitle:@"" forState:0];
    
    //获取可转移的账户类型*/
    [self showProgressDefaultText];
    [self reqTransferAccountList];
}

- (void)dealloc
{
    [transferAccountDataArr release];
    [coinListArr release];
    [_selectController release];
    [_symbol release];
    [toolBar release];
    [_startAccountType release];
    [_destAccountType release];
    [_holdAmount release];
    [_amountTF release];
    [_startLabel release];
    [_destLabel release];
    [_holdAmountLabel release];
    [super dealloc];
}

- (void)bindSymbol:(NSString *)symbol {
    self.symbol = symbol;
    
    [_coinTypeBtn setTitle:symbol forState:0];
    [self getMaxAmount];
}

#pragma mark - 请求数据
/// 获取币种
- (void)reqCoinListData {
    [[NetWorkManage shareSingleNetWork] reqTransferSymbols:self fromAccountType:self.startAccountType toAccountType: self.destAccountType finishedCallback:@selector(reqCoinListDataFinished:) failedCallback:@selector(reqSymbolBaseInfoFailed:)];
    //[[NetWorkManage shareSingleNetWork] reqDepositeWithdrawCoinList:self inOut:@"1" finishedCallback:@selector(reqCoinListDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCoinListDataFinished:(NSDictionary *)json {
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        coinListArr = [[NSArray alloc] initWithArray: (NSArray*) [json objectForKey:@"data"]];
        if (coinListArr.count > 0) {
            [self bindSymbol: [NSString stringWithString: coinListArr.firstObject]];
        }

    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqSymbolBaseInfoFailed:(NSDictionary *)json {
    [self dismissProgress];
}

/// 获取可划转的币种最大值
- (void)getMaxAmount {
    [YYRequestUtility Post:@"account/getSymbolMaxAmount.do" addParameters:@{@"fromAccountType": self.startAccountType, @"symbol": self.symbol} progress:nil success:^(NSDictionary *responseDict) {
        NSLog(@"responseDict : %@", responseDict);
        if ([responseDict[@"code"] intValue] == 200) {
            self.holdAmount = [responseDict objectForKey:@"data"];
            _holdAmountLabel.text = [NSString stringWithFormat:@"%@:%@ %@", NSLocalizedStringForKey(@"可用数量"), self.holdAmount, self.symbol];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}


#pragma mark - 按钮点击事件
/// 翻转账户
- (IBAction)toggleBtnClicked:(id)sender {
    NSString *flag = _startAccountType;
    self.startAccountType = self.destAccountType;
    self.destAccountType = flag;
    
    NSString *text = _startLabel.text;
    _startLabel.text = _destLabel.text;
    _destLabel.text = text;
    [self getMaxAmount];
}


/// 选择币种
- (IBAction)choiseCoinBtnClicked:(id)sender
{
    if([coinListArr count] == 0){
        [self showToastCenter:NSLocalizedStringForKey(@"No coins available for top-up at the moment")];
        return;
    }
    self.selectController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.selectController.view.backgroundColor=[UIColor colorWithWhite:0 alpha:0.4];
    [self.selectController reloadSelectCoinData:coinListArr];
    [self presentViewController:self.selectController animated:YES completion:^{
        
    }];
}


- (IBAction)backgroundViewTouchDown:(id)sender
{
    [_amountTF resignFirstResponder];
}

- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

/** 记录按钮点击事件*/
- (IBAction)recordButtonPressed:(id)sender
{
    [self pageToViewControllerForName:@"PCTransferRecordController"];
}

/** 出发点按钮点击事件*/
- (IBAction)startButtonPressed:(id)sender
{
    if([transferAccountDataArr count] == 0)
        return;
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"账户类型") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for(PCTransferAccountModel *entity in transferAccountDataArr){
        UIAlertAction *action = [UIAlertAction actionWithTitle:entity.accountName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _startLabel.text = entity.accountName;
            if(![self.startAccountType isEqualToString:entity.accountType]){
                self.startAccountType = entity.accountType;
                //出发点每选择一次，重新获取数据
                //[self getMaxAmount];
                [self reqCoinListData];
            }
        }];
        [actionSheet addAction:action];
    }
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

/** 目的点按钮点击事件*/
- (IBAction)destButtonPressed:(id)sender
{
    if([transferAccountDataArr count] == 0)
        return;
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"账户类型") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for(PCTransferAccountModel *entity in transferAccountDataArr){
        UIAlertAction *action = [UIAlertAction actionWithTitle:entity.accountName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _destLabel.text = entity.accountName;
            self.destAccountType = entity.accountType;
            [self reqCoinListData];
        }];
        [actionSheet addAction:action];
    }
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)allAmountButtonPressed:(id)sender
{
    if(checkIsStringWithAnyText(self.holdAmount)){
        _amountTF.text = self.holdAmount;
    }else{
        _amountTF.text = @"0";
    }
    
}

- (IBAction)transferAccountButtonPressed:(id)sender
{
    [_amountTF resignFirstResponder];
    if([self.startAccountType isEqualToString:self.destAccountType]){
        [self showToastCenter:NSLocalizedStringForKey(@"同种类型账户不能进行划转！请重新选择.")];
        return;
    }
    if([_amountTF.text doubleValue] <= 0){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入划转的数量")];
        return;
    }
//    if([_amountTF.text doubleValue] > [self.holdAmount doubleValue]){
//        [self showToastCenter:NSLocalizedStringForKey(@"划转数量不能超过可用数量.")];
//        return;
//    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:[NSString stringWithFormat:NSLocalizedStringForKey(@"确定要从\"%@\"划转数量%@%@到\"%@\"吗？"),self.startLabel.text,_amountTF.text,self.symbol,self.destLabel.text] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self showProgressDefaultText];
        [self reqAccountTransfer:@""];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];

}



#pragma mark - 请求数据
- (void)reqTransferAccountList
{
    [[NetWorkManage shareSingleNetWork] reqTransferAccountList:self finishedCallback:@selector(reqTransferAccountListFinished:) failedCallback:@selector(reqTransferAccountListFinished:)];
}

- (void)reqTransferAccountListFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        [transferAccountDataArr removeAllObjects];
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *accountTypeList = [dataDic objectForKey:@"accountTypeList"];
        for(NSDictionary *dic in accountTypeList){
            PCTransferAccountModel *accountEntity = [[[PCTransferAccountModel alloc] initWithJson:dic] autorelease];
            [transferAccountDataArr addObject:accountEntity];
        }
        if([transferAccountDataArr count] >= 2){
            PCTransferAccountModel *startEntity = [transferAccountDataArr firstObject];
            PCTransferAccountModel *destEntity = [transferAccountDataArr objectAtIndex:1];
            self.startAccountType = startEntity.accountType;
            self.destAccountType = destEntity.accountType;
            _startLabel.text = startEntity.accountName;
            _destLabel.text = destEntity.accountName;
        }
        //获取一次持有数量
        //[self getMaxAmount];
        [self reqCoinListData];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqAccountTransfer:(NSString *)payPass
{
    [[NetWorkManage shareSingleNetWork] reqAccountTransfer:self amount:_amountTF.text symbol: self.symbol fromAccountType:self.startAccountType toAccountType:self.destAccountType payPass:payPass finishedCallback:@selector(reqAccountTransferFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqAccountTransferFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"操作成功");
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        //重新获取数据
        [self getMaxAmount];
    }else{
        if([self checkIsNeedTradePassword:json]){          //需要输入交易密码
            PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
            [payAlertView show];
        }else if([self checkIsNotEnoughCash:json]){         //不够资金
            NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }else if(![self checkIsNeedSetTradePassword:json]){     //不需要设置交易密码
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
    }
}

#pragma mark - SelectCoinController delegate
- (void)selectCoinDidSelctedWithSymol:(NSString *)symbol {
    [self bindSymbol:symbol];
    
}


#pragma mark - payAlertView delegate
- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password
{
    if (password.length>0) {
        [self reqAccountTransfer:password];
        [toolView close];
    }else{
        [toolView reset];
    }
}

#pragma mark - TextFieldToolBar delegate
- (void)TFDonePressed
{
    [_amountTF resignFirstResponder];
}
@end
