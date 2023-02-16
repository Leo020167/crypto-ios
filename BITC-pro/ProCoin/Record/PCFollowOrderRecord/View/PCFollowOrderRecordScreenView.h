//
//  PCFollowOrderRecordScreenView.h
//  ProCoin
//
//  Created by Hay on 2020/3/3.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"

@protocol PCFollowOrderRecordScreenViewDelegate <NSObject>

@required
- (void)followOrderRecordScreenCommitDataWithSymbol:(NSString *)symbol orderType:(NSString *)orderType accountType:(NSString *)accountType;

@end

@interface PCFollowOrderRecordScreenView : TJRBaseViewController

@property (assign, nonatomic) id<PCFollowOrderRecordScreenViewDelegate> delegate;

/** 显示view
 * @param inputSymbol 如没初始值刚开始默认传空字符,不要传nil
 * @param orderType 如没初始值刚开始默认传空字符,不要传nil
 * @param accounType 如没初始值刚开始默认传空字符,不要传nil
 */
- (void)addSelfToParentViewController:(UIViewController *)controller inputSymbol:(NSString *)inputSymbol orderType:(NSString *)orderType accounType:(NSString *)accountType;

@end


