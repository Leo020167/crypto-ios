//
//  PCSubscribeUserAlertView.m
//  ProCoin
//
//  Created by Hay on 2020/3/24.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCSubscribeUserAlertView.h"
#import "NetWorkManage+TransferCoin.h"
#import "VeDateUtil.h"
#import "TextFieldToolBar.h"

@interface PCSubscribeUserAlertView ()<TextFieldToolBarDelegate>
{
    BOOL isDimissView;      //是否要消失
    TextFieldToolBar *toolBar;
}

@property (retain, nonatomic) PCPersonalInfoModel *subInfo;
@property (copy, nonatomic) NSString *holdAmount;

@property (retain, nonatomic) IBOutlet UIView *alertView;   //提示框
@property (retain, nonatomic) IBOutlet UIControl *contentView; //内容view
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *tipsLabel;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property (retain, nonatomic) IBOutlet UILabel *holdAmountLabel;
@property (retain, nonatomic) IBOutlet UILabel *totalLabel;
@property (retain, nonatomic) IBOutlet UILabel *noticeLabel;
@property (retain, nonatomic) IBOutlet UILabel *unitLabel;
@property (retain, nonatomic) IBOutlet UITextField *amountTF;
@property (retain, nonatomic) IBOutlet UIButton *subButton;

@end

@implementation PCSubscribeUserAlertView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isDimissView = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    toolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _amountTF.inputAccessoryView = toolBar;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [toolBar release];
    [_subInfo release];
    [_holdAmount release];
    [_alertView release];
    [_contentView.layer removeAllAnimations];
    [_contentView release];
    [_titleLabel release];
    [_tipsLabel release];
    [_priceLabel release];
    [_holdAmountLabel release];
    [_totalLabel release];
    [_noticeLabel release];
    [_unitLabel release];
    [_amountTF release];
    [_subButton release];
    [super dealloc];
}


#pragma mark - 显示与消失
- (void)showInController:(UIViewController *)controller subInfo:(PCPersonalInfoModel *)subInfo holdAmount:(NSString *)holdAmount
{
    self.subInfo = subInfo;
    self.holdAmount = holdAmount;
    
    self.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [controller addChildViewController:self];
    [controller.view addSubview:self.view];
    
    //添加增加的动画
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.5];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[self.contentView layer] addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    self.alertView.frame = CGRectMake(10, (SCREEN_HEIGHT - 226)/2.0 , SCREEN_WIDTH - 20, 226);
    [self.contentView addSubview:self.alertView];
    
    [self reloadSubscribeUserAlertViewData];

}

- (void)dismissViewWithAnimation
{
    if(_amountTF.isFirstResponder){
        isDimissView = YES;
        [_amountTF resignFirstResponder];
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self.alertView removeFromSuperview];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];

}

#pragma mark - 更新数据
- (void)reloadSubscribeUserAlertViewData
{
    if(_subInfo.myIsAttention){     //是否已订阅
        _titleLabel.text = NSLocalizedStringForKey(@"续费");
        [_subButton setTitle:NSLocalizedStringForKey(@"续费") forState:UIControlStateNormal];
        if(_subInfo.isExpireTime){      //已过期
            _tipsLabel.text = NSLocalizedStringForKey(@"订阅已过期");
            _tipsLabel.textColor = [UIColor redColor];
        }else{
            _tipsLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"%@到期，续费后有效期延长"),[VeDateUtil formatterDate:_subInfo.expireTime inStytle:nil outStytle:@"yyyy-MM-dd" isTimestamp:YES]];
            _tipsLabel.textColor = RGBA(29, 49, 85, 1.0);
        }
    }else{
        _titleLabel.text = NSLocalizedStringForKey(@"订阅");
        [_subButton setTitle:NSLocalizedStringForKey(@"订阅") forState:UIControlStateNormal];
        _tipsLabel.text = NSLocalizedStringForKey(@"你尚未订阅该用户");
        _tipsLabel.textColor = RGBA(29, 49, 85, 1.0);
    }
    _unitLabel.text = _subInfo.subFeeTypeUnit;
    _priceLabel.text = _subInfo.subFeeTypeName;
    _holdAmountLabel.text = [NSString stringWithFormat:@"%@:%@ USDT", NSLocalizedStringForKey(@"账户余额可用"), _holdAmount];
    _noticeLabel.text = _subInfo.subNotice;
}


#pragma mark - 点击事件
- (IBAction)contentViewDidTouchDown:(id)sender
{
    [self dismissViewWithAnimation];
}

- (IBAction)subUserButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(subscribeUserAlertViewDidCommit:buyNum:)]){
        [_delegate subscribeUserAlertViewDidCommit:self buyNum:_amountTF.text];
    }
}

#pragma mark - 文本改动
- (void)textfieldTextDidChanged:(NSNotification *)notifi
{
    if(checkIsStringWithAnyText(_amountTF.text)){
        CGFloat totalPrice = [_amountTF.text integerValue] * [_subInfo.subFee doubleValue];
        _totalLabel.text = [NSString stringWithFormat:@"%@ USDT",@(totalPrice)];
    }else{
        _totalLabel.text = @"0 USDT";
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if(SCREEN_HEIGHT - (self.alertView.frame.origin.y + self.alertView.frame.size.height) < keyboardRect.size.height){
        [UIView animateWithDuration:0.35 animations:^{
            CGRect rect = self.alertView.frame;
            rect.origin.y = SCREEN_HEIGHT - keyboardRect.size.height - self.alertView.frame.size.height;
            self.alertView.frame = rect;
        }];
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 animations:^{
        self.alertView.frame = CGRectMake(10, (SCREEN_HEIGHT - 226)/2.0 , SCREEN_WIDTH - 20, 226);
    } completion:^(BOOL finished) {
        if(isDimissView){
            [self dismissViewWithAnimation];
            isDimissView = NO;
        }
    }];
    
}

#pragma mark - TextFieldToolBar delegate
- (void)TFDonePressed
{
    [_amountTF resignFirstResponder];
}
@end
