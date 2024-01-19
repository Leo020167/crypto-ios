//
//  NetWorkManage+Home.h
//  TJRtaojinniu
//
//  Created by Hay on 2017/5/6.
//  Copyright © 2017年 Taojinroad. All rights reserved.
//

#import "NetWorkManage.h"

@interface NetWorkManage (Home)

#pragma mark - 首页获取基本App信息,版本更新等等内容
- (void)reqHomeGet:(id)delegate noticeTime:(NSString*)noticeTime finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 账户数据
- (void)reqHomeAccountInfo:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 行情数据【已弃用】
- (void)reqHomeMarketInfo:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 获取自选股
- (void)reqCustomCoinFollowList:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 排序自选股 symbolAndSort=BTC/USDT:0,ETH/USDT:1,EOS/USDT:2
- (void)reqSortCustomSymbol:(id)delegate symbolAndSort:(NSString *)symbolAndSort finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 删除自选股
- (void)reqDeleteCustomSymbol:(id)delegate symbol:(NSString *)symbol finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - cropyme数据
- (void)reqHomeCropymeData:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 获取关注页数据
- (void)reqHomeFollowUsers:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 搜索用户
- (void)reqHomeSearchUser:(id)delegate keyValue:(NSString *)keyValue finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 请求我的页面数据
- (void)reqHomeMineData:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 能力值兑换
- (void)reqAbilityToKBT:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 获取顶部公告
- (void)reqTopAnnounceData:(id)delegate finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 获取更多公告(带分页)
- (void)reqAnnounceDataList:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 获取帮助列表(带分页)
- (void)reqHelpDataList:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

#pragma mark - 获取平台公告列表(带分页)
- (void)reqPlatformAnnouncementDataList:(id)delegate pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;
@end



