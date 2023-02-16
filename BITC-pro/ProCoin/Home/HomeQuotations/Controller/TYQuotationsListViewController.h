//
//  HomeAccountListViewController.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/12/4.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "JXCategoryListContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYQuotationsListViewController : TJRBaseViewController<JXCategoryListContentViewDelegate>

/// 2新币榜 3涨幅榜 4跌幅榜
@property (nonatomic, assign) NSInteger index;

- (void)getData;

@end

NS_ASSUME_NONNULL_END
