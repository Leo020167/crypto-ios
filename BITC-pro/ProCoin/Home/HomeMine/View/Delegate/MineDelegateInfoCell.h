//
//  MineDelegateInfoCell.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/10/28.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MineDelegateInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MineDelegateInfoCell : UITableViewCell

@property (nonatomic, strong) MineDelegateInfoModel *model;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

NS_ASSUME_NONNULL_END
