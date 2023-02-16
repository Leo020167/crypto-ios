//
//  LeverageWinLossRateSettingView.m
//  BYY
//
//  Created by Hay on 2020/1/3.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "LeverageWinLossRateSettingView.h"
#import "TextFieldToolBar.h"
#import "TradeUtil.h"

@interface LeverageWinLossRateSettingView()<UITextFieldDelegate,TextFieldToolBarDelegate>
{
    TextFieldToolBar *winToolBar;
    TextFieldToolBar *lossToolBar;
    BOOL isDismissView;
}

@property (copy, nonatomic) NSString *maxStopLossRate;
@property (copy, nonatomic) NSString *buySell;
@property (copy, nonatomic) NSString *openCostPriceValue;
@property (copy, nonatomic) NSString *bailBalanceValue;
@property (copy, nonatomic) NSString *borrowBalanceValue;
@property (copy, nonatomic) NSString *interestValue;
@property (copy, nonatomic) NSString *priceDecimals;

@property (retain, nonatomic) IBOutlet UILabel *stopWinPriceLabel;
@property (retain, nonatomic) IBOutlet UILabel *stopLossPriceLabel;
@property (retain, nonatomic) IBOutlet UITextField *stopWinRateTF;
@property (retain, nonatomic) IBOutlet UITextField *stopLossRateTF;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentViewLayoutConstraintBottom;


@end

@implementation LeverageWinLossRateSettingView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _contentViewLayoutConstraintBottom.constant = - (self.contentView.frame.size.height + NAVIGATION_BAR_HEIGHT);
    [self layoutIfNeeded];
    [self initialSettingView];
}

- (void)initialSettingView
{
    isDismissView = NO;
    winToolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    lossToolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _stopWinRateTF.inputAccessoryView = winToolBar;
    _stopLossRateTF.inputAccessoryView = lossToolBar;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [winToolBar release];
    [lossToolBar release];
    [_maxStopLossRate release];
    [_buySell release];
    [_openCostPriceValue release];
    [_bailBalanceValue release];
    [_borrowBalanceValue release];
    [_interestValue release];
    [_priceDecimals release];
    [_stopWinPriceLabel release];
    [_stopLossPriceLabel release];
    [_stopWinRateTF release];
    [_stopLossRateTF release];
    [_contentView release];
    [_contentViewLayoutConstraintBottom release];
    [super dealloc];
}

#pragma mark -
- (void)reloadWinLossRateSettingView
{
    
}

#pragma mark - 显示与消失
- (void)showViewInView:(UIView *)superView currentWinRate:(NSString *)currentWinRate currentLossRate:(NSString *)currentLossRate maxLossRate:(NSString *)maxLossRate buySell:(NSString *)buySell openCostPriceValue:(NSString *)openCostPriceValue borrowBalanceValue:(NSString *)borrowBalanceValue bailBalanceValue:(NSString *)bailBalanceValue interestValue:(NSString *)interestValue priceDecimals:(NSString *)priceDecimals
{
    self.buySell = buySell;
    self.openCostPriceValue = openCostPriceValue;
    self.borrowBalanceValue = borrowBalanceValue;
    self.bailBalanceValue = bailBalanceValue;
    self.priceDecimals = priceDecimals;
    self.interestValue = interestValue;
    
    if(checkIsStringWithAnyText(currentWinRate) && [currentWinRate doubleValue] > 0){
        _stopWinRateTF.text = currentWinRate;
        CGFloat winPrice = 0;
        if([self.borrowBalanceValue doubleValue] != 0 && [self.bailBalanceValue doubleValue] != [self.interestValue doubleValue]){
            winPrice = [self.openCostPriceValue doubleValue] * ( 1 + ([self.buySell doubleValue]) * [_stopWinRateTF.text doubleValue] / (([self.borrowBalanceValue doubleValue] / ([self.bailBalanceValue doubleValue] - [self.interestValue doubleValue])) *100));
        }
        
        NSString *winPriceString = NSLocalizedStringForKey(@"未设置");
        if(winPrice > 0){
            winPriceString  = [TradeUtil stringRoundDownFloatValue:winPrice dotBits:[self.priceDecimals integerValue]];
        }
        _stopWinPriceLabel.text = winPriceString;
    }else{
        _stopWinRateTF.text = @"";
        _stopWinPriceLabel.text = NSLocalizedStringForKey(@"未设置");
    }
    
    if(checkIsStringWithAnyText(currentLossRate) && [currentLossRate doubleValue] > 0){
        _stopLossRateTF.text = currentLossRate;
        CGFloat lossPrice = 0;
         if([self.borrowBalanceValue doubleValue] != 0 && [self.bailBalanceValue doubleValue] != [self.interestValue doubleValue]){
             lossPrice = [self.openCostPriceValue doubleValue] * ( 1 - ([self.buySell doubleValue]) * [_stopLossRateTF.text doubleValue]/(([self.borrowBalanceValue doubleValue]/([self.bailBalanceValue doubleValue] - [self.interestValue doubleValue]))*100));
         }
        NSString *lossPriceString = NSLocalizedStringForKey(@"未设置");
        if(lossPrice > 0){
            lossPriceString  =  [TradeUtil stringRoundDownFloatValue:lossPrice dotBits:[self.priceDecimals integerValue]];
        }
        _stopLossPriceLabel.text = lossPriceString;
    }else{
        _stopLossRateTF.text = @"";
        _stopLossPriceLabel.text = NSLocalizedStringForKey(@"未设置");
    }
    
    self.maxStopLossRate = maxLossRate;
    
    
    [superView addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintBottom.constant = 0;
        [self layoutIfNeeded];
    }];
    
}

