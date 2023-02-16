//
//  HomeBigVRankingCell.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfluencerRankEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeBigVRankingCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *dayLabel;

@property (nonatomic, strong) UILabel *leftLabel;

@property (nonatomic, strong) UILabel *centerLabel;

@property (nonatomic, strong) UILabel *rightLabel;

@property (nonatomic, strong) InfluencerRankEntity *model;

- (NSMutableAttributedString *)textWithMoney:(NSString *)count title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
