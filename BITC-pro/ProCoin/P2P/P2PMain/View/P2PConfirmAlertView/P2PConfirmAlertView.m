//
//  P2PConfirmAlertView.m
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "P2PConfirmAlertView.h"
#import "TextFieldToolBar.h"
#import "P2POrderEntity.h"
#import "TJRBaseParserJson.h"
#import "NetWorkManage+P2P.h"
#import "CommonUtil.h"
#import "TJRBaseViewController.h"

@interface P2PConfirmAlertView()<UITextFieldDelegate> {
    NSTimer *timer;
    NSInteger timerCount;
    BOOL bReqFinished;
}

@property (retain, nonatomic) TextFieldToolBar *toolBar;

@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIView *touchView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutContentViewBottom;
@property (retain, nonatomic) IBOutlet UILabel *lbTitle;
@property (retain, nonatomic) IBOutlet UILabel *lbLimit;
@property (retain, nonatomic) IBOutlet UITextField *tfAmount;
@property (retain, nonatomic) IBOutlet UILabel *lbBalance;
@property (retain, nonatomic) IBOutlet UILabel *lbPrice;
@property (retain, nonatomic) IBOutlet UILabel *lbAmount;
@property (retain, nonatomic) IBOutlet UILabel *lbTotal;
@property (retain, nonatomic) IBOutlet UIButton *btnTime;
@property (retain, nonatomic) IBOutlet UIButton *btnMax;
@property (retain, nonatomic) IBOutlet UIButton *btnInOut;

/// 实收款  实付款
@property (retain, nonatomic) IBOutlet UILabel *lbTotalTips;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property (copy, nonatomic) NSString* timeLimit;
@property (copy, nonatomic) NSString* holdAmount;
@property (copy, nonatomic) NSString* adId;
@property (assign, nonatomic) CGFloat price;
@property (assign, nonatomic) Boolean isBuy;

@property (nonatomic, strong) P2POrderEntity *entity;

@end

@implementation P2PConfirmAlertView


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapEvent:)] autorelease];
    [_touchView addGestureRecognizer:recognizer];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    self.toolBar = [[[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1] autorelease];
    _tfAmount.inputAccessoryView = _toolBar;
    _tfAmount.delegate = self;
    
    bReqFinished = YES;
    
    self.timeLimit = @"30";
}


- (void)dealloc
{
    [_timeLimit release];
    [_holdAmount release];
    [_adId release];
    [_contentView release];
    [_touchView release];
    [_layoutContentViewBottom release];
    [_lbTitle release];
    [_tfAmount release];
    [_lbBalance release];
    [_lbPrice release];
    [_lbAmount release];
    [_lbTotal release];
    [_btnTime release];
    [_btnMax release];
    [_btnInOut release];
    [_toolBar release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_lbLimit release];
    [_lbTotalTips release];
    [_indicatorView release];
    [super dealloc];
}

- (void)reloadUIData:(P2POrderEntity*)entity isBuy:(BOOL)isBuy holdAmount:(NSString*)holdAmount timeLimit:(NSString*)timeLimit {
    self.entity = entity;
    _lbTotal.text = [NSString stringWithFormat:@"%@0.00", entity.currencySign];
    _lbPrice.text = [NSString stringWithFormat:@"%@ %@/USDT",entity.price, entity.currencyType];
    _lbLimit.text = [NSString stringWithFormat:@"%@ %@USDT-%@USDT", NSLocalizedStringForKey(@"限额"), entity.minCny, entity.maxCny];
    _lbBalance.text = [NSString stringWithFormat:@"%@ %@ USDT", NSLocalizedStringForKey(@"余额"), holdAmount];
    if (isBuy) {
        self.lbTotalTips.text = NSLocalizedStringForKey(@"实付款");
        _tfAmount.placeholder = NSLocalizedStringForKey(@"请输入购买数量");
        [_btnMax setTitle:NSLocalizedStringForKey(@"全部买入") forState:UIControlStateNormal];
        _lbTitle.text = [NSString stringWithFormat:@"%@USDT", NSLocalizedStringForKey(@"购买")];
        _lbBalance.hidden = _btnInOut.hidden = YES;
    } else {
        self.lbTotalTips.text = NSLocalizedStringForKey(@"实收款");
        _tfAmount.placeholder = NSLocalizedStringForKey(@"请输入出售数量");
        [_btnMax setTitle:NSLocalizedStringForKey(@"全部出售") forState:UIControlStateNormal];
        _lbTitle.text = [NSString stringWithFormat:@"%@USDT", NSLocalizedStringForKey(@"出售")];
        _lbBalance.hidden = _btnInOut.hidden = NO;
    }
    
    _price = [entity.price doubleValue];
    _isBuy = isBuy;
    self.adId = entity.adId;
    self.holdAmount = holdAmount;
    self.timeLimit = timeLimit;
}

#pragma mark - 按钮点击事件
- (void)backgroundTapEvent:(UIGestureRecognizer *)recognizer {
    [self dismissView];
}

- (IBAction)maxBtnClicked:(id)sender {
    _tfAmount.text = _holdAmount;
    [self textFieldChange:_tfAmount];
}

