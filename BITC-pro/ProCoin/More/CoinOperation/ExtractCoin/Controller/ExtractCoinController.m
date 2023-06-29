//
//  ExtractCoinController.m
//  Cropyme
//
//  Created by Hay on 2019/6/13.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "ExtractCoinController.h"
#import "NetWorkManage+ExtractCoin.h"
#import "ExtractCoinDataEntity.h"
#import "CommonUtil.h"
#import "TextFieldToolBar.h"
#import "TradeUtil.h"
#import "PayAlertView.h"
#import "CoinOperationInfoEntity.h"
#import "EmailAlertView.h"
#import "HomeAccountCheckViewController.h"
#import "NetWorkManage+file.h"
#import "UIImage+Size.h"
#import "ExtAddressViewController.h"
#import "UIView+General.h"
#import "SelectCoinController.h"

@interface ExtractCoinController ()<UITextFieldDelegate,UIAlertViewDelegate,TextFieldToolBarDelegate,EmailAlertViewDelegate,ExtAddressViewDelegate, SelectCoinControllerDelegate>
{
    NSArray *coinListArr;
    NSArray *chainTypeListArr;
    TextFieldToolBar *amountToolBar;
}

@property (retain, nonatomic) SelectCoinController *selectController;           //选择币种

@property (copy, nonatomic) NSString *symbol;
@property (retain, nonatomic) CoinWithdrawConfigEntity *infoEntity;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *amountSymbolLabel;        //可用数量
@property (retain, nonatomic) IBOutlet UILabel *amountLabel;        //可用数量
@property (retain, nonatomic) IBOutlet UILabel *lockSymbolLabel;        //冻结数量
@property (retain, nonatomic) IBOutlet UILabel *lockLabel;        //冻结数量

//页面显示元素
@property (retain, nonatomic) IBOutlet UIView *keyTypesView;
@property (retain, nonatomic) IBOutlet UIView *optionsView;
@property (retain, nonatomic) IBOutlet UIButton *coinSymbolButton;         //提币币种

@property (retain, nonatomic) IBOutlet UITextField *addressTF;      //地址输入
@property (retain, nonatomic) IBOutlet UILabel *tipsLabel;          //提示label

//输入框
@property (retain, nonatomic) IBOutlet UITextField *amountTF;       //数量输入
@property (retain, nonatomic) IBOutlet UILabel *feeLabel;           //手续费
@property (retain, nonatomic) IBOutlet UILabel *feeSymbolLabel;     //手续费symbol

@property (retain, nonatomic) IBOutlet UILabel *extractTFSymbolLabel;    //到账数量的symbol
@property (retain, nonatomic) IBOutlet UILabel *finalExtractCoinAmountLabel;            //最终到账

@property (nonatomic, strong) TJRUser *user;

@property (nonatomic, strong) EmailAlertView *emailAlertView;

@property (nonatomic, copy) NSString *selectedChainType;    //链类型
@property (nonatomic, strong) CoinWithdrawConfigAddress *addressConfig;    //提币地址

/// 我的余额
@property (nonatomic, copy) NSString *balance;

@end

@implementation ExtractCoinController
- (void)viewDidLayoutSubviews {
    [[self.view viewWithTag:800] applyShadow];
    [[self.view viewWithTag:801] applyShadow];
    [[self.view viewWithTag:802] applyShadow];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.symbol = nil;
    
    [_keyTypesView setHidden: YES];
    [_coinSymbolButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 0.0)];
    _amountTF.delegate = self;
    amountToolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _amountTF.inputAccessoryView = amountToolBar;
    coinListArr = [[NSArray alloc] init];
    chainTypeListArr = [[NSArray alloc] init];
    
    [self resetViewBaseInfo];
    [self reqCoinListData];
    //self.withdrawLabel.text = NSLocalizedStringForKey(@"提币二维码");
    
    [self getUserData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}


