//
//  StoreTransferInVC.m
//  BYY
//
//  Created by Hay on 2019/12/18.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "StoreTransferInVC.h"
#import "NetWorkManage+Store.h"
#import "StoreTransferConfigModel.h"
#import "TextFieldToolBar.h"

@interface StoreTransferInVC ()<TextFieldToolBarDelegate>
{
    TextFieldToolBar *toolBar;
}

@property (nonatomic, copy) NSString *storeSymbol;
@property (nonatomic, retain) StoreTransferConfigModel *configModel;

@property (retain, nonatomic) IBOutlet UILabel *tipsLabel;
@property (retain, nonatomic) IBOutlet UITextField *amountTF;
@property (retain, nonatomic) IBOutlet UILabel *symbolLabel;
@property (retain, nonatomic) IBOutlet UILabel *availAmountLabel;

@end

@implementation StoreTransferInVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    toolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _amountTF.inputAccessoryView = toolBar;
    
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"StoreTransferStoreSymbol"]){
        self.storeSymbol = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"StoreTransferStoreSymbol"];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"StoreTransferStoreSymbol"];
        
        [self reqTransferConfig];
    }
}

- (void)dealloc
{
    [toolBar release];
    [_storeSymbol release];
    [_configModel release];
    [_amountTF release];
    [_symbolLabel release];
    [_tipsLabel release];
    [_availAmountLabel release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)allAmountButtonPressed:(id)sender
{
    if(_configModel == nil)
        return;
    if(_amountTF.text.doubleValue != [_configModel.amount doubleValue]){
        _amountTF.text = _configModel.amount;
    }
}
- (IBAction)transferInButtonPressed:(id)sender
{
    [_amountTF resignFirstResponder];
    if(_configModel == nil)
        return;
    
    if(!checkIsStringWithAnyText(_amountTF.text) ){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入转入数量")];
        return;
    }
    if([_amountTF.text doubleValue] < [_configModel.minInAmount doubleValue]){
        [self showToastCenter:[NSString stringWithFormat:NSLocalizedStringForKey(@"输入的数量不能低于%@"),_configModel.minInAmount]];
        return;
    }
    if(_amountTF.text.doubleValue > [_configModel.amount doubleValue]){
        [self showToastCenter:NSLocalizedStringForKey(@"当前可用数量不足")];
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:[NSString stringWithFormat:NSLocalizedStringForKey(@"是否确定转入%@数量的%@"),_amountTF.text,_configModel.storeSymbol] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self reqTransferStoreSymbol];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 请求数据
- (void)reqTransferConfig
{
    [[NetWorkManage shareSingleNetWork] reqStoreTransferConfig:self storeSymbol:_storeSymbol inOut:@"1" finishedCallback:@selector(reqTransferConfigFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqTransferConfigFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        self.configModel = [[[StoreTransferConfigModel alloc] initWithJson:dataDic] autorelease];
        
        [self reloadTransferConfigUI];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqTransferStoreSymbol
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqStoreCreateTransferIn:self storeSymbol:_storeSymbol amount:_amountTF.text finishedCallback:@selector(reqTransferStoreSymbolFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqTransferStoreSymbolFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        [self goBack];
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"转入成功")];
        }
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}


#pragma mark - 更新UI
- (void)reloadTransferConfigUI
{
    _tipsLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"转入%@数量到存币宝"),_configModel.storeSymbol];
    _amountTF.placeholder = [NSString stringWithFormat:NSLocalizedStringForKey(@"请最低转入%@"),_configModel.minInAmount];
    _symbolLabel.text = _configModel.storeSymbol;
    _availAmountLabel.text = [NSString stringWithFormat:@"%@：%@ %@", NSLocalizedStringForKey(@"可用数量"), _configModel.amount,_configModel.storeSymbol];
}

#pragma mark - text field tool bar delegate
- (void)TFDonePressed
{
    [_amountTF resignFirstResponder];
}
@end
