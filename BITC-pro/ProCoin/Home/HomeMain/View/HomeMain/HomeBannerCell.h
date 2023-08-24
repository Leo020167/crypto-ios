//
//  HomeBannerCell.h
//  ProCoin
//
//  Created by Luo Chun on 2023/7/21.
//  Copyright © 2023 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDCycleScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeBannerCell : UITableViewCell<SDCycleScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *bannerArray;
@end

NS_ASSUME_NONNULL_END
