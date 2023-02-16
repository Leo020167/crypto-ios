//
//  TYMineTransactionRecordListViewController.h
//  ProCoin
//
//  Created by 李祥翔 on 2022/3/29.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "JXCategoryListContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYMineTransactionRecordListViewController : TJRBaseViewController<JXCategoryListContentViewDelegate>

/// 0历史 1委托
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, copy) NSString *accountType;

/// 筛选的交易队
@property (nonatomic, copy) NSString *screenSymbol;

/// 筛选的订单类型
@property (nonatomic, copy) NSString *screenOrderType;

- (void)getData;

@end

NS_ASSUME_NONNULL_END