- (void)getUserData{
    [YYRequestUtility Post:@"user/info.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        NSLog(@"responseDict : %@", responseDict);
        if ([responseDict[@"code"] intValue] == 200) {
            TJRUser *user = [TJRUser yy_modelWithDictionary:responseDict[@"data"]];
            self.user = user;
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)bindChainTypeView {
    
    if ([_symbol.uppercaseString isEqualToString: @"USDT"]) {
        [self.keyTypesView setHidden:NO];
    } else {
        [self.keyTypesView setHidden:YES];
        return;
    }
    
    [_optionsView qmui_removeAllSubviews];
    CGFloat width = 64;
    CGFloat height = 30;
    CGFloat tap = 8;
    UIButton *firstButton;
    for(int i = 0; i < chainTypeListArr.count; i++){
        NSString *string = [NSString stringWithFormat:@"%@", chainTypeListArr[i]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.layer.cornerRadius = 5;
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = UIColorMakeWithHex(@"#00BAB8").CGColor;
        [button addTarget:self action:@selector(optionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1000+i;
        [button setFrame:CGRectMake(0.0 + (tap + width) * i , 0.0, width, height)];
        [button setTitle:string forState:UIControlStateNormal];
        [button setTitleColor:UIColorMakeWithHex(@"#00BAB8") forState: UIControlStateNormal];
        [button setTitleColor:UIColorMakeWithHex(@"#ffffff") forState: UIControlStateSelected];
        [button setBackgroundImage:[UIImage qmui_imageWithColor:UIColorMakeWithHex(@"#ffffff")] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage qmui_imageWithColor:UIColorMakeWithHex(@"#00BAB8")] forState:UIControlStateSelected];
        
        button.titleLabel.font = UIFontMake(15);
        if(i == 0){
            firstButton = button;
        }
        [_optionsView addSubview:button];
    }
    if (firstButton) {[self optionsButtonPressed:firstButton];}
}

- (void)setInfoEntity:(CoinWithdrawConfigEntity *)infoEntity {
    _infoEntity = [infoEntity retain];
    _amountLabel.text = infoEntity.availableAmount;
    _lockLabel.text = infoEntity.frozenAmount;
    _feeLabel.text = infoEntity.fee;
    
    //NSString *address = infoEntity.addressList.firstObject.address;
    //_addressTF.text = address;
}


/// 获取提币信息
/// /// "data": {"availableAmount": "10","addressList": [{"address": "JKLJKSJGIOUIO454334","symbol": "BTC"}],"minChargeAmount": "1"},
- (void)getWithdrawConfig {
    if (_symbol == nil) return;
    [YYRequestUtility Post:@"depositeWithdraw/getWithdrawConfigs.do" addParameters:@{@"symbol": _symbol} progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            self.infoEntity = [CoinWithdrawConfigEntity yy_modelWithDictionary:responseDict[@"data"]];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)dealloc
{
    [coinListArr release];
    [amountToolBar release];
    [_symbol release];
    [_infoEntity release];
    [_coinSymbolButton release];
    [_amountLabel release];
    [_extractTFSymbolLabel release];
    [_feeLabel release];
    [_feeSymbolLabel release];
    [_tipsLabel release];
    [_finalExtractCoinAmountLabel release];
    [_addressTF release];
    [_amountTF release];
    [_keyTypesView release];
    [_optionsView release];

    [super dealloc];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-keyboardRect.size.height - kUINormalBottomSafeDistance);
    }];
    [_scrollView qmui_scrollToBottom];
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 animations:^{
    } completion:^(BOOL finished) {
        [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
        }];
    }];
    
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

#pragma mark - 请求数据
- (void)reqCoinListData {
    [[NetWorkManage shareSingleNetWork] reqDepositeWithdrawCoinList:self inOut:@"1" finishedCallback:@selector(reqCoinListDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCoinListDataFinished:(NSDictionary *)json {
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        coinListArr = [[NSArray alloc] initWithArray: (NSArray*) [dataDic objectForKey:@"coinList"]];
        chainTypeListArr = [[NSArray alloc] initWithArray: (NSArray*) [dataDic objectForKey:@"chainTypeList"]];
        if (coinListArr.count > 0) {
            [self bindSymbol: [NSString stringWithString: coinListArr.firstObject ]];
        }

    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqSymbolBaseInfoFailed:(NSDictionary *)json
{
    [self dismissProgress];
    [self resetViewBaseInfo];
}

- (void)bindSymbol:(NSString *)symbol {
    self.symbol = symbol;
    self.selectedChainType = nil;
    
    [_coinSymbolButton setTitle:symbol forState:0];
    self.amountSymbolLabel.text = [NSString stringWithFormat: NSLocalizedStringForKey(@"可用余额()"), symbol];
    self.lockSymbolLabel.text = [NSString stringWithFormat: NSLocalizedStringForKey(@"冻结金额()"), symbol];
    //self.feeSymbolLabel.text = [NSString stringWithFormat: NSLocalizedStringForKey(@"手续费()"), symbol];
    self.feeSymbolLabel.text = [NSString stringWithFormat: NSLocalizedStringForKey(@"手续费()"), @"ATC"];
    self.extractTFSymbolLabel.text = [NSString stringWithFormat: NSLocalizedStringForKey(@"到账数量()"), symbol];
    [self getWithdrawConfig];
    [self bindChainTypeView];
}

#pragma mark - 按钮点击事件
- (IBAction)chooseCoinButtonPressed:(id)sender
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

- (IBAction)addressManager {
    ExtAddressViewController *vc = [[[ExtAddressViewController alloc] initWithNibName:@"ExtAddressViewController" bundle:nil] autorelease];
    [[self getTJRAppDelegate].navigation pushViewController:vc animated:YES];
    
    //[self pageToViewControllerForName:@"ExtAddressViewController"];
}

- (IBAction)addressChoise {
    ExtAddressViewController *vc = [[[ExtAddressViewController alloc] initWithNibName:@"ExtAddressViewController" bundle:nil] autorelease];
    vc.symbol = _symbol;
    vc.chainType = _selectedChainType;
    vc.delegate = self;
    [[self getTJRAppDelegate].navigation pushViewController:vc animated:YES];
    
    //[self pageToViewControllerForName:@"ExtAddressViewController"];
}

- (void)extAddressViewDidSelected:(CoinWithdrawConfigAddress * _Nonnull)address {
    self.addressConfig = [CoinWithdrawConfigAddress yy_modelWithDictionary:address];
    _addressTF.text = _addressConfig.address;
}


- (IBAction)backButtonPressed:(id)sender {
    [self goBack];
}

- (IBAction)recordButtonPressed:(id)sender {
    [self pageToViewControllerForName:@"PCCoinOperationRecordController"];
}


//- (IBAction)allAmountButtonPressed:(id)sender
//{
//    self.amountTF.text = self.balance;
//    [self updateViewData];
//}

- (void)optionsButtonPressed:(UIButton *)sender {
    if(sender.isSelected){
        return;
    }
    
    sender.selected = YES;
    NSInteger tag = sender.tag - 1000;
    
    self.selectedChainType = chainTypeListArr[tag];
    [self updateButtonWithSelectedState:sender];
    for(int i = 0; i < chainTypeListArr.count; i++){
        if(i == tag)
            continue;
        UIButton *button = [_optionsView viewWithTag:1000+i];
        button.selected = NO;
        [self updateButtonWithNormalState:button];
    }
}

- (IBAction)commitExtractCoinButtonPressed:(id)sender {
   
    if(!checkIsStringWithAnyText(_addressTF.text)){
        [self showToastCenter:NSLocalizedStringForKey(@"请选择提币地址")];
        return;
    }

    if(!checkIsStringWithAnyText(_amountTF.text)){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入提取数量")];
        return;
    }
//    if(!self.qrImage_str.length){
//        [QMUITips showError:NSLocalizedStringForKey(@"请上传提币二维码")];
//        return;
//    }
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedStringForKey(@"提币数量:%@%@\n确认前请仔细核对提币地址信息，以避免造成不必要的财产损失."),_amountTF.text, _symbol];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    [self reqSubmitExtractCoin:@""];
        
//        if ([CommonUtil checkEmail:ROOTCONTROLLER_USER.email]) {
//            NSLog(@"邮箱:%@", ROOTCONTROLLER_USER.email);
//            if (!self.user.phone.length) {
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"请绑定手机号码") preferredStyle:UIAlertControllerStyleAlert];
//                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
//                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"去设置") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    [self pageToOrBackWithName:@"ModifyPhoneController"];
//                }]];
//                [self presentViewController:alert animated:YES completion:nil];
//            }else{
//                [self.emailAlertView showInView:self.view];
//            }
//        } else {
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"请绑定邮箱") preferredStyle:UIAlertControllerStyleAlert];
//            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
//            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"去设置") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [self pageToOrBackWithName:@"EmailVerificationViewController"];
//            }]];
//            [self presentViewController:alert animated:YES completion:nil];
//        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - EmailAlertViewDelegate

- (void)emailCodeSuccess {
    HomeAccountCheckViewController *check = [[HomeAccountCheckViewController alloc] init];
    check.checkDataBlock = ^{
        [self reqSubmitExtractCoin:@""];
    };
    [QMUIHelper.visibleViewController.navigationController pushViewController:check animated:YES];
}


/** 请求提币*/
- (void)reqSubmitExtractCoin:(NSString *)payPass {
    if (_symbol == nil) return;
    if (!self.amountTF.text.length) {
        [QMUITips showError:_amountTF.placeholder];
        return;
    }
    if (!self.addressTF.text.length) {
        [QMUITips showError:_addressTF.placeholder];
        return;
    }

    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    [para setObject:_amountTF.text forKey:@"amount"];
    [para setObject:_addressConfig.addressId forKey:@"addressId"];
    //[para setObject:model.type forKey:@"chainType"];
    [para setObject:payPass forKey:@"payPass"];
    
    [YYRequestUtility Post:@"depositeWithdraw/withdrawSubmit.do" addParameters:para progress:nil success:^(NSDictionary *responseDict) {
//        if ([responseDict[@"code"] intValue] == 200) {
//            [QMUITips showSucceed:responseDict[@"msg"]];
//            [self.navigationController popViewControllerAnimated:YES];
//        }else{
//            [QMUITips showError:responseDict[@"msg"]];
//        }
        [self reqSubmitExtractCoinFinished: responseDict];
    } failure:^(NSError *error) {
        
    }];
}


- (void)reqSubmitExtractCoinFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(checkIsStringWithAnyText(msg)){
            [self showToastCenter:msg];
        }else{
            
            [self showToastCenter:NSLocalizedStringForKey(@"提交成功")];
        }
        [self goBack];
    }else{
        if([self checkIsNeedTradePassword:json]){          //需要输入交易密码
            PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
            [payAlertView show];
        }else if([self checkIsNeedSetTradePassword:json]){     //是否需要设置交易密码
            
        }else if([[NSString stringWithFormat:@"%@",[json objectForKey:@"code"]] isEqualToString:@"40090"]){
            NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"实名认证") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self pageToViewControllerForName:@"MyOauthController"];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
        
    }
}


