//
//  CoinSubOperationView.m
//  BYY
//
//  Created by Hay on 2019/10/10.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CoinSubOperationView.h"

@interface CoinSubOperationView()

@property (retain, nonatomic) IBOutlet UIButton *buyButton;     //认购按钮
@property (retain, nonatomic) IBOutlet UIButton *tradeButton;   //交易按钮


@end

@implementation CoinSubOperationView

- (void)dealloc
{
    [_buyButton release];
    [_tradeButton release];
    [super dealloc];
}

#pragma mark - 数据展示
- (void)reloadButtonStateWithBuyButtonState:(BOOL)buyEnable tradeButtonState:(BOOL)tradeEnable buyButtonTitle:(NSString *)buyButtonTitle
{
    [_buyButton setTitle:buyButtonTitle forState:UIControlStateNormal];
    _buyButton.enabled = buyEnable;
    _tradeButton.enabled = tradeEnable;
    if(buyEnable){
        _buyButton.backgroundColor = RGBA(97, 117, 174, 1.0);
    }else{
        _buyButton.backgroundColor = RGBA(97, 117, 174, 0.4);
    }
    
    if(tradeEnable){
        _tradeButton.backgroundColor = RGBA(97, 117, 174, 1.0);
    }else{
        _tradeButton.backgroundColor = RGBA(97, 117, 174, 0.4);
    }
    
}


#pragma mark - 按钮点击事件
/** 认购按钮点击事件*/
- (IBAction)buyBackButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(coinSubOperationViewSubscribeButtonDidSelected)]){
        [_delegate coinSubOperationViewSubscribeButtonDidSelected];
    }
}

/** 交易按钮点击事件*/
- (IBAction)tradeButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(coinSubOperationViewTradeButtonDidSelected)]){
        [_delegate coinSubOperationViewTradeButtonDidSelected];
    }
}


@end
