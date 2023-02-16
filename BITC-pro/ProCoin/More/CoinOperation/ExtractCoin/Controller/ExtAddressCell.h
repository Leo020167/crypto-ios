//
//  ExtAddressCell.h
//  ProCoin
//
//  Created by Luo Chun on 2022/11/24.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExtAddressCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *model;
@property (nonatomic, assign) BOOL isManager;

@property (nonatomic, copy) void(^deleteBlock)(NSDictionary *model);


@end

NS_ASSUME_NONNULL_END