- (void)dismissViewFromSuperViewWithAnimation
{
    if([_stopLossRateTF isFirstResponder]){
        isDismissView = YES;
        [_stopLossRateTF resignFirstResponder];
    }else if([_stopWinRateTF isFirstResponder]){
        isDismissView = YES;
        [_stopWinRateTF resignFirstResponder];
    }else{
        [self dismissViewWithAnimation];
    }
}

- (void)dismissViewWithAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintBottom.constant = - (self.contentView.frame.size.height + NAVIGATION_BAR_HEIGHT);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 按钮点击事件
- (IBAction)commitButtonPressed:(id)sender
{
    NSString *winRateString = @"0";
    NSString *lossRateString = @"0";
    
    if(checkIsStringWithAnyText(_stopWinRateTF.text)){
        winRateString = _stopWinRateTF.text;
    }
    
    if(checkIsStringWithAnyText(_stopLossRateTF.text)){
        lossRateString = _stopLossRateTF.text;
    }
    
    if([_delegate respondsToSelector:@selector(settingViewCommitButtonPressed:WithWinRate:lossRate:)]){
        [_delegate settingViewCommitButtonPressed:self WithWinRate:winRateString lossRate:lossRateString];
    }
}

- (IBAction)cancelSettingViewButtonPressed:(id)sender
{
    [self dismissViewFromSuperViewWithAnimation];
}

- (IBAction)backgroundViewDidTouchDown:(id)sender
{
    [self dismissViewFromSuperViewWithAnimation];
}

#pragma mark - text filed delegate
- (void)textfieldTextDidChanged:(NSNotification *)notification
{
    UITextField *textField = notification.object;
    if(textField == _stopWinRateTF){
        CGFloat winPrice = 0;
         if([self.borrowBalanceValue doubleValue] != 0 && [self.bailBalanceValue doubleValue] != [self.interestValue doubleValue]){
             winPrice = [self.openCostPriceValue doubleValue] * ( 1 + ([self.buySell doubleValue]) * [_stopWinRateTF.text doubleValue] / (([self.borrowBalanceValue doubleValue] / ([self.bailBalanceValue doubleValue] - [self.interestValue doubleValue])) *100));
         }
        NSString *winPriceString = NSLocalizedStringForKey(@"未设置");
        if(winPrice > 0){
            winPriceString  = [TradeUtil stringRoundDownFloatValue:winPrice dotBits:[self.priceDecimals integerValue]];
        }
        _stopWinPriceLabel.text = winPriceString;
    }else{
        CGFloat lossPrice = 0;
        if([self.borrowBalanceValue doubleValue] != 0 && [self.bailBalanceValue doubleValue] != [self.interestValue doubleValue]){
            lossPrice = [self.openCostPriceValue doubleValue] * ( 1 - ([self.buySell doubleValue]) * [_stopLossRateTF.text doubleValue]/(([self.borrowBalanceValue doubleValue]/([self.bailBalanceValue doubleValue] - [self.interestValue doubleValue]))*100));
        }
        NSString *lossPriceString = NSLocalizedStringForKey(@"未设置");
        if(lossPrice > 0){
            lossPriceString  =  [TradeUtil stringRoundDownFloatValue:lossPrice dotBits:[self.priceDecimals integerValue]];
        }
        _stopLossPriceLabel.text = lossPriceString;
    }
}

#pragma mark - 键盘事件
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _contentViewLayoutConstraintBottom.constant = keyboardRect.size.height - IPHONEX_BOTTOM_HEIGHT;
    [self layoutIfNeeded];
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 animations:^{
        _contentViewLayoutConstraintBottom.constant = 0.0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if(isDismissView){
            [self dismissViewWithAnimation];
        }
    }];
    
}

#pragma mark - TextFieldToolBar delegate
- (void)TFDonePressed
{
    [_stopWinRateTF resignFirstResponder];
    [_stopLossRateTF resignFirstResponder];
}

@end
