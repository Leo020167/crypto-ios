//
//  BankWayAlertView.m
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "BankWayAlertView.h"
#import "TJRBaseParserJson.h"
#import "NetWorkManage+P2P.h"
#import "CommonUtil.h"
#import "TJRBaseViewController.h"

@interface BankWayAlertView()
{
    BOOL bReqFinished;
    
}
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIView *touchView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutContentViewBottom;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutAlipayHeight;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutBandHeight;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutWechatHeight;
@property (retain, nonatomic) IBOutlet UIView *alipayView;
@property (retain, nonatomic) IBOutlet UIView *bankView;
@property (retain, nonatomic) IBOutlet UIView *wechatView;
@end

@implementation BankWayAlertView


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapEvent:)] autorelease];
    [_touchView addGestureRecognizer:recognizer];

    bReqFinished = YES;
}


- (void)dealloc
{
    [_contentView release];
    [_touchView release];
    [_layoutContentViewBottom release];
    [_indicatorView release];
    [_layoutAlipayHeight release];
    [_layoutBandHeight release];
    [_layoutWechatHeight release];
    [_alipayView release];
    [_bankView release];
    [_wechatView release];
    [super dealloc];
}


#pragma mark - 按钮点击事件
- (void)backgroundTapEvent:(UIGestureRecognizer *)recognizer
{
    [self dismissView];
}

#pragma mark - 请求数据接口
- (void)reqP2PFindPaymentOption
{
    if (bReqFinished) {
        bReqFinished = NO;
        [_indicatorView startAnimating];
        [[NetWorkManage shareSingleNetWork] reqP2PFindPaymentOptionList:self  finishedCallback:@selector(reqFindPaymentOptionFinished:) failedCallback:@selector(reqFindPaymentOptionFailed:)];
    }
    
}

- (void)reqFindPaymentOptionFinished:(id)result
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
        NSArray *list = [dataDic objectForKey:@"paymentOptionList"];
        
        _layoutAlipayHeight.constant = 0.5;
        _layoutWechatHeight.constant = 0.5;
        _layoutBandHeight.constant = 0.5;
        _alipayView.hidden = YES;
        _wechatView.hidden = YES;
        _bankView.hidden = YES;

        for(NSDictionary *dic in list){
            NSString* receiptType = [parser stringParser:dic name:@"receiptType"];
            if ([receiptType isEqualToString:@"1"]) {
                _layoutAlipayHeight.constant = 50;
                _alipayView.hidden = NO;
            }
            if ([receiptType isEqualToString:@"2"]) {
                _layoutWechatHeight.constant = 50;
                _wechatView.hidden = NO;
            }
            if ([receiptType isEqualToString:@"3"]) {
                _layoutBandHeight.constant = 50;
                _bankView.hidden = NO;
            }
        }
        
        
    }else{
            [[CommonUtil getControllerWithContainView:self] showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}



- (void)reqFindPaymentOptionFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [_indicatorView stopAnimating];
    [[CommonUtil getControllerWithContainView:self] showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}


#pragma mark - 显示与消失
/** 显示动画*/
- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [self reqP2PFindPaymentOption];
    _layoutContentViewBottom.constant = -64 + IPHONEX_BOTTOM_HEIGHT;
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        _layoutContentViewBottom.constant = 0;
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
        [self removeFromSuperview];
    }];
}

- (IBAction)alipayButtonClicked:(id)sender {
    [self dismissView];
    if (_delegate && [_delegate respondsToSelector:@selector(p2pView:alipayButtonClicked:)]) {
        [_delegate p2pView:self alipayButtonClicked:sender];
    }
}

- (IBAction)bankButtonClicked:(id)sender {
    [self dismissView];
    if (_delegate && [_delegate respondsToSelector:@selector(p2pView:bankButtonClicked:)]) {
        [_delegate p2pView:self bankButtonClicked:sender];
    }
}

- (IBAction)wechatpayButtonClicked:(id)sender {
    [self dismissView];
    if (_delegate && [_delegate respondsToSelector:@selector(p2pView:wechatpayButtonClicked:)]) {
        [_delegate p2pView:self wechatpayButtonClicked:sender];
    }
}

@end