#pragma mark - text field delegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField == _amountTF){
        if (textField.text.length) {
            float amount = [textField.text floatValue];
            _finalExtractCoinAmountLabel.text = [NSString stringWithFormat:@"%.8f", amount];
//            float income = amount - [_infoEntity.fee floatValue];
//            if (income > 0) {
//                _finalExtractCoinAmountLabel.text = [NSString stringWithFormat:@"%.8f", income];
//            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_addressTF resignFirstResponder];
    [self updateViewData];
    return YES;
}

#pragma mark - text field tool bar delegate
- (void)TFDonePressed
{
    if(checkIsStringWithAnyText(_amountTF.text) && checkIsStringWithAnyText(_symbol)){
        if([_amountTF.text doubleValue] > [_infoEntity.availableAmount doubleValue]){
            [self showToastCenter:NSLocalizedStringForKey(@"提币数量不能超过可提币数量")];
            _amountTF.text = _infoEntity.availableAmount;
        }
        [self updateViewData];
    }
    
    [_amountTF resignFirstResponder];
}


#pragma mark - payAlertView delegate
- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password
{
    if (password.length>0) {
        [self reqSubmitExtractCoin:password];
        [toolView close];
    }else{
        [toolView reset];
    }
}

//- (void)payAlertView:(PayAlertView *)toolView forgetButtonClicked:(id)sender {
//    [self pageToOrBackWithName:@"PayPasswordController"];
//}

