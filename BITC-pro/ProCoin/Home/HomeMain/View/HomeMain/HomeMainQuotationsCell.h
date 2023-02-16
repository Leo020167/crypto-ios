//
//  HomeMainSecondView.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/4.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeQuoteModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeMainQuotationsCell : UITableViewCell

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, copy) void(^clickDataBlock)(HomeQuoteModel *model);

@end

NS_ASSUME_NONNULL_END
