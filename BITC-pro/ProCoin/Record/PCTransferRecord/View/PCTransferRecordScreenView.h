//
//  PCTransferRecordScreenView.h
//  ProCoin
//
//  Created by Hay on 2020/3/6.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "PCTransferAccountModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol PCTransferRecordScreenViewDelegate <NSObject>


@required
- (void)transferRecordScreenCommitDataWithFromAccountType:(NSString *)fromAccountType toAccountType:(NSString *)toAccountType;

@end

@interface PCTransferRecordScreenView : TJRBaseViewController

@property (assign, nonatomic) id<PCTransferRecordScreenViewDelegate> delegate;

/** 显示view*/
- (void)addSelfToParentViewController:(UIViewController *)controller fromAcountArr:(NSArray *)fromAccountArr toAccountArr:(NSArray *)toAccountArr fromAccountType:(NSString *)fromAccountType toAccountType:(NSString *)toAccountType;

@end

NS_ASSUME_NONNULL_END
