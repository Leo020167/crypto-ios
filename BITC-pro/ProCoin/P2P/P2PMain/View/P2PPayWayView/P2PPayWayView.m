//
//  P2PPayWayView.m
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "P2PPayWayView.h"
#import "CommonUtil.h"

@interface P2PPayWayView(){

}
@property (retain, nonatomic) IBOutlet UIView *contentView;         //内容view
@property (retain, nonatomic) IBOutlet UIView *touchView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentViewLayoutConstraintTop; //内容view约束
@property (retain, nonatomic) IBOutlet UIButton *btnAll;
@property (retain, nonatomic) IBOutlet UIButton *btnBank;
@property (retain, nonatomic) IBOutlet UIButton *btnAlipay;
@property (retain, nonatomic) IBOutlet UIButton *btnWechatPay;
@end

@implementation P2PPayWayView


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapEvent:)] autorelease];
    [_touchView addGestureRecognizer:recognizer];

    [CommonUtil viewMasksToBounds:_btnAll cornerRadius:3 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
}


- (void)dealloc
{
    [_contentView release];
    [_touchView release];
    [_contentViewLayoutConstraintTop release];
    [_btnAll release];
    [_btnBank release];
    [_btnAlipay release];
    [_btnWechatPay release];
    [super dealloc];
}


#pragma mark - 按钮点击事件
- (void)backgroundTapEvent:(UIGestureRecognizer *)recognizer
{
    [self dismissView];
}
- (IBAction)allBtnClicked:(id)sender {
    _btnAll.selected = ! _btnAll.selected;
    _btnBank.selected = _btnAlipay.selected = _btnWechatPay.selected = ! _btnAll.selected;
    
    [CommonUtil viewMasksToBounds:_btnAll cornerRadius:3 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
    [CommonUtil viewMasksToBounds:_btnBank cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    [CommonUtil viewMasksToBounds:_btnAlipay cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    [CommonUtil viewMasksToBounds:_btnWechatPay cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    
    if (_delegate && [_delegate respondsToSelector:@selector(p2pView:buttonClicked:filterPayWay:)]) {
        [_delegate p2pView:self buttonClicked:sender filterPayWay:@"0"];
    }
    [self close];
}
- (IBAction)bankBtnClicked:(id)sender {
    _btnBank.selected = ! _btnBank.selected;
    _btnAll.selected = _btnAlipay.selected = _btnWechatPay.selected = ! _btnBank.selected;
    
    [CommonUtil viewMasksToBounds:_btnBank cornerRadius:3 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
    [CommonUtil viewMasksToBounds:_btnAll cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    [CommonUtil viewMasksToBounds:_btnAlipay cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    [CommonUtil viewMasksToBounds:_btnWechatPay cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    
    if (_delegate && [_delegate respondsToSelector:@selector(p2pView:buttonClicked:filterPayWay:)]) {
        [_delegate p2pView:self buttonClicked:sender filterPayWay:@"3"];
    }
    [self close];
}
- (IBAction)alipayBtnClicked:(id)sender {
    _btnAlipay.selected = ! _btnAlipay.selected;
    _btnAll.selected = _btnBank.selected = _btnWechatPay.selected = ! _btnAlipay.selected;
    
    [CommonUtil viewMasksToBounds:_btnAlipay cornerRadius:3 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
    [CommonUtil viewMasksToBounds:_btnBank cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    [CommonUtil viewMasksToBounds:_btnAll cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    [CommonUtil viewMasksToBounds:_btnWechatPay cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    
    if (_delegate && [_delegate respondsToSelector:@selector(p2pView:buttonClicked:filterPayWay:)]) {
        [_delegate p2pView:self buttonClicked:sender filterPayWay:@"1"];
    }
    [self close];
}
- (IBAction)wechatpayBtnClicked:(id)sender {
    _btnWechatPay.selected = ! _btnWechatPay.selected;
    _btnAll.selected = _btnBank.selected = _btnAlipay.selected = !_btnWechatPay.selected;
    
    [CommonUtil viewMasksToBounds:_btnWechatPay cornerRadius:3 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
    [CommonUtil viewMasksToBounds:_btnBank cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    [CommonUtil viewMasksToBounds:_btnAlipay cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    [CommonUtil viewMasksToBounds:_btnAll cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    
    if (_delegate && [_delegate respondsToSelector:@selector(p2pView:buttonClicked:filterPayWay:)]) {
        [_delegate p2pView:self buttonClicked:sender filterPayWay:@"2"];
    }
    [self close];
}


#pragma mark - 显示与消失
/** 显示动画*/
- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    _contentViewLayoutConstraintTop.constant = -_contentView.frame.size.height;
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintTop.constant = 0;
        [self layoutIfNeeded];
    }];
    self.displayed = YES;
}

/** 隐藏页面*/
- (void)dismissView
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintTop.constant = -_contentView.frame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (_delegate && [_delegate respondsToSelector:@selector(p2pView:dismissView:)]) {
            [_delegate p2pView:self dismissView:self];
        }
        [self removeFromSuperview];
    }];
    self.displayed = NO;
}

- (void)close
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintTop.constant = -_contentView.frame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    self.displayed = NO;
}


@end
