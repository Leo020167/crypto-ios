//
//  TYAccountListViewController.h
//  ProCoin
//
//  Created by 李祥翔 on 2022/8/24.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "JXPagerView.h"
#import "PCAccountModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYAccountCoinViewController : TJRBaseViewController<JXPagerViewListViewDelegate>

- (void)getData:(PCAccountModel *)model;

@end

NS_ASSUME_NONNULL_END
