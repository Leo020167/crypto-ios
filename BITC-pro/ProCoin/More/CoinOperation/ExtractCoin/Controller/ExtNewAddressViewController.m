//
//  ExtNewAddressViewController.m
//  ProCoin
//
//  Created by Luo Chun on 2022/11/24.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "ExtNewAddressViewController.h"
#import "UIView+General.h"
#import "NetWorkManage+ExtractCoin.h"
#import "ExtractCoinDataEntity.h"
#import "RZWebImageView.h"
#import "CommonUtil.h"
#import "CoinOperationInfoEntity.h"
#import "UIImage+Size.h"
#import "SelectCoinController.h"
#import "CoinRechargeViewController.h"
#import "MTDashLine.h"
#import "YYRequestUtility.h"
#import "PayAlertView.h"

@interface ExtNewAddressViewController () <SelectCoinControllerDelegate, UITextFieldDelegate, PayAlertViewDelegate> {
    NSArray *coinListArr;
    NSArray *chainTypeListArr;
}
@property (retain, nonatomic) CoinOperationInfoEntity *infoEntity;
@property (retain, nonatomic) SelectCoinController *selectController;           //选择币种

@property (retain, nonatomic) IBOutlet UIView *cardView;
@property (retain, nonatomic) IBOutlet UIButton *coinTypeBtn;   //幣
@property (retain, nonatomic) IBOutlet UIView *typeView;
@property (retain, nonatomic) IBOutlet UIView *optionView;

@property (retain, nonatomic) IBOutlet UITextField *addressField;
@property (retain, nonatomic) IBOutlet UIButton *pasteBtn;

@property (retain, nonatomic) IBOutlet UITextField *descField;

@property (retain, nonatomic) IBOutlet UIButton *okBtn;

@property (retain, nonatomic) NSString *symbol;
@property (retain, nonatomic) NSString *chainType;
@end

@implementation ExtNewAddressViewController


- (void)dealloc
{
    [_cardView release];
    [_coinTypeBtn release];
    [_selectController release];
    [_typeView release];
    [_addressField release];
    [_pasteBtn release];
    [_descField release];
    [_okBtn release];
    
    [super dealloc];
}

- (void)viewDidLayoutSubviews {
    
    [[self.view viewWithTag:800] applyShadow];
    [_pasteBtn applyRadiusMask:14 bottomLeft:14 bottomRight:6 topRight:6];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _addressField.delegate = self;
    _descField.delegate = self;
    [_coinTypeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 0.0)];
    coinListArr = [[NSArray alloc] init];
    chainTypeListArr = [[NSArray alloc] init];
    [self reqCoinListData];
}

- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (void)bindChainTypeView {
    if ([_symbol.uppercaseString isEqualToString: @"USDT"]) {
        [self.typeView setHidden:NO];
    } else {
        [self.typeView setHidden:YES];
        return;
    }
    
    [_optionView qmui_removeAllSubviews];
    CGFloat width = 68;
    CGFloat height = 30;
    CGFloat tap = 8;
    for(int i = 0; i < chainTypeListArr.count; i++){
        NSString *string = chainTypeListArr[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(optionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1000 + i;
        button.titleLabel.font = UIFontMake(14);
        [button setFrame:CGRectMake(0.0 + (tap + width) * i , 0.0, width, height)];
        [button setTitle:string forState:UIControlStateNormal];
        [button setTitleColor:UIColorMakeWithHex(@"#00BAB8") forState: UIControlStateNormal];
        [button setTitleColor:UIColorMakeWithHex(@"#ffffff") forState: UIControlStateSelected];
        [button setBackgroundImage:[UIImage qmui_imageWithColor:UIColorMakeWithHex(@"#ffffff")] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage qmui_imageWithColor:UIColorMakeWithHex(@"#00BAB8")] forState:UIControlStateSelected];
        if(i == 0){
            _chainType = chainTypeListArr.firstObject;
            [self updateButtonWithSelectedState:button];
            button.selected = YES;
        }else{
            [self updateButtonWithNormalState:button];
            button.selected = NO;
        }
        [_optionView addSubview:button];
    }
}

- (void)optionsButtonPressed:(UIButton *)sender
{
    if(sender.isSelected){
        return;
    }
    NSInteger tag = sender.tag - 1000;
    sender.selected = YES;
    _chainType = chainTypeListArr[tag];
    [self updateButtonWithSelectedState:sender];
    for(int i = 0; i < chainTypeListArr.count; i++){
        if(i == tag )
            continue;
        UIButton *button = (UIButton *)[_optionView viewWithTag: 1000 + i];
        button.selected = NO;
        [self updateButtonWithNormalState:button];
    }
}

#pragma mark - 设置按钮状态
- (void)updateButtonWithSelectedState:(UIButton *)button
{
    [button setTitleColor:UIColorMakeWithHex(@"#00BAB8") forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    //button.layer.borderColor = RGBA(97, 117, 174, 1.0).CGColor;
    button.layer.borderWidth = 0;
}

- (void)updateButtonWithNormalState:(UIButton *)button
{
    [button setTitleColor:UIColorMakeWithHex(@"#00BAB8") forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    button.layer.borderColor = UIColorMakeWithHex(@"#00BAB8").CGColor;
    button.layer.borderWidth = 1.0;
}


-(IBAction)coinSelect:(UIButton *)sender {
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


#pragma mark - SelectCoinController delegate
- (void)selectCoinDidSelctedWithSymol:(NSString *)symbol
{
    self.symbol = symbol;
    //_symbolLabel.text = symbol;
    [_coinTypeBtn setTitle:symbol forState:0];
    [self bindChainTypeView];
}


#pragma mark - 请求数据
- (void)reqCoinListData
{
    [[NetWorkManage shareSingleNetWork] reqDepositeWithdrawCoinList:self inOut:@"1" finishedCallback:@selector(reqCoinListDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCoinListDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        coinListArr = [[NSArray alloc] initWithArray: (NSArray*) [dataDic objectForKey:@"coinList"]];
        chainTypeListArr = [[NSArray alloc] initWithArray: (NSArray*) [dataDic objectForKey:@"chainTypeList"]];
        if (coinListArr.count > 0) {
            [_coinTypeBtn setTitle:[coinListArr.firstObject stringValue] forState:0];
        }
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}


- (void)reqSymbolBaseInfoFailed:(NSDictionary *)json
{
    [self dismissProgress];
    
}

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


-(IBAction)pasteAddress:(id)sender {
    _addressField.text = [UIPasteboard generalPasteboard].string;
}

-(IBAction)save:(id)sender {

    NSString *addr = _addressField.text;
    if (addr.length <= 0) {
        [QMUITips showInfo:_addressField.placeholder];
    }
    NSString *remark = _descField.text;
    if (remark.length <= 0) {
        [QMUITips showInfo:_descField.placeholder];
    }
    PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
    [payAlertView show];

}

-(void)reqSave:(NSString *)payPass {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if ([_coinTypeBtn titleForState:0].length > 0) {
        NSString *symbol = [_coinTypeBtn titleForState:0];
        param[@"symbol"] = symbol;
        if ([symbol.uppercaseString isEqualToString: @"USDT"]) {
            param[@"chainType"] = _chainType;
        }
    }
    NSString *addr = _addressField.text;
    if (addr.length > 0) {
        param[@"address"] = addr;
    } else {
        [QMUITips showError:@"msg"];
    }
    NSString *remark = _descField.text;
    if (remark.length > 0) {
        param[@"remark"] = remark;
    } else {
        [QMUITips showError:@"msg"];
    }
    param[@"payPass"] = payPass;
    [YYRequestUtility Post:@"depositeWithdraw/addAddress.do" addParameters:param progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            [QMUITips showSucceed:responseDict[@"msg"]];
            [self goBack];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}


#pragma mark - payAlertView delegate
- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password
{
    if (password.length>0) {
        [self reqSave:password];
        [toolView close];
    }else{
        [toolView reset];
    }
}

//- (void)payAlertView:(PayAlertView *)toolView forgetButtonClicked:(id)sender {
//    if (!self.user.phone.length) {
//        [self pageToOrBackWithName:@"ModifyPhoneController"];
//    } else {
//        [self pageToOrBackWithName:@"PayPasswordController"];
//    }
    //[self pageToOrBackWithName:@"PayPasswordController"];
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}
@end
