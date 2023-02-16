//
//  PayAlertView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 1/27/16.
//  Copyright © 2016 淘金路. All rights reserved.
//

#import "PayAlertView.h"
#import "TradeInputView.h"
#import "CommonUtil.h"
#import "TJRBaseViewController.h"
#import "ModifyPhoneController.h"

@interface PayAlertView ()<TradeInputViewDelegate>{
    BOOL bReqFinished;
    CGRect phoneRectScreen;
}
@property (retain, nonatomic) IBOutlet TradeInputView *tradeInputView;
@property (retain, nonatomic) IBOutlet UIView *alertView;

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (copy, nonatomic) NSString *password;

@property (nonatomic, strong) TJRUser *user;
@end

@implementation PayAlertView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initAlertView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initAlertView];
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate{
    
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (self) {
        [self initAlertView];
        
        if (title) {
            self.titleLabel.text = title;
        }
        
        if (message) {
            self.tipsLabel.text = message;
        }
        
        self.delegate = delegate;
    }
    
    return self;
}


- (void)initAlertView{
    
    phoneRectScreen = [[UIScreen mainScreen] bounds];
    
    [[NSBundle mainBundle] loadNibNamed:@"PayAlertView" owner:self options:nil];
    CGRect frame = self.alertView.frame;
    frame.origin = CGPointZero;
    frame.size = phoneRectScreen.size;
    self.alertView.frame = frame;
    
    [self addSubview:_alertView];
    
    _tradeInputView.delegate = self;
    
    bReqFinished = YES;
    _contentView.alpha = 0.5;
    
    [self getUserData];
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


- (IBAction)closeButtonClicked:(id)sender {
    
    [self close];
}


- (IBAction)forgetButtonClicked:(id)sender {
    
    [self closeButtonClicked:nil];
    
    if (_delegate && [_delegate respondsToSelector:@selector(payAlertView:forgetButtonClicked:)]) {
        [_delegate payAlertView:self forgetButtonClicked:sender];
    }else{
        TJRBaseViewController* ctr = (TJRBaseViewController *)ROOTCONTROLLER.navigationController.topViewController;
        if (!self.user.phone.length) {
            ModifyPhoneController *vc = [[[ModifyPhoneController alloc] initWithNibName:@"ModifyPhoneController" bundle:nil] autorelease];
            vc.isForSetPayPwd = YES;
            [[ctr getTJRAppDelegate].navigation pushViewController:vc animated:YES];
        } else {
            [ctr pageToOrBackWithName:@"PayPasswordController"];
        }
        //TJRBaseViewController* ctr = (TJRBaseViewController *)ROOTCONTROLLER.navigationController.topViewController;
        //[ctr pageToOrBackWithName:@"PayPasswordController"];
    }
}

#pragma mark tradeInputViewDelegate Methods
- (void)tradeInputView:(TradeInputView *)tradeInputView finish:(NSString *)password{
    
    if (tradeInputView == _tradeInputView) {
        
        self.password = password;
        if (password.length>0) {
            NSString* password = [CommonUtil getMD5:_password];
            if (_delegate && [_delegate respondsToSelector:@selector(payAlertView:finish:)]) {
                [_delegate payAlertView:self finish:password];
            }
        }
    }
}

- (void)tradeInputView:(TradeInputView *)tradeInputView statue:(BOOL)statue{

}


- (void)startAnimating{
    _indicatorView.hidden = NO;
    _tradeInputView.userInteractionEnabled = NO;
}

- (void)stopAnimating{
    _indicatorView.hidden = YES;
    _tradeInputView.userInteractionEnabled = YES;
}

- (void)reset{
    self.tipsLabel.text = @"";
    self.password = nil;
    [self.tradeInputView clean];
}

- (void)show{
    
    // 浮现
    [ROOTCONTROLLER.navigationController.topViewController.view.window addSubview:self];
    
    [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
         _contentView.alpha = 1;
        
    }completion:^(BOOL finished){
    }];
    
    /** 弹出键盘 */
    [_tradeInputView becomeFirstResponder];
}

- (void)close{
    [_tradeInputView resignFirstResponder];
    [_tradeInputView clean];
    [self removeFromSuperview];
    _contentView.alpha = 0.5;
}


- (void)dealloc {
    [_titleLabel release];
    [_tipsLabel release];
    [_tradeInputView release];
    [_alertView release];
    [_indicatorView release];
    [_contentView release];
    [_user release];
    [super dealloc];
}
@end
