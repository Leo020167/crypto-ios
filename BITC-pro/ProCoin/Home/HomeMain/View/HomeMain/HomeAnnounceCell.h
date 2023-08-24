//
//  HomeAnnounceCell.h
//  ProCoin
//
//  Created by Luo Chun on 2023/7/21.
//  Copyright © 2023 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMJVerticalScrollText.h"



NS_ASSUME_NONNULL_BEGIN

@interface HomeAnnounceCell : UITableViewCell<LMJVerticalScrollTextDelegate>

@property (nonatomic, strong) NSMutableArray *announceDataArr;
@end

NS_ASSUME_NONNULL_END
