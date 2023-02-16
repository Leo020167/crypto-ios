//
//  ExtAddressCell.m
//  ProCoin
//
//  Created by Luo Chun on 2022/11/24.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "ExtAddressCell.h"
#import "UIView+General.h"

@interface ExtAddressCell () {
    NSDictionary *info;
}

@property (retain, nonatomic) IBOutlet UIView *cardView;

@property (retain, nonatomic) IBOutlet UILabel *coinLabel;
@property (retain, nonatomic) IBOutlet UILabel *addressLabel;
@property (retain, nonatomic) IBOutlet UILabel *descLabel;
@property (retain, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (retain, nonatomic) IBOutlet UIButton *deleteBtn;

@end

@implementation ExtAddressCell

- (void)dealloc
{
    [_coinLabel release];
    [_addressLabel release];
    [_descLabel release];
    [_arrowImageView release];
    [_deleteBtn release];
    [super dealloc];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_cardView applyShadow];
    
}

- (void)setIsManager:(BOOL)isManager {
    [_deleteBtn setHidden:!isManager];
    [_arrowImageView setHidden:isManager];
}

/// "address": "1231231231","createTime": "1669814953","id": "1597945848128417793","remark": "111","symbol": "BTC","userId": "2009591"
- (void)setModel:(NSDictionary *)model {
    info = model;
    _coinLabel.text = model[@"symbol"];
    _addressLabel.text = model[@"address"];
    _descLabel.text = model[@"remark"];
    
}

- (IBAction)deleteAddress:(id)sender {
    self.deleteBlock(info);
}


@end
