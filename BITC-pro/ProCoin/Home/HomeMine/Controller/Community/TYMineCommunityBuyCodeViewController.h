//
//  TYMineCommunityBuyCodeViewController.h
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/2.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYMineCommunityBuyCodeViewController : TJRBaseViewController

@property (nonatomic, copy) NSString *inviteCodePrice;

@property (nonatomic, copy) void(^reloadDataBlock)(void);

@end

NS_ASSUME_NONNULL_END
