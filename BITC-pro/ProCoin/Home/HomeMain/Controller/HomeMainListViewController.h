//
//  HomeMainListViewController.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/12/3.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "JXPagerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeMainListViewController : TJRBaseViewController<JXPagerViewListViewDelegate>

@property (nonatomic, assign) NSInteger index ;

- (void)getData;

@end

NS_ASSUME_NONNULL_END
