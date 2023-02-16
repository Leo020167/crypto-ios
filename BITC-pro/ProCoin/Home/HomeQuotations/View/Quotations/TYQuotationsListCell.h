//
//  TYQuotationsListCell.h
//  ProCoin
//
//  Created by 李祥翔 on 2022/3/28.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeQuoteModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYQuotationsListCell : UITableViewCell

@property (nonatomic, copy) void(^changeAnimState)(HomeQuoteModel *model);

- (void)bindModel:(HomeQuoteModel *)model;
@end

NS_ASSUME_NONNULL_END
