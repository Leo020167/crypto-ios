//
//  PCDigitalRecordScreenView.h
//  ProCoin
//
//  Created by Hay on 2020/3/3.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"

@protocol PCDigitalRecordScreenViewDelegate <NSObject>

@required
- (void)digitalRecordScreenCommitDataWithSymbol:(NSString *)symbol orderType:(NSString *)orderType;

@end


@interface PCDigitalRecordScreenView : TJRBaseViewController

@property (assign, nonatomic) id<PCDigitalRecordScreenViewDelegate> delegate;

/** 显示view
 * @param inputSymbol 如没初始值刚开始默认传空字符,不要传nil
 * @param orderType 如没初始值刚开始默认传空字符,不要传nil
 */
- (void)addSelfToParentViewController:(UIViewController *)controller inputSymbol:(NSString *)inputSymbol orderType:(NSString *)orderType;

@end


