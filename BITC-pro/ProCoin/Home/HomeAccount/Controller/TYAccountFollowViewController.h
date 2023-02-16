//
//  TYAccountFollowViewController.h
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/4.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "JXPagerView.h"
#import "PCAccountModel.h"
#import "PCBaseHoldCoinModel.h"
#import "PCHomeUserFollowOrderInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYAccountFollowViewController : TJRBaseViewController<JXPagerViewListViewDelegate>

- (void)getData:(PCAccountModel *)model;

@end

NS_ASSUME_NONNULL_END
