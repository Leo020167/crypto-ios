//
//  StoreTransferOutVC.m
//  BYY
//
//  Created by Hay on 2019/12/19.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "StoreTransferOutVC.h"
#import "NetWorkManage+Store.h"
#import "StoreTransferOutConfigModel.h"
#import "TextFieldToolBar.h"

#define OptionDefaultColor RGBA(29, 49, 85, 0.2)
#define OptionSelectedColor RGBA(29, 49, 85, 1.0)

typedef NS_ENUM(NSInteger, TransferOutSymbolKind){
    TransferOutSymbolCapital = 0,   //本金转出
    TransferOutSymbolProfit,        //收益转出
};

@interface StoreTransferOutVC ()<TextFieldToolBarDelegate>
{
    TextFieldToolBar *toolBar;
}

@property (nonatomic, copy) NSString *storeSymbol;
@property (nonatomic, retain) StoreTransferOutConfigModel *configModel;

@property (retain, nonatomic) IBOutlet UILabel *transferTipLabel;
@property (retain, nonatomic) IBOutlet UITextField *amountTF;
@property (retain, nonatomic) IBOutlet UILabel *symbolLabel;
@property (retain, nonatomic) IBOutlet UILabel *holdAmountLabel;
@property (retain, nonatomic) IBOutlet UILabel *frozenAmountLabel;
@property (retain, nonatomic) IBOutlet UIButton *leftOptionButton;              //左选项按钮
@property (retain, nonatomic) IBOutlet UIView *leftOptionView;                  //左选项view
@property (retain, nonatomic) IBOutlet UILabel *leftOptionTitle;                //左选项标题文本
@property (retain, nonatomic) IBOutlet UILabel *leftOptionContent;              //左选项内容
@property (retain, nonatomic) IBOutlet UIImageView *leftSelectedIV;             //左选择图片
@property (retain, nonatomic) IBOutlet UIButton *rightOptionButton;             //右选项按钮
@property (retain, nonatomic) IBOutlet UIView *rightOptionView;                 //右选项view
@property (retain, nonatomic) IBOutlet UILabel *rightOptionTitle;               //右选项标题文本
@property (retain, nonatomic) IBOutlet UILabel *rightOptionContent;             //右选项内容
@property (retain, nonatomic) IBOutlet UIImageView *rightSelectedIV;            //右选择图片

@end

@implementation StoreTransferOutVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self resetAllOptionsUI];
    toolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _amountTF.inputAccessoryView = toolBar;
    
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"StoreTransferOutStoreSymbol"]){
        self.storeSymbol = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"StoreTransferOutStoreSymbol"];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"StoreTransferOutStoreSymbol"];
        
        [self showProgressDefaultText];
        [self reqTransferConfig];
    }
    
}

- (void)dealloc
{
    [toolBar release];
    [_storeSymbol release];
    [_configModel release];
    [_transferTipLabel release];
    [_amountTF release];
    [_symbolLabel release];
    [_holdAmountLabel release];
    [_frozenAmountLabel release];
    [_leftOptionButton release];
    [_rightOptionButton release];
    [_leftOptionView release];
    [_rightOptionView release];
    [_leftOptionTitle release];
    [_leftOptionContent release];
    [_rightOptionTitle release];
    [_rightOptionContent release];
    [_leftSelectedIV release];
    [_rightSelectedIV release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)optionsButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton.isSelected)
        return;
    
    if(targetButton == _leftOptionButton){
        _leftOptionButton.selected = YES;
        _rightOptionButton.selected = NO;
    }else{
        _rightOptionButton.selected = YES;
        _leftOptionButton.selected = NO;
    }
    _amountTF.text = @"";
    [self leftOptionsUI];
    [self rightOptionsUI];
    
}

- (IBAction)allAmountButtonPressed:(id)sender
{
    if(_configModel == nil){
        return;
    }
    
    if(_leftOptionButton.isSelected){
        _amountTF.text = _configModel.holdAmount;
    }else{
        _amountTF.text = _configModel.profit;
    }
}

