//
//  PledgeBuyViewController.h
//  ProCoin
//
//  Created by Luo Chun on 2022/11/24.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN



@protocol PledgeBuyViewControllerDelegate <NSObject>

@required
- (void)digitalRecordScreenCommitDataWithSymbol:(NSString *)symbol orderType:(NSString *)orderType;

@end


@interface PledgeBuyViewController : TJRBaseViewController

@property (assign, nonatomic) id<PledgeBuyViewControllerDelegate> delegate;

/** 显示view
 * @param inputSymbol 如没初始值刚开始默认传空字符,不要传nil
 * @param orderType 如没初始值刚开始默认传空字符,不要传nil
 */
- (void)addSelfToParentViewController:(UIViewController *)controller pid:(NSString *)orderType;

@end


NS_ASSUME_NONNULL_END
