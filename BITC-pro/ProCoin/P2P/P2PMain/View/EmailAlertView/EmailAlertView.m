//
//  EmailAlertView.m
//  ProCoin
//
//  Created by sh on 2021/7/24.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "EmailAlertView.h"

#import "CommonUtil.h"
#import "TJRBaseParserJson.h"
#import "NetWorkManage+Security.h"
#import "TJRBaseViewController.h"

@interface EmailAlertView ()
{
    NSTimer* timer;
    NSInteger timerCount;
}
@property (retain, nonatomic) IBOutlet UILabel *contentLab;

@property (retain, nonatomic) IBOutlet UITextField *emailCodeTF;

@property (retain, nonatomic) IBOutlet UIButton *getCodeBtn;

@property (retain, nonatomic) IBOutlet UIButton *nextBtn;

@end


@implementation EmailAlertView


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapEvent:)] autorelease];
    [self addGestureRecognizer:recognizer];
        
    _contentLab.text = [NSString stringWithFormat:@"%@%@", NSLocalizedStringForKey(@"已绑定邮箱号:"),  [CommonUtil hidenEmailStr:ROOTCONTROLLER_USER.email]];
    [_emailCodeTF becomeFirstResponder];
    [CommonUtil viewMasksToBounds:_getCodeBtn cornerRadius:2 borderColor:[UIColor blueColor]];
}


#pragma mark - 按钮点击事件
- (void)backgroundTapEvent:(UIGestureRecognizer *)recognizer {
    [self dismissView];
}

- (IBAction)getEmailCode:(id)sender {
    if (timerCount > 0) {
        return;
    }
    [[NetWorkManage shareSingleNetWork] reqGetEmailCode:self emailStr:ROOTCONTROLLER_USER.email finishedCallback:@selector(requestEmailCodeFinished:) failedCallback:@selector(requestEmailCodeFalid:)];
}

- (IBAction)nextBtnAction:(id)sender {
    [[NetWorkManage shareSingleNetWork] reqCheckEmailCode:self emailStr:ROOTCONTROLLER_USER.email emailCode:_emailCodeTF.text finishedCallback:@selector(requestCheckEmailCodeFinished:) failedCallback:@selector(requestCheckEmailCodeFalid:)];
}


- (void)requestEmailCodeFinished:(NSDictionary *)json {
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];

    if (isok) {
        [self startTimer];
    } else {
        [[CommonUtil getControllerWithContainView:self] showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
    
}

- (void)requestEmailCodeFalid:(NSDictionary *)json {
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];

    if (!isok) {
        NSLog(NSLocalizedStringForKey(@"获取验证码失败"));
    }
    [[CommonUtil getControllerWithContainView:self] showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

- (void)requestCheckEmailCodeFinished:(NSDictionary *)json {
    
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];

    if (isok) {
        if (_delegate && [_delegate respondsToSelector:@selector(emailCodeSuccess)]) {
            [self dismissView];
            [_delegate emailCodeSuccess];
        }
    } else {
        [[CommonUtil getControllerWithContainView:self] showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
    
}

- (void)requestCheckEmailCodeFalid:(NSDictionary *)json {
    
    TJRBaseParserJson *parser = [[[TJRBaseParserJson alloc] init] autorelease];
    BOOL isok = [parser parseBaseIsOk:json];

    if (!isok) {
        NSLog(NSLocalizedStringForKey(@"获取验证码失败"));
    }
    [[CommonUtil getControllerWithContainView:self] showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}



#pragma mark - 定时器 统计超时
- (void)startTimer{
    [self closeTimer];
    timerCount = 60;
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
    if (timerCount>=0) {
        [_getCodeBtn setTitle:[NSString stringWithFormat:NSLocalizedStringForKey(@"剩余 %ld 秒"), (long)timerCount] forState:(UIControlStateNormal)];
        [_getCodeBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
        [CommonUtil viewMasksToBounds:_getCodeBtn cornerRadius:2 borderColor:[UIColor grayColor]];
    }
    if (timerCount == 0) {
        [self closeTimer];
        [_getCodeBtn setTitle:NSLocalizedStringForKey(@"重新获取") forState:(UIControlStateNormal)];
        [_getCodeBtn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
        [CommonUtil viewMasksToBounds:_getCodeBtn cornerRadius:2 borderColor:[UIColor blueColor]];
    }
}


#pragma mark - 显示与消失
/** 显示动画*/
- (void)showInView:(UIView *)view
{
    _emailCodeTF.text = nil;
    [_getCodeBtn setTitle:NSLocalizedStringForKey(@"获取验证码") forState:(UIControlStateNormal)];
    [_getCodeBtn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    [CommonUtil viewMasksToBounds:_getCodeBtn cornerRadius:2 borderColor:[UIColor blueColor]];
    [view addSubview:self];
}

/** 隐藏页面*/
- (void)dismissView
{
    [self removeFromSuperview];
}


- (void)dealloc {
    [_emailCodeTF release];
    [_contentLab release];
    [_nextBtn release];
    [self closeTimer];
    [_getCodeBtn release];
    [super dealloc];
}
@end
