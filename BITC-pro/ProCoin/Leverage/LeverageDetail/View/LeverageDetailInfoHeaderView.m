//
//  LeverageDetailInfoHeaderView.m
//  BYY
//
//  Created by Hay on 2019/12/30.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "LeverageDetailInfoHeaderView.h"
#import "TradeUtil.h"
#import "CommonUtil.h"

@interface LeverageDetailInfoHeaderView()
{
    CGFloat backgroundIVOriginHeight;
}

@property (retain, nonatomic) IBOutlet UIImageView *backgroundIV;
@property (retain, nonatomic) IBOutlet UILabel *profitLabel;

@end

@implementation LeverageDetailInfoHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    backgroundIVOriginHeight = self.frame.size.height;
    _backgroundIV.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, backgroundIVOriginHeight);
}

- (void)dealloc
{
    [_backgroundIV release];
    [_profitLabel release];
    [super dealloc];
}

- (void)reloadInfoHeaderViewProfit:(NSString *)profit
{
    _profitLabel.text = [TradeUtil stringByAppendingPlusSymbolString:profit];
}

- (void)backgrondImageViewHeightNeedDidChanged:(CGFloat)entraHeight
{
    if(entraHeight == 0){
        if(_backgroundIV.frame.size.height != backgroundIVOriginHeight){
            [_backgroundIV setFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, backgroundIVOriginHeight)];
        }
        return;
    }
    [_backgroundIV setFrame:CGRectMake(0.0, -entraHeight, SCREEN_WIDTH, entraHeight + backgroundIVOriginHeight)];
}
@end