#pragma mark - SelectCoinController delegate
- (void)selectCoinDidSelctedWithSymol:(NSString *)symbol
{
    [self bindSymbol:symbol];
}

#pragma mark - 更新数据
- (void)updateViewData
{
    float amount = [self.amountTF.text floatValue];
    _finalExtractCoinAmountLabel.text = [NSString stringWithFormat:@"%.8f", amount];
//    float income = amount - [_infoEntity.fee floatValue];
//    if (income > 0) {
//        _finalExtractCoinAmountLabel.text = [NSString stringWithFormat:@"%.8f", income];
//    }
}


- (void)resetViewBaseInfo
{
    self.infoEntity = nil;
    self.symbol = nil;
    
    //[CommonUtil viewHeightForAutoLayout:_keyTypesView height:0];
    _amountSymbolLabel.text = [NSString stringWithFormat: NSLocalizedStringForKey(@"可用余额()"), (_symbol ?: @"")];
    _lockSymbolLabel.text = [NSString stringWithFormat: NSLocalizedStringForKey(@"冻结金额()"), _symbol ?: @""];
//    _feeSymbolLabel.text = [NSString stringWithFormat: NSLocalizedStringForKey(@"手续费()"), _symbol ?: @""];
    _feeSymbolLabel.text = [NSString stringWithFormat: NSLocalizedStringForKey(@"手续费()"), @"ATC"];
    _extractTFSymbolLabel.text = [NSString stringWithFormat: NSLocalizedStringForKey(@"到账数量()"), _symbol ?: @""];
    
    _feeLabel.text = @"0.00000000";
    _amountLabel.text = @"0";
    _finalExtractCoinAmountLabel.text = @"---";
    
}

#pragma mark - 设置按钮状态
- (void)updateButtonWithSelectedState:(UIButton *)button
{
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

- (EmailAlertView *)emailAlertView
{
    if(!_emailAlertView){
        _emailAlertView = [[[[NSBundle mainBundle] loadNibNamed:@"EmailAlertView" owner:nil options:nil] lastObject] retain];
        _emailAlertView.delegate = self;
    }
    return _emailAlertView;
}


@end
