//
//  AccountInfoView.m
//  Cropyme
//
//  Created by Hay on 2019/5/5.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "AccountInfoView.h"
#import "CommonUtil.h"
#import "TradeUtil.h"

@interface AccountInfoView()
{
    CGFloat bgOriginHeight;
}

@property (retain, nonatomic) IBOutlet UILabel *tolAssetsLabel;         //总的usdt数目
@property (retain, nonatomic) IBOutlet UILabel *tolMoneyLabel;          //约等于多少人民币
@property (retain, nonatomic) IBOutlet UIView *backgroundView;

@end


@implementation AccountInfoView

- (void)awakeFromNib
{
    [super awakeFromNib];
    CGFloat viewMaxHeight = self.frame.size.height + STATUS_BAR_HEIGHT;
    bgOriginHeight = viewMaxHeight;
    [self setFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, viewMaxHeight)];
    [CommonUtil viewHeightForAutoLayout:_backgroundView height:viewMaxHeight];
}

- (void)dealloc
{
    [_backgroundView release];
    [_tolAssetsLabel release];
    [_tolMoneyLabel release];
    [super dealloc];
}


/** 更新数据*/
- (void)reloadAccountInfoViewData:(AccountAssetsEntity *)assetsEntity
{
    _tolAssetsLabel.text = assetsEntity.tolAssets;
    _tolMoneyLabel.text = assetsEntity.tolAssetsCny;
    [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
}

#pragma mark -  按钮点击事件
/** 充值按钮点击事件*/
- (IBAction)chargeCoinButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(accountChargeCoinButtonPressed)]){
        [_delegate accountChargeCoinButtonPressed];
    }
}

/** 提币按钮点击事件*/
- (IBAction)extractCoinButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(accountExtractCoinButtonPressed)]){
        [_delegate accountExtractCoinButtonPressed];
    }
}

/** 划转按钮点击事件*/
- (IBAction)transferCoinButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(accountTransferCoinButtonPressed)]){
        [_delegate accountTransferCoinButtonPressed];
    }
}

/** 法币交易按钮点击事件*/
- (IBAction)p2pCoinButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(accountTransferCoinButtonPressed)]){
        [_delegate accountP2pCoinButtonPressed];
    }
}

@end
