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

/// 1： 币币 2：合约  3：全球期指
@property (nonatomic, assign) NSInteger index;

- (void)getData;

@end

NS_ASSUME_NONNULL_END
