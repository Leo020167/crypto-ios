//
//  P2PMainController.m
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "P2PMainController.h"
#import "P2PPayWayView.h"
#import "P2PConfirmAlertView.h"
#import "RZRefreshTableView.h"
#import "PayWayAlertView.h"
#import "ExpressSellAlertView.h"
#import "ExpressBuyAlertView.h"
#import "P2PMenuView.h"
#import "NetWorkManage+P2P.h"
#import "TJRBaseParserJson.h"
#import "P2POrderEntity.h"
#import "P2PPayWayEntity.h"
#import "RZWebImageView.h"
#import "CommonUtil.h"
#import "P2PPayMoneyView.h"
#import "NetWorkManage+TransferCoin.h"
#import "FRDLivelyButton.h"
#import "TextFieldToolBar.h"
#import "TradeUtil.h"
#import "HomeNewNumEntity.h"
#import "P2PCoinFilterView.h"


@interface P2PMainController () <P2PMenuViewDelegate,P2PPayWayViewDelegate,P2PPayMoneyViewDelegate, PayWayAlertViewDelegate,TextFieldToolBarDelegate,UITextFieldDelegate, QMUITextFieldDelegate, P2PCoinFilterViewDelegate>{
    BOOL bReqFinished;
    
    NSMutableArray* tableData;
    
    TextFieldToolBar* toolBar;
}


/// 标题  购买数量 出售数量
@property (retain, nonatomic) IBOutlet UILabel *lExpressTitle;
@property (retain, nonatomic) IBOutlet UITextField *tfExpress;
@property (retain, nonatomic) IBOutlet UIImageView *ivBtnBg;
@property (retain, nonatomic) IBOutlet UIButton *btnP2p;
@property (retain, nonatomic) IBOutlet UIButton *btnExpress;
@property (retain, nonatomic) IBOutlet UIButton *btnBuy;
@property (retain, nonatomic) IBOutlet UIButton *btnSell;
@property (retain, nonatomic) IBOutlet UIView *p2pView;

@property (nonatomic, strong) QMUITextField *textField;

/// 背景视图
@property (retain, nonatomic) IBOutlet UIView *expressView;
@property (retain, nonatomic) IBOutlet UILabel *lbBalance;
@property (retain, nonatomic) IBOutlet UIView *amountAllView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutAmountAllWidth;
@property (retain, nonatomic) P2PPayWayView *payWayView;
@property (retain, nonatomic) P2PPayMoneyView *payMoneyView;
@property (retain, nonatomic) P2PCoinFilterView *coinFilterView;
@property (retain, nonatomic) P2PConfirmAlertView *confirmAlertView;
@property (retain, nonatomic) PayWayAlertView *payAlertView;
@property (retain, nonatomic) ExpressSellAlertView *expressSellAlertView;
@property (retain, nonatomic) ExpressBuyAlertView *expressBuyAlertView;
@property (retain, nonatomic) P2PMenuView *menuView;
@property (retain, nonatomic) IBOutlet UILabel *lbExpressPrice;
@property (retain, nonatomic) IBOutlet UILabel *lbExpressCny;

@property (retain, nonatomic) IBOutlet FRDLivelyButton *btnPayAmountLogo;
@property (retain, nonatomic) IBOutlet FRDLivelyButton *btnPayWayLogo;
@property (retain, nonatomic) IBOutlet FRDLivelyButton *btnSymbolFilterLogo;
@property (retain, nonatomic) IBOutlet RZRefreshTableView *refreshTableView;
@property (retain, nonatomic) IBOutlet UIButton *btnPayWay;
@property (retain, nonatomic) IBOutlet UIButton *btnPayAmount;
@property (retain, nonatomic) IBOutlet UIButton *btnSymbolFilter;

/// 划转按钮
@property (nonatomic, strong) QMUIButton *btnTransfer;

@property (retain, nonatomic) IBOutlet UIButton *btnExpressDone;

@property (copy, nonatomic) NSString *buySell;
@property (copy, nonatomic) NSString *filterPayWay;
@property (copy, nonatomic) NSString *filterCny;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *holdAmount;

/// 价格约后边的单价
@property (retain, nonatomic) IBOutlet UILabel *coinLabel;
@property (retain, nonatomic) P2POrderEntity *expressOrder;