- (IBAction)transferButtonPressed:(id)sender
{
    [_amountTF resignFirstResponder];
    if(_configModel == nil)
        return;
    
    if(!checkIsStringWithAnyText(_amountTF.text) ){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入转出数量")];
        return;
    }
    if(_leftOptionButton.isSelected){               //左边选项
        if([_amountTF.text doubleValue] > [_configModel.holdAmount doubleValue]){
            [self showToastCenter:NSLocalizedStringForKey(@"转出数量超过当前持有数量！")];
            return;
        }
    }else{
        if([_amountTF.text doubleValue] > [_configModel.profit doubleValue]){
            [self showToastCenter:NSLocalizedStringForKey(@"转出数量超过当前持有数量！")];
            return;
        }
    }
    if([_amountTF.text doubleValue] == 0){
        [self showToastCenter:NSLocalizedStringForKey(@"转出数量必须大于0！")];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:[NSString stringWithFormat:NSLocalizedStringForKey(@"是否确定转出%@数量的%@到持仓？"),_amountTF.text,_configModel.storeSymbol] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self reqCreateTransferOut];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 请求数据
- (void)reqTransferConfig
{
    [[NetWorkManage shareSingleNetWork] reqStoreTransferConfig:self storeSymbol:_storeSymbol inOut:@"-1" finishedCallback:@selector(reqTransferConfigFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqTransferConfigFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSDictionary *storeResultDic = [dataDic objectForKey:@"storeResult"];
        self.configModel = [[[StoreTransferOutConfigModel alloc] initWithJson:storeResultDic] autorelease];
        
        [self reloadTransferOutUI];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqCreateTransferOut
{
    [self showProgressDefaultText];
    TransferOutSymbolKind selectedKind = _leftOptionButton.isSelected ?  TransferOutSymbolCapital:TransferOutSymbolProfit;
    [[NetWorkManage shareSingleNetWork] reqStoreCreateTransferOut:self storeSymbol:_storeSymbol amount:_amountTF.text selectItem:[NSString stringWithFormat:@"%@",@(selectedKind)] finishedCallback:@selector(reqCreateTransferOutFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCreateTransferOutFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        [self goBack];
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            [self showToastCenter:NSLocalizedStringForKey(@"转出成功")];
        }
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}



#pragma mark - 更新UI
- (void)reloadTransferOutUI
{
    _leftOptionButton.selected = YES;
    [self leftOptionsUI];
    [self rightOptionsUI];
}

- (void)leftOptionsUI
{
    _leftOptionTitle.text = _configModel.amountTip;
    _leftOptionContent.text = _configModel.amount;
    if(_leftOptionButton.isSelected){
        _leftOptionView.layer.borderWidth = 1.0;
        _leftOptionView.layer.borderColor = OptionSelectedColor.CGColor;
        _leftOptionTitle.textColor = OptionSelectedColor;
        _leftOptionContent.textColor = OptionSelectedColor;
        _leftSelectedIV.hidden = NO;
        
        _transferTipLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"转出%@数量到持仓"),_configModel.amountSymbol];
        _amountTF.placeholder = [NSString stringWithFormat:@"%@%@", NSLocalizedStringForKey(@"请输入转出数量"), _configModel.amountSymbol];
        _symbolLabel.text = _configModel.amountSymbol;
        _holdAmountLabel.text = [NSString stringWithFormat:@"%@：%@ %@", NSLocalizedStringForKey(@"可转出数量"),_configModel.holdAmount,_configModel.amountSymbol];
        _frozenAmountLabel.text = [NSString stringWithFormat:@"%@：%@ %@", NSLocalizedStringForKey(@"冻结数量"), _configModel.frozenAmount,_configModel.amountSymbol];
    }else{
        _leftOptionView.layer.borderWidth = 1.0;
        _leftOptionView.layer.borderColor = OptionDefaultColor.CGColor;
        _leftOptionTitle.textColor = OptionDefaultColor;
        _leftOptionContent.textColor = OptionDefaultColor;
        _leftSelectedIV.hidden = YES;
    }
}

- (void)rightOptionsUI
{
    _rightOptionTitle.text = _configModel.profitTip;
    _rightOptionContent.text = _configModel.profit;
    if(_rightOptionButton.isSelected){
        _rightOptionView.layer.borderWidth = 1.0;
        _rightOptionView.layer.borderColor = OptionSelectedColor.CGColor;
        _rightOptionTitle.textColor = OptionSelectedColor;
        _rightOptionContent.textColor = OptionSelectedColor;
        _rightSelectedIV.hidden = NO;
        
        _transferTipLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"转出%@数量到持仓"),_configModel.profitSymbol];
        _amountTF.placeholder = [NSString stringWithFormat:@"%@%@", NSLocalizedStringForKey(@"请输入转出数量"), _configModel.profitSymbol];
        _symbolLabel.text = _configModel.profitSymbol;
        _holdAmountLabel.text = [NSString stringWithFormat:@"%@：%@ %@", NSLocalizedStringForKey(@"可转出数量"), _configModel.profit,_configModel.profitSymbol];
        _frozenAmountLabel.text = [NSString stringWithFormat:@"%@：0 %@", NSLocalizedStringForKey(@"冻结数量"), _configModel.profitSymbol];           //收益不存在冻结
    }else{
        _rightOptionView.layer.borderWidth = 1.0;
        _rightOptionView.layer.borderColor = OptionDefaultColor.CGColor;
        _rightOptionTitle.textColor = OptionDefaultColor;
        _rightOptionContent.textColor = OptionDefaultColor;
        _rightSelectedIV.hidden = YES;
    }
}

- (void)resetAllOptionsUI
{
    _leftOptionButton.selected = NO;
    _leftOptionView.layer.borderWidth = 1.0;
    _leftOptionView.layer.borderColor = OptionDefaultColor.CGColor;
    _leftOptionTitle.textColor = OptionDefaultColor;
    _leftOptionContent.textColor = OptionDefaultColor;
    _leftSelectedIV.hidden = YES;
    
    _rightOptionButton.selected = NO;
    _rightOptionView.layer.borderWidth = 1.0;
    _rightOptionView.layer.borderColor = OptionDefaultColor.CGColor;
    _rightOptionTitle.textColor = OptionDefaultColor;
    _rightOptionContent.textColor = OptionDefaultColor;
    _rightSelectedIV.hidden = YES;
}

#pragma mark - text field tool bar delegate
- (void)TFDonePressed
{
    [_amountTF resignFirstResponder];
}
@end
