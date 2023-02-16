//
//  TYAccountBalanceInfoCell.h
//  ProCoin
//
//  Created by 李祥翔 on 2022/8/21.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCAccountModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYAccountBalanceInfoCell : UITableViewCell

@property (nonatomic, strong) PCAccountModel *balanceModel;

@property (nonatomic, strong) PCAccountModel *coinModel;

@end

NS_ASSUME_NONNULL_END
