//
//  PersonalMainFollowCell.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonalMainFollowModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PersonalMainFollowCell : UITableViewCell

@property (nonatomic, strong) UIButton *titleBtn;

@property (nonatomic, strong) PersonalMainFollowModel *model;

@end

NS_ASSUME_NONNULL_END
