//
//  P2PHistoryAlertView.m
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "P2PHistoryAlertView.h"
#import "P2PPayWayEntity.h"
#import "RZWebImageView.h"

@interface P2PHistoryAlertView()
{

    
}
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIView *touchView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutContentViewTop;

@property (copy, nonatomic) NSString* buySell;
@property (retain, nonatomic) IBOutlet UIButton *btnBuy;
@property (retain, nonatomic) IBOutlet UIButton *btnSell;
@property (retain, nonatomic) IBOutlet UIButton *btnConfirm;

@end

@implementation P2PHistoryAlertView


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapEvent:)] autorelease];
    [_touchView addGestureRecognizer:recognizer];

}


- (void)dealloc
{
    [_buySell release];
    [_contentView release];
    [_touchView release];
    [_layoutContentViewTop release];
    [_btnBuy release];
    [_btnSell release];
    [_btnConfirm release];
    [super dealloc];
}

- (IBAction)buySellBtnClicked:(id)sender {
    for (int i = 0; i< 2; i++) {
        UIButton* btn = (UIButton*)[self viewWithTag:200 + i];
        btn.selected = NO;
    }
    UIButton* btn = (UIButton*)sender;
    btn.selected = YES;
    
    switch (btn.tag) {
        case 200:
            self.buySell = @"buy";
            break;
        case 201:
            self.buySell = @"sell";
            break;
        default:
            break;
    }
    _btnConfirm.selected = YES;
}


- (IBAction)resetBtnClicked:(id)sender {
    for (int i = 0; i< 2; i++) {
        UIButton* btn = (UIButton*)[self viewWithTag:200 + i];
        btn.selected = NO;
    }
}

- (IBAction)confirmBtnClicked:(id)sender {
    if (!TTIsStringWithAnyText(_buySell)) {
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(p2pView:buySell:)]) {
        [_delegate p2pView:self buySell:_buySell];
    }
    [self dismissView];
}
- (IBAction)dismissBtnClicked:(id)sender {
    [self dismissView];
}

#pragma mark - 按钮点击事件
- (void)backgroundTapEvent:(UIGestureRecognizer *)recognizer
{
    [self dismissView];
}


#pragma mark - 显示与消失
/** 显示动画*/
- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    _layoutContentViewTop.constant = -IPHONEX_TOP_HEIGHT -_contentView.frame.size.height;
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        _layoutContentViewTop.constant = 0;
        [self layoutIfNeeded];
    }completion:^(BOOL finished) {
    }];
    
}

/** 隐藏页面*/
- (void)dismissView
{
    [UIView animateWithDuration:0.3 animations:^{
        _layoutContentViewTop.constant = -IPHONEX_TOP_HEIGHT - _contentView.frame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end