/// 订单按钮
@property (retain, nonatomic) IBOutlet UIButton *historyBtn;

@property (nonatomic, strong) NSMutableArray *coinTypeArray;
@end

@implementation P2PMainController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.historyBtn.qmui_badgeTextColor = UIColor.whiteColor;
    self.historyBtn.qmui_badgeBackgroundColor = UIColor.redColor;
    self.historyBtn.qmui_badgeOffset = CGPointMake(-25, 20);
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"MessageCount"];
    if (count == 0) {
        self.historyBtn.qmui_shouldShowUpdatesIndicator = NO;
    }else{
        self.historyBtn.qmui_shouldShowUpdatesIndicator = YES;
        self.historyBtn.qmui_badgeInteger = count;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    tableData = [[NSMutableArray alloc] init];
    bReqFinished = YES;
    
    [_btnBuy setTitle:NSLocalizedStringForKey(@"充值") forState:UIControlStateNormal];
    [_btnSell setTitle:NSLocalizedStringForKey(@"提现") forState:UIControlStateNormal];
    [_btnExpressDone setTitle:NSLocalizedStringForKey(@"充值") forState:UIControlStateNormal];
    
    [_refreshTableView setTableViewDelegate:self];
    [CommonUtil setExtraCellLineHidden:_refreshTableView];
    
    //添加toolbar
    toolBar = [[TextFieldToolBar alloc]initWithDelegate:self numOfTextField:1];
    _tfExpress.inputAccessoryView = toolBar;
    
    [self.expressView addSubview:self.textField];
    [self.expressView addSubview:self.btnTransfer];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.lExpressTitle);
        make.size.mas_equalTo(CGSizeMake(70, 30));
    }];
    [self.btnTransfer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.textField.mas_left).offset(-15);
        make.centerY.mas_equalTo(self.lExpressTitle);
        make.size.mas_equalTo(CGSizeMake(70, 30));
    }];
    
    [self reqAccountHold];
    
    [self reqCoinTypeArray];
    
    self.buySell = @"buy";
    self.filterPayWay = @"0";
    self.filterCny = @"";
    self.type = @"";
    [self expressBtnClicked:self.btnExpress];
//    [self refreshTableViewHeaderRefreshingDidTrigger];
    
    [_btnPayWayLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:NO];
    [_btnPayAmountLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:NO];
    [_btnSymbolFilterLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:NO];
    [_btnPayWayLogo setOptions:@{ kFRDLivelyButtonLineWidth: @(0.5f),
                          kFRDLivelyButtonHighlightedColor: RGBA(97, 117, 174, 1),
                          kFRDLivelyButtonColor: [UIColor blackColor]
                          }];
    [_btnPayAmountLogo setOptions:@{ kFRDLivelyButtonLineWidth: @(0.5f),
                          kFRDLivelyButtonHighlightedColor: RGBA(97, 117, 174, 1),
                          kFRDLivelyButtonColor: [UIColor blackColor]
                          }];
    [_btnSymbolFilterLogo setOptions:@{ kFRDLivelyButtonLineWidth: @(0.5f),
                          kFRDLivelyButtonHighlightedColor: RGBA(97, 117, 174, 1),
                          kFRDLivelyButtonColor: [UIColor blackColor]
                          }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMessageCount) name:@"ReloadMessageCount" object:nil];

}

- (void)reloadMessageCount{
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"MessageCount"];
    if (count == 0) {
        self.historyBtn.qmui_badgeInteger = 0;
    }else{
        self.historyBtn.qmui_badgeInteger = count;
    }
}

- (void)reqCoinTypeArray{
    [YYRequestUtility Post:@"/otc/mainad/config.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            self.coinTypeArray = [NSMutableArray arrayWithArray:responseDict[@"data"][@"currencies"]];
//            self.payMoneyView.coinTypeArray = self.coinTypeArray;
            self.coinFilterView.coinTypeArray = self.coinTypeArray;
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
    }];
}

