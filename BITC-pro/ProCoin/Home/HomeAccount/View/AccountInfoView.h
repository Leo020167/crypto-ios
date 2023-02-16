//
//  AccountInfoView.h
//  Cropyme
//
//  Created by Hay on 2019/5/5.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountAssetsEntity.h"

@protocol AccountInfoViewDelegate <NSObject>

@optional
- (void)accountChargeCoinButtonPressed;         //充币
- (void)accountExtractCoinButtonPressed;        //提币
- (void)accountTransferCoinButtonPressed;       //划转
- (void)accountP2pCoinButtonPressed;            //法币交易
@end


@interface AccountInfoView : UIView


@property (assign, nonatomic) id<AccountInfoViewDelegate> delegate;


/** 更新数据*/
- (void)reloadAccountInfoViewData:(AccountAssetsEntity *)assetsEntity;

@end


