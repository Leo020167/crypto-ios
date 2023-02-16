//
//  TYMineTransactionRecordListCell.h
//  ProCoin
//
//  Created by 李祥翔 on 2022/3/29.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCBaseTransactionRecordModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYMineTransactionRecordListCell : UITableViewCell

@property (nonatomic, strong) PCBaseTransactionRecordModel *model;

@property (nonatomic, copy) void(^statusBtnActionBlock)(void);

@end

NS_ASSUME_NONNULL_END
