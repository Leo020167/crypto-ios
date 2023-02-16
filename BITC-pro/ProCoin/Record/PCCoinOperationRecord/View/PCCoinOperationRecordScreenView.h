//
//  PCCoinOperationRecordScreenView.h
//  ProCoin
//
//  Created by Hay on 2020/3/10.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"

@protocol PCCoinOperationRecordScreenViewDelegate <NSObject>

@required
- (void)coinOperationRecordScreenDidSelectedWithInOut:(NSString *)inOut;

@end



@interface PCCoinOperationRecordScreenView : TJRBaseViewController

@property (assign, nonatomic) id<PCCoinOperationRecordScreenViewDelegate> delegate;

#pragma mark -  显示与消失
- (void)addSelfToParentViewController:(UIViewController *)controller inOut:(NSString *)inOut;

@end


