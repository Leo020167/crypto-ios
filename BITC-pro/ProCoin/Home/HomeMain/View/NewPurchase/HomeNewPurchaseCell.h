//
//  HomeNewPurchaseCell.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/23.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeNewPurchaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeNewPurchaseCell : UITableViewCell

@property (nonatomic, strong) HomeNewPurchaseListModel *model;

@property (nonatomic, copy) void(^reloadDataBlock)(void);

@end

NS_ASSUME_NONNULL_END