- (IBAction)inOutBtnClicked:(id)sender {
    
    [self dismissView];
    [[CommonUtil getControllerWithContainView:self] pageToOrBackWithName:@"PCTransferCoinController"];
}

- (IBAction)confirmBtnClicked:(id)sender {
    [_tfAmount resignFirstResponder];
    
    if(!TTIsStringWithAnyText(_tfAmount.text)){
        [[CommonUtil getControllerWithContainView:self] showToast:NSLocalizedStringForKey(@"请输入数量") inView:self];
        return;
    }
    if (_isBuy) {
        NSString* buySell = _isBuy?@"buy":@"sell";
        [self reqP2PCreateOrder:buySell adId:_adId price:[NSString stringWithFormat:@"%.2f", _price] amount:_tfAmount.text];
    }else{
        NSString* buySell = _isBuy?@"buy":@"sell";
        [self reqP2PCreateOrder:buySell adId:_adId price:[NSString stringWithFormat:@"%.2f", _price] amount:_tfAmount.text];
    }
}

- (IBAction)timeBtnClicked:(id)sender {
    [self dismissView];
}

#pragma mark - Text Field Delegate

- (IBAction)textFieldChange:(UITextField *)textField {
    
    _lbAmount.text = [NSString stringWithFormat:@"%@ USDT", textField.text];
    _lbTotal.text = [NSString stringWithFormat:@"%@%.2f", self.entity.currencySign, [textField.text doubleValue]*_price];
}

#pragma mark - 显示与消失
/** 显示动画*/
- (void)showInView:(UIView *)view
{
    _tfAmount.text = @"";
    [view addSubview:self];
    _layoutContentViewBottom.constant = -64 + IPHONEX_BOTTOM_HEIGHT;
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        _layoutContentViewBottom.constant = 0;
        [self startTimer];
        [self layoutIfNeeded];
    }];
    
}

/** 隐藏页面*/
- (void)dismissView
{
    [UIView animateWithDuration:0.3 animations:^{
        _layoutContentViewBottom.constant = -_contentView.frame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self closeTimer];
        [self removeFromSuperview];
    }];
}

#pragma mark - 键盘通知
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    CGRect frame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _layoutContentViewBottom.constant = frame.size.height;
    [self layoutIfNeeded];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    _layoutContentViewBottom.constant = 0;
    [self layoutIfNeeded];
}

#pragma mark - text field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}


#pragma mark - text field tool bar delegate
- (void)TFDonePressed
{
    [_tfAmount resignFirstResponder];
}

#pragma mark - 定时器
- (void)startTimer
{
    timerCount = [_timeLimit intValue];
    [self closeTimer];
    timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)closeTimer
{
    if(timer && [timer isValid]){
        [timer invalidate];
        timer = nil;
    }
}

- (void)onTimer:(NSTimer *)timer {
    
    timerCount--;
    [_btnTime setTitle:[NSString stringWithFormat:NSLocalizedStringForKey(@"%lds后自动取消"),timerCount] forState:UIControlStateNormal];
    if (timerCount == 0) {
        [self closeTimer];
        [self dismissView];
    }
}

#pragma mark - 请求数据接口
- (void)reqP2PCreateOrder:(NSString*)buySell adId:(NSString*)adId price:(NSString*)price amount:(NSString*)amount
{
    if (bReqFinished) {
        bReqFinished = NO;
        [_indicatorView startAnimating];
        [[NetWorkManage shareSingleNetWork] reqP2PCreateOrder:self buySell:buySell adId:adId amount:amount price:price  showReceiptType:@"" finishedCallback:@selector(reqCreateOrderFinished:) failedCallback:@selector(reqCreateOrderFailed:)];
    }
    
}

- (void)reqCreateOrderFinished:(id)result
{
    [_indicatorView stopAnimating];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    
    if([parser parseBaseIsOk:result]){

        NSDictionary *dataDic = [result objectForKey:@"data"];
        NSString* orderId = [parser stringParser:dataDic name:@"orderId"];
        
        [[CommonUtil getControllerWithContainView:self] showToast:str inView:ROOTCONTROLLER.view];
        
        [[CommonUtil getControllerWithContainView:self] putValueToParamDictionary:P2PDict value:orderId forKey:@"orderId"];
        [[CommonUtil getControllerWithContainView:self] pageToOrBackWithName:@"P2PConfirmController"];
        
        [self dismissView];
        
        
    }else{
        NSString* code = [NSString stringWithFormat:@"%@",[result objectForKey:@"code"]];
        if ([code isEqualToString:@"40090"]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:str preferredStyle:UIAlertControllerStyleAlert];
            __block typeof(UIViewController*) weakSelf = [CommonUtil getControllerWithContainView:self];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"去设置") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf pageToOrBackWithName:@"MyOauthController"];
            }];
            [alertController addAction:alertAction];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf dismissViewControllerAnimated:alertController completion:nil];
            }]];
            [self dismissView];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        }else{
            [[CommonUtil getControllerWithContainView:self] showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
        
    }
    

}

- (void)reqCreateOrderFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [_indicatorView stopAnimating];
    [[CommonUtil getControllerWithContainView:self] showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}


@end

