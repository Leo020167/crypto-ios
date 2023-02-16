//
//  PledgeIndexCell.h
//  ProCoin
//
//  Created by Luo Chun on 2022/11/23.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface PledgeIndexCell : UITableViewCell

@property (nonatomic, retain) NSDictionary *model;

@property (nonatomic, copy) void(^clickActionBlock)(NSDictionary *model);

@end

NS_ASSUME_NONNULL_END
