//
//  PledgeRecordCell.m
//  ProCoin
//
//  Created by Luo Chun on 2022/11/23.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "PledgeRecordCell.h"
#import "UIView+General.h"

@interface PledgeRecordCell()

@property (retain, nonatomic) IBOutlet UIView *cardView;
@property (retain, nonatomic) IBOutlet UIView *mainView;
@property (retain, nonatomic) IBOutlet UIView *duringView;

@property (retain, nonatomic) IBOutlet UILabel *coinLabel;
@property (retain, nonatomic) IBOutlet UILabel *duringLabel;
@property (retain, nonatomic) IBOutlet UILabel *gainLabel;  //收益
@property (retain, nonatomic) IBOutlet UILabel *numberLabel;
@property (retain, nonatomic) IBOutlet UILabel *beginTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *endTimeLabel;

@end

@implementation PledgeRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_cardView applyShadow];
    
//    CALayer *layer = [_cardView layer];
//    layer.shadowOffset = CGSizeMake(0, 10);
//    layer.shadowRadius = 10.0;
//    layer.shadowColor = [UIColor blackColor].CGColor;
//    layer.shadowOpacity = 0.05;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_duringView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft  cornerRadii:CGSizeMake(12, 12)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = _duringView.bounds;
    maskLayer.path = maskPath.CGPath;
    _duringView.layer.mask = maskLayer;
}
- (void)setModel:(NSDictionary *)model {
    
    _coinLabel.text = model[@"symbol"];
    _gainLabel.text = model[@"profitRate"];
    _duringLabel.text = [NSString stringWithFormat: @"%@%@", model[@"duration"], NSLocalizedStringForKey(@"天")];
    _numberLabel.text = [NSString stringWithFormat: @"%@", model[@"count"]];
    _beginTimeLabel.text = [VeDateUtil formatterDate:model[@"startTime"] inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    _endTimeLabel.text = [VeDateUtil formatterDate:model[@"endTime"] inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