-(void)dealloc{
    [toolBar release];
    [_holdAmount release];
    [_type release];
    [_expressOrder release];
    [_filterCny release];
    [_filterPayWay release];
    [_buySell release];
    [tableData release];
    [_menuView release];
    [_p2pView release];
    [_expressView release];
    [_btnBuy release];
    [_btnSell release];
    [_expressSellAlertView release];
    [_expressBuyAlertView release];
    [_payAlertView release];
    [_payWayView release];
    [_refreshTableView release];
    [_ivBtnBg release];
    [_btnPayWay release];
    [_btnPayAmount release];
    [_lbBalance release];
    [_amountAllView release];
    [_layoutAmountAllWidth release];
    [_btnTransfer release];
    [_lbExpressPrice release];
    [_lbExpressCny release];
    [_btnExpressDone release];
    [_btnPayWayLogo release];
    [_btnPayAmountLogo release];
    [_coinLabel release];
    [_historyBtn release];
    [super dealloc];
}

#pragma mark - 懒加载
- (P2PPayWayView *)payWayView
{
    if(!_payWayView){
        _payWayView = [[[[NSBundle mainBundle] loadNibNamed:@"P2PPayWayView" owner:nil options:nil] lastObject] retain];
        _payWayView.delegate = self;
    }
    return _payWayView;
}

- (P2PPayMoneyView *)payMoneyView
{
    if(!_payMoneyView){
        _payMoneyView = [[[[NSBundle mainBundle] loadNibNamed:@"P2PPayMoneyView" owner:nil options:nil] lastObject] retain];
        _payMoneyView.delegate = self;
    }
    return _payMoneyView;
}

- (P2PCoinFilterView *)coinFilterView
{
    if(!_coinFilterView){
        _coinFilterView = [[[[NSBundle mainBundle] loadNibNamed:@"P2PCoinFilterView" owner:nil options:nil] lastObject] retain];
        _coinFilterView.delegate = self;
    }
    return _coinFilterView;
}


- (PayWayAlertView *)payAlertView
{
    if(!_payAlertView){
        _payAlertView = [[[[NSBundle mainBundle] loadNibNamed:@"PayWayAlertView" owner:nil options:nil] lastObject] retain];
        _payAlertView.delegate = self;
    }
    return _payAlertView;
}

- (P2PConfirmAlertView *)confirmAlertView
{
    if(!_confirmAlertView){
        _confirmAlertView = [[[[NSBundle mainBundle] loadNibNamed:@"P2PConfirmAlertView" owner:nil options:nil] lastObject] retain];
    }
    return _confirmAlertView;
}


- (ExpressSellAlertView *)expressSellAlertView
{
    if(!_expressSellAlertView){
        _expressSellAlertView = [[[[NSBundle mainBundle] loadNibNamed:@"ExpressSellAlertView" owner:nil options:nil] lastObject] retain];
    }
    return _expressSellAlertView;
}

- (ExpressBuyAlertView *)expressBuyAlertView
{
    if(!_expressBuyAlertView){
        _expressBuyAlertView = [[[[NSBundle mainBundle] loadNibNamed:@"ExpressBuyAlertView" owner:nil options:nil] lastObject] retain];
    }
    return _expressBuyAlertView;
}

