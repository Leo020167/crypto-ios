//
//  PledgeIndexCell.m
//  ProCoin
//
//  Created by Luo Chun on 2022/11/23.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "PledgeIndexCell.h"
#import "UIView+General.h"

@interface PledgeIndexCell () {
    NSDictionary *info;
}

@property (retain, nonatomic) IBOutlet UIView *cardView;

@property (retain, nonatomic) IBOutlet UILabel *coinLabel;
@property (retain, nonatomic) IBOutlet UILabel *minNumLabel;
@property (retain, nonatomic) IBOutlet UILabel *daysLabel;
//@property (retain, nonatomic) IBOutlet UILabel *earningLabel;
@property (retain, nonatomic) IBOutlet UILabel *evdayFeeLabel;   //每日利息

@end

@implementation PledgeIndexCell
- (void)awakeFromNib {
    [super awakeFromNib];
    
//    CALayer *layer = [_cardView layer];
//    layer.shadowOffset = CGSizeMake(0, 10);
//    layer.shadowRadius = 10.0;
//    layer.shadowColor = [UIColor blackColor].CGColor;
//    layer.shadowOpacity = 0.05;
    
    [_cardView applyShadow];
}


- (void)setModel:(NSDictionary *)model {
    info = model;
    _coinLabel.text = model[@"symbol"];
    //_minNumLabel.text = model[@"minCount"];
    //_daysLabel.text = model[@"duration"];
    //_earningLabel.text = model[@"profitRate"];
    _evdayFeeLabel.text = model[@"profitRate"];
    _daysLabel.text = [NSString stringWithFormat: @"%@%@", model[@"duration"], NSLocalizedStringForKey(@"天")];
    _evdayFeeLabel.text = [NSString stringWithFormat: @"%@%%", model[@"profitRate"]];
    _minNumLabel.text = model[@"minCount"] ;

}

- (IBAction)action:(id)sender {
    self.clickActionBlock(info);
}

@end
