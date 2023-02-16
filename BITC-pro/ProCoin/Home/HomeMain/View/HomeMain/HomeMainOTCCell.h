//
//  HomeMainOTCCell.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/12/3.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeMainOTCCell : UITableViewCell

@property (nonatomic, copy) void(^clickActionBlock)(NSUInteger type);

@end

NS_ASSUME_NONNULL_END
