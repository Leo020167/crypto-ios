//
//  ExtAddressViewController.h
//  ProCoin
//
//  Created by Luo Chun on 2022/11/24.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRBaseViewController.h"
#import "ExtractCoinDataEntity.h"

@protocol ExtAddressViewDelegate <NSObject>

@optional
- (void)extAddressViewDidSelected:(CoinWithdrawConfigAddress *_Nonnull)address;

@end



NS_ASSUME_NONNULL_BEGIN

@interface ExtAddressViewController : TJRBaseViewController

@property (assign, nonatomic) id<ExtAddressViewDelegate> delegate;

@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, strong) NSString *chainType;

@end

NS_ASSUME_NONNULL_END