- (P2PMenuView *)menuView
{
    if(!_menuView){
        _menuView = [[P2PMenuView alloc]init];
        _menuView.delegate = self;
    }
    return _menuView;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)payWayBtnClicked:(id)sender
{
    if (self.payWayView.displayed) {
        [_btnPayWayLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
        [self.payWayView dismissView];
    }else{
        [_btnPayWayLogo setStyle:kFRDLivelyButtonStyleCaretUp animated:YES];
        [self.refreshTableView qmui_scrollToTop];
        [self.payWayView showInView:self.refreshTableView];
    }
    [self.payMoneyView dismissView];
    [_btnPayAmountLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
    [self.coinFilterView dismissView];
    [_btnSymbolFilterLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
}

- (IBAction)payMoneyBtnClicked:(id)sender
{
    if (self.payMoneyView.displayed) {
        [_btnPayAmountLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
        [self.payMoneyView dismissView];
    }else{
        [_btnPayAmountLogo setStyle:kFRDLivelyButtonStyleCaretUp animated:YES];
        [self.refreshTableView qmui_scrollToTop];
        [self.payMoneyView showInView:self.refreshTableView];
    }
    [self.payWayView dismissView];
    [_btnPayWayLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
    [self.coinFilterView dismissView];
    [_btnSymbolFilterLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
}
 
- (IBAction)coinFilterBtnClicked:(id)sender
{
    [_btnPayAmountLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
    [_btnPayWayLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
    [self.payMoneyView dismissView];
    [self.payWayView dismissView];
    
    if (self.coinFilterView.displayed) {
        [_btnSymbolFilterLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
        [self.coinFilterView dismissView];
    }else{
        [_btnSymbolFilterLogo setStyle:kFRDLivelyButtonStyleCaretUp animated:YES];
        [self.refreshTableView qmui_scrollToTop];
        [self.coinFilterView showInView:self.refreshTableView];
    }
}
 

- (IBAction)optionsButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton == _btnBuy){
        if(_btnBuy.isSelected){
            return;
        }
        _textField.text = @"CNY";
        _btnBuy.selected = YES;
        _btnSell.selected = NO;
        _btnBuy.titleLabel.font = [UIFont systemFontOfSize:22.0f];
        _btnSell.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _lExpressTitle.text = NSLocalizedStringForKey(@"购买数量");
        _btnTransfer.hidden = YES;
        _layoutAmountAllWidth.constant = 0;
        _lbBalance.hidden = YES;
        _tfExpress.text = @"";
        [_btnExpressDone setTitle:NSLocalizedStringForKey(@"购买") forState:UIControlStateNormal];
        
        self.buySell = @"buy";
    }else{
        if(_btnSell.isSelected){
            return;
        }
        _textField.text = @"CNY";
        _btnBuy.selected = NO;
        _btnSell.selected = YES;
        _btnBuy.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _btnSell.titleLabel.font = [UIFont systemFontOfSize:22.0f];
        _lExpressTitle.text = NSLocalizedStringForKey(@"提现数量");
        _btnTransfer.hidden = NO;
        _layoutAmountAllWidth.constant = 50;
        _lbBalance.hidden = NO;
        _tfExpress.text = @"";
        [_btnExpressDone setTitle:NSLocalizedStringForKey(@"提现") forState:UIControlStateNormal];
        
        self.buySell = @"sell";
    }
    
    [self refreshTableViewHeaderRefreshingDidTrigger];
}

- (IBAction)p2pBtnClicked:(id)sender
{
    _btnP2p.selected = ! _btnP2p.selected;
    _btnExpress.selected = ! _btnExpress.selected;
    _p2pView.hidden = !_btnP2p.selected;
    _expressView.hidden = _btnP2p.selected;
    
    _ivBtnBg.image = _btnP2p.selected? [UIImage imageNamed:@"p2p_bg_swicth_selected"]:[UIImage imageNamed:@"p2p_bg_swicth"];
    
    self.type = @"optional";
    [self refreshTableViewHeaderRefreshingDidTrigger];
}

- (IBAction)expressBtnClicked:(id)sender
{
    _btnExpress.selected = ! _btnExpress.selected;
    _btnP2p.selected = ! _btnP2p.selected;
    _expressView.hidden = !_btnExpress.selected;
    _p2pView.hidden = _btnExpress.selected;
    
    _ivBtnBg.image = _btnP2p.selected? [UIImage imageNamed:@"p2p_bg_swicth_selected"]:[UIImage imageNamed:@"p2p_bg_swicth"];
    
    self.type = @"fast";
    [self refreshTableViewHeaderRefreshingDidTrigger];
}

- (IBAction)expressConfirmBtnClicked:(id)sender
{
    [_tfExpress resignFirstResponder];
    if (!TTIsStringWithAnyText(_tfExpress.text)) {
        [self showToast:NSLocalizedStringForKey(@"请输入数量")];
        return;
    }
    if (!TTIsStringWithAnyText(_expressOrder.adId)) {
        [self showToast:NSLocalizedStringForKey(@"非交易时间，暂不能操作。")];
        return;
    }
    
    [YYRequestUtility Post:@"identity/get.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            int state = [responseDict[@"data"][@"identityAuth"][@"state"] intValue];
            if (state != 1) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"账户未实名") message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"去认证") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [self pageToOrBackWithName:@"MyOauthController"];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }else{
                if ([_buySell isEqualToString:@"buy"]) {
                    [self.expressBuyAlertView showInView:self.view];
                    [self.expressBuyAlertView reloadUIData:_expressOrder buySell:_buySell amount:_tfExpress.text];
                } else {
                    [self.payAlertView showInView:self.view];
                }
            }
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (IBAction)expressAllBtnClicked:(id)sender {
    if (_expressOrder != nil) {
        _tfExpress.text = _holdAmount;
    }
}

- (IBAction)moreBtnClicked:(id)sender
{
    [self.menuView show:self.view];
}
- (IBAction)historyBtnClicked:(id)sender {
    [self pageToOrBackWithName:@"P2PHistoryController"];
}

//触摸背景收起键盘
- (IBAction)viewTouchDown:(id)sender {
    [_tfExpress resignFirstResponder];
}

#pragma mark - P2PMenuView delegate
- (void)p2pMenuView:(P2PMenuView *)menuView adButtonClicked:(id)sender{
    [[NetWorkManage shareSingleNetWork] reqP2PGetCertificationInfo:self  finishedCallback:@selector(reqCertificationInfoFinished:) failedCallback:@selector(reqCertificationInfoFailed:)];
}

- (void)reqCertificationInfoFinished:(id)result{
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){
        NSDictionary *dataDic = [result objectForKey:@"data"];
        NSDictionary *dic = [dataDic objectForKey:@"otcCertification"];
        int state = [parser intParser:dic name:@"state"];
        if (state == 2) {
            [self pageToOrBackWithName:@"P2PMyADController"];
        }else{
            [QMUITips showError:NSLocalizedStringForKey(@"请先进行商家认证")];
        }
    }else{
        [QMUITips showError:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqCertificationInfoFailed:(NSDictionary *)json{
    [QMUITips showError:NSLocalizedStringForKey(@"请求失败")];
}

- (void)p2pMenuView:(P2PMenuView *)menuView customerButtonClicked:(id)sender{
    [self pageToOrBackWithName:@"P2PAuthCustomerController"];
}

- (void)p2pMenuView:(P2PMenuView *)menuView moneyButtonClicked:(id)sender{
    [self pageToOrBackWithName:@"P2PBankWayController"];
}

#pragma mark - P2PPayWayView delegate
- (void)p2pView:(P2PPayWayView *)menuView dismissView:(id)sender {
    [_btnPayWayLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
}

- (void)p2pView:(P2PPayWayView *)menuView buttonClicked:(id)sender filterPayWay:(NSString*) filterPayWay {
    self.filterPayWay = filterPayWay;
    [self refreshTableViewHeaderRefreshingDidTrigger];
    [_btnPayWayLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
    
    NSString* payWay = NSLocalizedStringForKey(@"支付方式");
    if ([filterPayWay isEqualToString:@"1"]) payWay = NSLocalizedStringForKey(@"支付宝");
    if ([filterPayWay isEqualToString:@"2"]) payWay = NSLocalizedStringForKey(@"微信");
    if ([filterPayWay isEqualToString:@"3"]) payWay = NSLocalizedStringForKey(@"银行卡");
    
    if ([filterPayWay isEqualToString:@"0"]) {
        [_btnPayWay setTitle:NSLocalizedStringForKey(@"支付方式") forState:UIControlStateNormal];
        [_btnPayWay setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        [_btnPayWay setTitle:payWay forState:UIControlStateNormal];
        [_btnPayWay setTitleColor:RGBA(97, 117, 174, 1) forState:UIControlStateNormal];
    }
    
}

#pragma mark - P2PPayMoneyView delegate
- (void)p2pView:(P2PPayMoneyView *)menuView dismissMoneyView:(id)sender{
    [_btnPayAmountLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
}

- (void)p2pView:(P2PPayMoneyView *)menuView buttonClicked:(id)sender filterCny:(NSString*) filterCny{
    self.filterCny = filterCny;
    [self refreshTableViewHeaderRefreshingDidTrigger];
    [_btnPayAmountLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
    
    if ([filterCny isEqualToString:@""]) {
        [_btnPayAmount setTitle:NSLocalizedStringForKey(@"交易金额") forState:UIControlStateNormal];
        [_btnPayAmount setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        [_btnPayAmount setTitle:[TradeUtil tradeBankFormatter:filterCny] forState:UIControlStateNormal];
        [_btnPayAmount setTitleColor:RGBA(97, 117, 174, 1) forState:UIControlStateNormal];
    }
}

#pragma mark - P2PCoinFilterView delegate
- (void)p2pSymbolView:(P2PCoinFilterView *)menuView dismissView:(id)sender{
    [_btnSymbolFilterLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
}

- (void)p2pSymbolView:(P2PCoinFilterView *)menuView selected: (NSString *)symbol {
    [self refreshTableViewHeaderRefreshingDidTrigger];
    [_btnSymbolFilterLogo setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
    
    if ([symbol isEqualToString:@""]) {
        [_btnSymbolFilter setTitle:NSLocalizedStringForKey(@"币种") forState:UIControlStateNormal];
        [_btnSymbolFilter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        [_btnSymbolFilter setTitle:symbol forState:UIControlStateNormal];
        [_btnSymbolFilter setTitleColor:RGBA(97, 117, 174, 1) forState:UIControlStateNormal];
    }
}


#pragma mark - PayWayAlertView delegate
- (void)p2pView:(PayWayAlertView *)menuView entity:(P2PPayWayEntity*) entity{
    [self.expressSellAlertView showInView:self.view];
    [self.expressSellAlertView reloadUIData:_expressOrder item:entity buySell:_buySell amount:_tfExpress.text];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    switch (textField.tag) {
        case 1:
            [_tfExpress becomeFirstResponder];
            break;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSUInteger tag = [textField tag];
    [toolBar checkBarButton:tag];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [self viewTouchDown:nil];
        return NO;
    }
    return YES;
}

#pragma mark - Text Field Tool Bar Delegate Methods
- (void)TFAnimateView:(NSUInteger)tag{
}
- (void)TFDonePressed{
    [self viewTouchDown:nil];
}

#pragma mark - 请求数据接口
- (void)reqMainADListData:(NSInteger)pageNo buySell:(NSString*)buySell filterPayWay:(NSString*)filterPayWay filterCny:(NSString*)filterCny type:(NSString*)type
{
//    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        //NSString *coinType = @"CNY";
        NSString *coinType = @"";
        if ([self.type isEqualToString:@"optional"]) {
            if (self.coinFilterView.coinType.length) {
                coinType = self.coinFilterView.coinType;
            }
        }else{
            coinType = self.textField.text;
        }
        [[NetWorkManage shareSingleNetWork] reqP2PADList:self buySell:buySell filterPayWay:filterPayWay filterCny:filterCny type:type pageNo:[NSString stringWithFormat:@"%@",@(pageNo)] currencyType:coinType finishedCallback:@selector(reqMainADListFinished:) failedCallback:@selector(reqMainADListFailed:)];
//    }
    
}

- (void)reqMainADListFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        NSDictionary *dataDic = [result objectForKey:@"data"];
        
        NSArray *list = [dataDic objectForKey:@"data"];
        
        //自选列表
        NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
        for(NSDictionary *dic in list){
            P2POrderEntity *entity = [[[P2POrderEntity alloc] initWithJson:dic]autorelease];
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
        
        //快捷数据
        if (list.count>0) {
            P2POrderEntity *entity = [[[P2POrderEntity alloc] initWithJson:[list firstObject]]autorelease];
            _lbExpressPrice.text = entity.price;
            self.coinLabel.text = [NSString stringWithFormat:@"%@/USDT", entity.currencyType];
            if ([_buySell isEqualToString:@"buy"]) {
                _lbExpressCny.text = [NSString stringWithFormat:@"%@ %@USDT - %@USDT", NSLocalizedStringForKey(@"限额"), entity.minCny,entity.maxCny];
            } else {
                _lbExpressCny.text = [NSString stringWithFormat:@"%@ %@ USDT- %@ USDT", NSLocalizedStringForKey(@"限额"), entity.minCny,entity.maxCny];
            }
            self.expressOrder = entity;
        }else{
            self.coinLabel.text = @"--/USDT";
            _lbExpressPrice.text = @"0.00";
            _lbExpressCny.text = @"";
        }
        _lbBalance.text = [NSString stringWithFormat:@"%@ %@ USDT", NSLocalizedStringForKey(@"余额"), _holdAmount];
    }else{
        [_refreshTableView tableViewEndRefreshing];
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
    [_refreshTableView reloadData];
}

- (void)reqMainADListFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
    [_refreshTableView tableViewEndRefreshing];
}

#pragma mark - 请求账户余额
- (void)reqAccountHold
{
    [[NetWorkManage shareSingleNetWork] reqTransferAccountHoldAmount:self accountType:PCAccountBalanceType finishedCallback:@selector(reqAccountHoldFinished:) failedCallback:nil];
}

- (void)reqAccountHoldFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        TJRBaseEntity *parserJson = [[[TJRBaseEntity alloc] init] autorelease];
        self.holdAmount = [parserJson stringParser:@"holdAmount" json:dataDic];
    }
}

#pragma mark -
#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"P2PContentCell" owner:nil options:nil] lastObject];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"P2PContentCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"P2PContentCell" owner:nil options:nil] lastObject];
        UIButton *optBtn = (UIButton*)[cell viewWithTag:201];
        [optBtn addTarget:self action:@selector(buySellBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    P2POrderEntity *entity = [tableData objectAtIndex:indexPath.row];

    UILabel *lbUserName = (UILabel *)[cell viewWithTag:100];
    lbUserName.text = [NSString stringWithFormat:@"%@",entity.userName];
    
    UILabel *lbOrderNum = (UILabel *)[cell viewWithTag:101];
    lbOrderNum.text = [NSString stringWithFormat:@"%@ | %@%%",entity.orderNum, entity.limitRate];
    
    UILabel *lbAmount= (UILabel *)[cell viewWithTag:102];
    lbAmount.text = [NSString stringWithFormat:@"%@ %@ USDT", NSLocalizedStringForKey(@"数量"), entity.amount];
    
    RZWebImageView* headView = (RZWebImageView*)[cell viewWithTag:200];
    [headView showImageWithUrl:entity.userLogo];

    UILabel *lbLimit = (UILabel *)[cell viewWithTag:104];
    lbLimit.text = [NSString stringWithFormat:@"%@ %@USDT-%@USDT", NSLocalizedStringForKey(@"限额"), entity.minCny, entity.maxCny];
    
    UILabel *lbPrice = (UILabel *)[cell viewWithTag:105];
    lbPrice.text = [NSString stringWithFormat:@"%@%@", entity.currencySign, entity.price];
    
    RZWebImageView* pay1 = (RZWebImageView*)[cell viewWithTag:300];
    RZWebImageView* pay2 = (RZWebImageView*)[cell viewWithTag:301];
    RZWebImageView* pay3 = (RZWebImageView*)[cell viewWithTag:302];
    pay1.hidden = pay2.hidden = pay3.hidden = NO;
    
    [pay1 showImageWithUrl:((P2PPayWayEntity*)[entity.payWayArray objectAtIndex:0]).receiptLogo];
    
    if (entity.payWayArray.count == 3) {
        [pay2 showImageWithUrl:((P2PPayWayEntity*)[entity.payWayArray objectAtIndex:1]).receiptLogo];
        [pay3 showImageWithUrl:((P2PPayWayEntity*)[entity.payWayArray objectAtIndex:2]).receiptLogo];
    }else if (entity.payWayArray.count == 2) {
        [pay2 showImageWithUrl:((P2PPayWayEntity*)[entity.payWayArray objectAtIndex:1]).receiptLogo];
        pay3.hidden = YES;
    }else if (entity.payWayArray.count == 1) {
        pay2.hidden = pay3.hidden = YES;
    }
    
    UIButton *optBtn = (UIButton*)[cell viewWithTag:201];
    [optBtn setBackgroundColor:RGBA(97, 117, 174, 1)];
    if([self.buySell isEqualToString:@"buy"]){
        [optBtn setTitle:NSLocalizedStringForKey(@"购买") forState:UIControlStateNormal];
    }else{
        [optBtn setTitle:NSLocalizedStringForKey(@"出售") forState:UIControlStateNormal];
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!TTIsArrayWithItems(tableData)) return;
}

- (void)refreshTableViewHeaderRefreshingDidTrigger{
    _refreshTableView.pageNo = 1;

    [self reqMainADListData:_refreshTableView.pageNo buySell:self.buySell filterPayWay:self.filterPayWay filterCny:self.filterCny type:self.type];
}

- (void)refreshTableViewFooterRefreshingDidTrigger{
    _refreshTableView.pageNo = _refreshTableView.pageNo + 1;

}

- (void)buySellBtnClicked:(id)sender{
    [YYRequestUtility Post:@"identity/get.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            int state = [responseDict[@"data"][@"identityAuth"][@"state"] intValue];
            if (state != 1) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"账户未实名") message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"去认证") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [self pageToOrBackWithName:@"MyOauthController"];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }else{
                UITableViewCell* cell = [CommonUtil getTableViewCellWithContainView:sender];
                NSIndexPath *indexPath = [_refreshTableView indexPathForCell:cell];
                P2POrderEntity *entity = [tableData objectAtIndex:indexPath.row];

                if([self.buySell isEqual:@"buy"]){
                    [self.confirmAlertView reloadUIData:entity isBuy:YES holdAmount:_holdAmount timeLimit:entity.timeLimit];
                } else {
                    [self.confirmAlertView reloadUIData:entity isBuy:NO holdAmount:_holdAmount timeLimit:entity.timeLimit];
                }
                [self.confirmAlertView showInView:self.view];
            }
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

/// 弹窗
- (void)popShowAction{
    QMUIPopupMenuView *pop = [[QMUIPopupMenuView alloc] init];
    pop.automaticallyHidesWhenUserTap = YES;
    pop.maximumWidth = 100;
    pop.shouldShowItemSeparator = YES;
    pop.itemSeparatorColor = UIColorMakeWithHex(@"696969");
    pop.itemTitleColor = UIColor.whiteColor;
    pop.backgroundColor = UIColorMakeWithHex(@"4D4CE6");
    pop.highlightedBackgroundColor = UIColor.clearColor;
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *currencyItem in self.coinTypeArray) {
        QMUIPopupMenuButtonItem *item = [QMUIPopupMenuButtonItem itemWithImage:nil title:currencyItem handler:^(__kindof QMUIPopupMenuButtonItem * _Nonnull aItem) {
            if ([currencyItem isEqualToString:self.textField.text]) {
                return;
            }
            self.textField.text = currencyItem;
            [self refreshTableViewHeaderRefreshingDidTrigger];
            [pop hideWithAnimated:YES];
        }];
        [items addObject:item];
    }
    pop.items = items;
    pop.sourceView = self.textField;
    [pop showWithAnimated:YES];
}

- (QMUITextField *)textField{
    if (!_textField) {
        _textField = [[QMUITextField alloc] init];
        _textField.text = @"CNY";
        _textField.textColor = UIColorMakeWithHex(@"#3d3a50");
        _textField.textInsets = UIEdgeInsetsMake(0, 10, 0, 30);
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.font = UIFontMake(13);
        _textField.layer.cornerRadius = 2;
        _textField.layer.masksToBounds = YES;
        _textField.backgroundColor = UIColorMakeWithHex(@"#f2f5ff");
        _textField.delegate = self;
        
        UILabel *pullLabel = [[UILabel alloc] init];
        pullLabel.text = @"▽";
        pullLabel.textColor = UIColorMakeWithHex(@"3d3a50");
        pullLabel.font = UIFontMake(15);
        [_textField addSubview:pullLabel];
        [pullLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            make.centerY.mas_equalTo(self.textField);
        }];
    }
    return _textField;
}

- (QMUIButton *)btnTransfer{
    if (!_btnTransfer) {
        _btnTransfer = [[QMUIButton alloc] init];
        [_btnTransfer setTitle:NSLocalizedStringForKey(@"划转") forState:0];
        [_btnTransfer setTitleColor:UIColorMakeWithHex(@"3d3a50") forState:0];
        [_btnTransfer setImage:UIImageMake(@"p2p_logo_inout") forState:0];
        _btnTransfer.spacingBetweenImageAndTitle = 3;
        _btnTransfer.titleLabel.font = UIFontMake(13);
        _btnTransfer.layer.cornerRadius = 2;
        _btnTransfer.layer.masksToBounds = YES;
        _btnTransfer.hidden = YES;
        _btnTransfer.backgroundColor = UIColorMakeWithHex(@"#f2f5ff");
        _btnTransfer.qmui_tapBlock = ^(__kindof UIControl *sender) {
            [self pageToOrBackWithName:@"PCTransferCoinController"];
        };
    }
    return _btnTransfer;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.textField) {
        [self popShowAction];
        return NO;
    }
    return YES;
}

@end
