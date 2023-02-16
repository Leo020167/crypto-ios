//
//  NetWorkManage+KBT.h
//  Cropyme
//
//  Created by Hay on 2019/8/14.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "NetWorkManage.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetWorkManage (KBT)

/** KBT资产数据*/
- (void)reqKBTAssetsInfo:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** KBT回购主页数据*/
- (void)reqYYBBuyBackMainInfo:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** YYB公告*/
- (void)reqYYBBuyBackAnnounceData:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 回购YYB*/
- (void)reqYYBRepo:(id)delegate amount:(NSString *)amount finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;



/** ======================================== 认购接口 ===================================*/

/** 认购 */
- (void)reqSubBuy:(id)delegate subId:(NSString *)subId symbol:(NSString *)symbol amount:(NSString *)amount finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 认购主页*/
- (void)reqSubMainHome:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** 获取认购公告*/
- (void)reqSubAnnounceData:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

/** xxx资产*/
- (void)reqAccountAssetsInfo:(id)delegate symbol:(NSString *)symbol pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
@end

NS_ASSUME_NONNULL_END
