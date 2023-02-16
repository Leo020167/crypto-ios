//
//  TYAccountFollowInfoCell.h
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/4.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCAccountModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYAccountFollowInfoCell : UITableViewCell

@property (nonatomic, strong) QMUIButton *rateBtn;

@property (nonatomic, strong) PCAccountModel *followModel;

@property (nonatomic, strong) PCAccountModel *indexModel;

@property (nonatomic, strong) PCAccountModel *contractModel;


@end

NS_ASSUME_NONNULL_END
